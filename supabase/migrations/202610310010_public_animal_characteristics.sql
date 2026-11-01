-- Public vaccination entries deliberately contain only application date and type.
alter table public.animals add column weight_kg numeric,
 add column color text,
 add column vaccinations jsonb not null default '[]'::jsonb,
 add constraint animals_public_weight check (weight_kg is null or (weight_kg>0 and weight_kg<=1000)),
 add constraint animals_public_color check (color is null or (color=btrim(color,E' \t\n\r') and char_length(color) between 1 and 80)),
 add constraint animals_public_vaccinations check (jsonb_typeof(vaccinations)='array' and jsonb_array_length(vaccinations)<=100);
comment on column public.animals.vaccinations is 'Public application date and vaccine type only; private care records remain separate.';
create or replace function public.save_animal(p_operation_key text,p_payload jsonb) returns jsonb
language plpgsql security definer set search_path='' as $$
declare
 v_payload jsonb; v_records jsonb; v_record jsonb; v_id uuid; v_actor uuid;
 v_digest text; v_existing public.write_operations%rowtype; v_result jsonb;
 v_vaccination jsonb; v_vaccinations jsonb; v_weight numeric; v_color text; v_public_date_text text; v_public_date date; v_temperament text;
begin
 if not private.is_staff_current() then raise exception using errcode='42501',message='staff_required'; end if;
 v_actor:=auth.uid();
 if p_operation_key is null or p_operation_key !~ '^[A-Za-z0-9_-]{32}$' or jsonb_typeof(p_payload) is distinct from 'object' then
   raise exception using errcode='22023',message='invalid_payload'; end if;
 if exists(select 1 from jsonb_object_keys(p_payload) k where k not in
   ('id','name','species','sex','size','approximate_age','public_description','clinical_notes','is_vaccinated','is_neutered','care_records','last_dewormed_on','temperament','weight_kg','color','vaccinations')) then
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
 if p_payload ? 'weight_kg' then
   if jsonb_typeof(p_payload->'weight_kg') not in ('number','null') then
     raise exception using errcode='22023',message='invalid_payload'; end if;
   v_weight:=(p_payload->>'weight_kg')::numeric;
   if v_weight<=0 or v_weight>1000 then raise exception using errcode='22023',message='invalid_payload'; end if;
   v_payload:=v_payload||jsonb_build_object('weight_kg',v_weight);
 end if;
 if p_payload ? 'color' then
   if jsonb_typeof(p_payload->'color') not in ('string','null') then
     raise exception using errcode='22023',message='invalid_payload'; end if;
   v_color:=nullif(btrim(p_payload->>'color',E' \t\n\r'),'');
   if char_length(v_color)>80 then raise exception using errcode='22023',message='invalid_payload'; end if;
   v_payload:=v_payload||jsonb_build_object('color',v_color);
 end if;
 if p_payload ? 'vaccinations' then
   if jsonb_typeof(p_payload->'vaccinations')<>'array' or jsonb_array_length(p_payload->'vaccinations')>100 then
     raise exception using errcode='22023',message='invalid_payload'; end if;
   v_vaccinations:='[]'::jsonb;
   for v_vaccination in select value from jsonb_array_elements(p_payload->'vaccinations') loop
     if jsonb_typeof(v_vaccination)<>'object' then raise exception using errcode='22023',message='invalid_payload'; end if;
     if exists(select 1 from jsonb_object_keys(v_vaccination) k where k not in ('applied_on','vaccine_type'))
       or jsonb_typeof(v_vaccination->'applied_on') is distinct from 'string'
       or jsonb_typeof(v_vaccination->'vaccine_type') is distinct from 'string'
       or char_length(btrim(v_vaccination->>'vaccine_type')) not between 1 and 120
       or (v_vaccination->>'applied_on') !~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' then
       raise exception using errcode='22023',message='invalid_payload'; end if;
     v_public_date:=(v_vaccination->>'applied_on')::date;
     if v_public_date>(current_timestamp at time zone 'America/Sao_Paulo')::date then
       raise exception using errcode='22023',message='invalid_payload'; end if;
     v_vaccinations:=v_vaccinations||jsonb_build_array(jsonb_build_object('applied_on',v_public_date,'vaccine_type',btrim(v_vaccination->>'vaccine_type')));
   end loop;
   v_payload:=v_payload||jsonb_build_object('vaccinations',v_vaccinations);
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
   insert into public.animals(name,species,sex,size,approximate_age,public_description,is_vaccinated,is_neutered,last_dewormed_on,temperament,weight_kg,color,vaccinations)
   values(v_payload->>'name',v_payload->>'species',v_payload->>'sex',v_payload->>'size',v_payload->>'approximate_age',
     v_payload->>'public_description',(v_payload->>'is_vaccinated')::boolean,(v_payload->>'is_neutered')::boolean,(v_payload->>'last_dewormed_on')::date,v_payload->>'temperament',(v_payload->>'weight_kg')::numeric,v_payload->>'color',coalesce(v_payload->'vaccinations','[]'::jsonb))
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
     temperament=case when v_payload ? 'temperament' then v_payload->>'temperament' else temperament end,
     weight_kg=case when v_payload ? 'weight_kg' then (v_payload->>'weight_kg')::numeric else weight_kg end,
     color=case when v_payload ? 'color' then v_payload->>'color' else color end,
     vaccinations=case when v_payload ? 'vaccinations' then v_payload->'vaccinations' else vaccinations end where id=v_id;
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
