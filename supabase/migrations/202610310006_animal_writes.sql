create table public.write_operations (
 actor_id uuid not null references auth.users(id),
 operation_key text not null check (operation_key ~ '^[A-Za-z0-9_-]{32}$'),
 operation_kind text not null check (operation_kind in ('save_animal','set_status','set_publication')),
 payload_digest text not null,
 result jsonb not null,
 completed_at timestamptz not null default now(),
 primary key(actor_id,operation_key)
);
alter table public.write_operations enable row level security;
revoke all on public.write_operations from public,anon,authenticated;
grant all on public.write_operations to service_role;

create function private.managed_animal_json(p_id uuid) returns jsonb
language sql stable security definer set search_path='' as $$
 select jsonb_build_object('animal',to_jsonb(a),'clinical_notes',d.clinical_notes,
   'care_records',coalesce((select jsonb_agg(to_jsonb(c) order by c.created_at,c.id)
     from public.clinical_records c where c.animal_id=a.id),'[]'::jsonb))
 from public.animals a join public.animal_internal_details d on d.animal_id=a.id where a.id=p_id;
$$;
revoke all on function private.managed_animal_json(uuid) from public,anon,authenticated;

create function public.get_managed_animal(p_animal_id uuid) returns jsonb
language plpgsql stable security definer set search_path='' as $$
declare v_result jsonb;
begin
 if not private.is_staff_current() then raise exception using errcode='42501',message='staff_required'; end if;
 v_result:=private.managed_animal_json(p_animal_id);
 if v_result is null then raise exception using errcode='PT404',message='not_found'; end if;
 return v_result;
end;
$$;

create function public.list_managed_animals(p_status text default null,p_cursor jsonb default null) returns jsonb
language plpgsql stable security definer set search_path='' as $$
declare v_items jsonb; v_total bigint; v_last jsonb;
begin
 if not private.is_staff_current() then raise exception using errcode='42501',message='staff_required'; end if;
 if p_status is not null and p_status not in ('available','treatment','quarantine','adopted') then
   raise exception using errcode='22023',message='invalid_status'; end if;
 if p_cursor is not null and (jsonb_typeof(p_cursor)<>'array' or jsonb_array_length(p_cursor)<>2
   or jsonb_typeof(p_cursor->0)<>'string' or jsonb_typeof(p_cursor->1)<>'string') then
   raise exception using errcode='22023',message='invalid_cursor'; end if;
 select count(*) into v_total from public.animals a where p_status is null or a.status=p_status;
 select coalesce(jsonb_agg(private.managed_animal_json(x.id) order by x.name,x.id),'[]') into v_items
 from (select a.id,a.name from public.animals a where (p_status is null or a.status=p_status)
   and (p_cursor is null or (a.name,a.id)>((p_cursor->>0),(p_cursor->>1)::uuid))
   order by a.name,a.id limit 50) x;
 if jsonb_array_length(v_items)=50 then
   v_last:=v_items->49->'animal';
 end if;
 return jsonb_build_object('items',v_items,'total',v_total,'cursor',
   case when v_last is null then null else jsonb_build_array(v_last->>'name',v_last->>'id') end);
end;
$$;

create function public.get_write_operation(p_operation_key text) returns jsonb
language plpgsql stable security definer set search_path='' as $$
begin
 if not private.is_staff_current() then raise exception using errcode='42501',message='staff_required'; end if;
 return (select result from public.write_operations where actor_id=auth.uid() and operation_key=p_operation_key);
end;
$$;

create function public.save_animal(p_operation_key text,p_payload jsonb) returns jsonb
language plpgsql security definer set search_path='' as $$
declare
 v_payload jsonb; v_records jsonb; v_record jsonb; v_id uuid; v_actor uuid;
 v_digest text; v_existing public.write_operations%rowtype; v_result jsonb;
begin
 if not private.is_staff_current() then raise exception using errcode='42501',message='staff_required'; end if;
 v_actor:=auth.uid();
 if p_operation_key is null or p_operation_key !~ '^[A-Za-z0-9_-]{32}$' or jsonb_typeof(p_payload) is distinct from 'object' then
   raise exception using errcode='22023',message='invalid_payload'; end if;
 if exists(select 1 from jsonb_object_keys(p_payload) k where k not in
   ('id','name','species','sex','size','approximate_age','public_description','clinical_notes','is_vaccinated','is_neutered','care_records')) then
   raise exception using errcode='22023',message='invalid_payload'; end if;
 if exists(select 1 from jsonb_each(p_payload) e where e.key in
   ('name','species','sex','size','approximate_age','public_description','clinical_notes') and jsonb_typeof(e.value)<>'string')
   or exists(select 1 from jsonb_each(p_payload) e where e.key in ('is_vaccinated','is_neutered') and jsonb_typeof(e.value)<>'boolean')
   or (p_payload ? 'id' and jsonb_typeof(p_payload->'id') not in ('string','null')) then
   raise exception using errcode='22023',message='invalid_payload'; end if;
 v_records:=coalesce(p_payload->'care_records','[]');
 if jsonb_typeof(v_records)<>'array' then raise exception using errcode='22023',message='invalid_payload'; end if;
 for v_record in select value from jsonb_array_elements(v_records) loop
   if jsonb_typeof(v_record)<>'object' or jsonb_typeof(v_record->'description') is distinct from 'string'
      or jsonb_typeof(v_record->'kind') is distinct from 'string'
      or exists(select 1 from jsonb_object_keys(v_record) k where k not in ('kind','description'))
      or v_record->>'kind' not in ('vaccination','deworming','medication')
      or char_length(btrim(v_record->>'description')) not between 1 and 1000 then
     raise exception using errcode='22023',message='invalid_payload'; end if;
 end loop;
 select coalesce(jsonb_agg(jsonb_build_object('kind',value->>'kind','description',btrim(value->>'description')) order by ordinality),'[]')
   into v_records from jsonb_array_elements(v_records) with ordinality;
 v_payload:=jsonb_build_object('id',p_payload->>'id','name',btrim(p_payload->>'name'),
   'species',p_payload->>'species','sex',p_payload->>'sex','size',p_payload->>'size',
   'approximate_age',btrim(p_payload->>'approximate_age'),'public_description',coalesce(p_payload->>'public_description',''),
   'clinical_notes',coalesce(p_payload->>'clinical_notes',''),'is_vaccinated',coalesce((p_payload->>'is_vaccinated')::boolean,false),
   'is_neutered',coalesce((p_payload->>'is_neutered')::boolean,false),'care_records',v_records);
 if coalesce(char_length(v_payload->>'name'),0) not between 1 and 80
   or coalesce(char_length(v_payload->>'approximate_age'),0) not between 1 and 80
   or coalesce(v_payload->>'species','') not in ('dog','cat')
   or coalesce(v_payload->>'sex','') not in ('female','male')
   or coalesce(v_payload->>'size','') not in ('small','medium','large')
   or char_length(v_payload->>'public_description')>3000 or char_length(v_payload->>'clinical_notes')>3000 then
   raise exception using errcode='22023',message='invalid_payload'; end if;
 v_digest:=encode(extensions.digest(v_payload::text,'sha256'),'hex');
 -- Same actor/key is serialized across concurrent HTTP sessions, including creates.
 perform pg_advisory_xact_lock(hashtextextended(v_actor::text||':'||p_operation_key,0));
 if not private.is_staff_current() then raise exception using errcode='42501',message='staff_required'; end if;
 select * into v_existing from public.write_operations where actor_id=v_actor and operation_key=p_operation_key;
 if found then
   if v_existing.operation_kind<>'save_animal' or v_existing.payload_digest<>v_digest then
     raise exception using errcode='PT409',message='operation_conflict'; end if;
   return v_existing.result;
 end if;
 if v_payload->>'id' is null then
   insert into public.animals(name,species,sex,size,approximate_age,public_description,is_vaccinated,is_neutered)
   values(v_payload->>'name',v_payload->>'species',v_payload->>'sex',v_payload->>'size',v_payload->>'approximate_age',
     v_payload->>'public_description',(v_payload->>'is_vaccinated')::boolean,(v_payload->>'is_neutered')::boolean)
   returning id into v_id;
   insert into public.animal_internal_details(animal_id,created_by,updated_by) values(v_id,v_actor,v_actor);
 else
   v_id:=(v_payload->>'id')::uuid;
   perform 1 from public.animals where id=v_id for update;
   if not found then raise exception using errcode='PT404',message='not_found'; end if;
   if not private.is_staff_current() then raise exception using errcode='42501',message='staff_required'; end if;
   update public.animals set name=v_payload->>'name',species=v_payload->>'species',sex=v_payload->>'sex',size=v_payload->>'size',
     approximate_age=v_payload->>'approximate_age',public_description=v_payload->>'public_description',
     is_vaccinated=(v_payload->>'is_vaccinated')::boolean,is_neutered=(v_payload->>'is_neutered')::boolean where id=v_id;
 end if;
 update public.animal_internal_details set clinical_notes=v_payload->>'clinical_notes',updated_at=now(),updated_by=v_actor where animal_id=v_id;
 delete from public.clinical_records where animal_id=v_id;
 insert into public.clinical_records(animal_id,kind,description,created_by,updated_by)
   select v_id,value->>'kind',value->>'description',v_actor,v_actor from jsonb_array_elements(v_records);
 v_result:=private.managed_animal_json(v_id);
 insert into public.write_operations(actor_id,operation_key,operation_kind,payload_digest,result)
 values(v_actor,p_operation_key,'save_animal',v_digest,v_result);
 return v_result;
exception when invalid_text_representation then
 raise exception using errcode='22023',message='invalid_payload';
end;
$$;

revoke all on function public.get_managed_animal(uuid),public.list_managed_animals(text,jsonb),
 public.get_write_operation(text),public.save_animal(text,jsonb) from public,anon;
grant execute on function public.get_managed_animal(uuid),public.list_managed_animals(text,jsonb),
 public.get_write_operation(text),public.save_animal(text,jsonb) to authenticated;
