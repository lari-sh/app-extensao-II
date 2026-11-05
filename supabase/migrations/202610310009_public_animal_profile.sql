-- Deliberately public summaries; no backfill from private clinical records.
alter table public.animals add column last_dewormed_on date,
 add column temperament text,
 add constraint animals_public_deworming_date check (last_dewormed_on is null or last_dewormed_on <= (current_timestamp at time zone 'America/Sao_Paulo')::date),
 add constraint animals_public_temperament check (temperament is null or (temperament=btrim(temperament,E' \t\n\r') and char_length(temperament) between 1 and 120));
comment on column public.animals.last_dewormed_on is 'Public date of last deworming application; never copied from private history.';
comment on column public.animals.temperament is 'Deliberately public temperament summary entered by staff.';

create or replace function public.save_animal(p_operation_key text,p_payload jsonb) returns jsonb
language plpgsql security definer set search_path='' as $$
declare
 v_payload jsonb; v_records jsonb; v_record jsonb; v_id uuid; v_actor uuid;
 v_digest text; v_existing public.write_operations%rowtype; v_result jsonb;
 v_public_date_text text; v_public_date date; v_temperament text;
begin
 if not private.is_staff_current() then raise exception using errcode='42501',message='staff_required'; end if;
 v_actor:=auth.uid();
 if p_operation_key is null or p_operation_key !~ '^[A-Za-z0-9_-]{32}$' or jsonb_typeof(p_payload) is distinct from 'object' then
   raise exception using errcode='22023',message='invalid_payload'; end if;
 if exists(select 1 from jsonb_object_keys(p_payload) k where k not in
   ('id','name','species','sex','size','approximate_age','public_description','clinical_notes','is_vaccinated','is_neutered','care_records','last_dewormed_on','temperament')) then
   raise exception using errcode='22023',message='invalid_payload'; end if;
 if exists(select 1 from jsonb_each(p_payload) e where e.key in
   ('name','species','sex','size','approximate_age','public_description','clinical_notes') and jsonb_typeof(e.value)<>'string')
   or exists(select 1 from jsonb_each(p_payload) e where e.key in ('is_vaccinated','is_neutered') and jsonb_typeof(e.value)<>'boolean')
   or (p_payload ? 'id' and jsonb_typeof(p_payload->'id') not in ('string','null')) then
   raise exception using errcode='22023',message='invalid_payload'; end if;
 if exists(select 1 from jsonb_each(p_payload) e where e.key in ('last_dewormed_on','temperament')
   and jsonb_typeof(e.value) not in ('string','null')) then
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
 -- Omitted fields remain absent from digest and preserve data for legacy clients.
 if p_payload ? 'last_dewormed_on' then
   v_public_date_text:=nullif(btrim(p_payload->>'last_dewormed_on'),'');
   if v_public_date_text is not null then
     if v_public_date_text !~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' then
       raise exception using errcode='22023',message='invalid_payload'; end if;
     v_public_date:=v_public_date_text::date;
     if v_public_date>(current_timestamp at time zone 'America/Sao_Paulo')::date then
       raise exception using errcode='22023',message='invalid_payload'; end if;
   end if;
   v_payload:=v_payload||jsonb_build_object('last_dewormed_on',v_public_date);
 end if;
 if p_payload ? 'temperament' then
   v_temperament:=nullif(btrim(p_payload->>'temperament',E' \t\n\r'),'');
   if v_temperament is not null and char_length(v_temperament)>120 then
     raise exception using errcode='22023',message='invalid_payload'; end if;
   v_payload:=v_payload||jsonb_build_object('temperament',v_temperament);
 end if;
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
   insert into public.animals(name,species,sex,size,approximate_age,public_description,is_vaccinated,is_neutered,last_dewormed_on,temperament)
   values(v_payload->>'name',v_payload->>'species',v_payload->>'sex',v_payload->>'size',v_payload->>'approximate_age',
     v_payload->>'public_description',(v_payload->>'is_vaccinated')::boolean,(v_payload->>'is_neutered')::boolean,(v_payload->>'last_dewormed_on')::date,v_payload->>'temperament')
   returning id into v_id;
   insert into public.animal_internal_details(animal_id,created_by,updated_by) values(v_id,v_actor,v_actor);
 else
   v_id:=(v_payload->>'id')::uuid;
   perform 1 from public.animals where id=v_id for update;
   if not found then raise exception using errcode='PT404',message='not_found'; end if;
   if not private.is_staff_current() then raise exception using errcode='42501',message='staff_required'; end if;
   update public.animals set name=v_payload->>'name',species=v_payload->>'species',sex=v_payload->>'sex',size=v_payload->>'size',
     approximate_age=v_payload->>'approximate_age',public_description=v_payload->>'public_description',
     is_vaccinated=(v_payload->>'is_vaccinated')::boolean,is_neutered=(v_payload->>'is_neutered')::boolean,
     last_dewormed_on=case when v_payload ? 'last_dewormed_on' then (v_payload->>'last_dewormed_on')::date else last_dewormed_on end,
     temperament=case when v_payload ? 'temperament' then v_payload->>'temperament' else temperament end where id=v_id;
 end if;
 update public.animal_internal_details set clinical_notes=v_payload->>'clinical_notes',updated_at=now(),updated_by=v_actor where animal_id=v_id;
 delete from public.clinical_records where animal_id=v_id;
 insert into public.clinical_records(animal_id,kind,description,created_by,updated_by)
   select v_id,value->>'kind',value->>'description',v_actor,v_actor from jsonb_array_elements(v_records);
 v_result:=private.managed_animal_json(v_id);
 insert into public.write_operations(actor_id,operation_key,operation_kind,payload_digest,result)
 values(v_actor,p_operation_key,'save_animal',v_digest,v_result);
 return v_result;
exception when invalid_text_representation or sqlstate '22007' or sqlstate '22008' then
 raise exception using errcode='22023',message='invalid_payload';
end;
$$;
revoke all on function public.save_animal(text,jsonb) from public,anon;
grant execute on function public.save_animal(text,jsonb) to authenticated;
