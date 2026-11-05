-- Finite treatment creation and reconciliation. Revision changes are added in 015.
create function private.medication_staff_current() returns boolean
language plpgsql security definer set search_path='' as $$
begin
 if not private.is_staff_current() then return false; end if;
 if auth.jwt()->>'exp' is not null and (auth.jwt()->>'exp')::numeric<=extract(epoch from clock_timestamp()) then return false; end if;
 return exists(select 1 from auth.sessions s join public.staff_members m on m.user_id=s.user_id
 where s.id=(auth.jwt()->>'session_id')::uuid and s.user_id=auth.uid() and m.active
 and (s.not_after is null or s.not_after>clock_timestamp()));
exception when others then return false;
end;$$;
revoke all on function private.medication_staff_current() from public,anon;
grant execute on function private.medication_staff_current() to authenticated,service_role;
alter policy medication_staff_read on public.medication_treatments using (private.medication_staff_current());
alter policy medication_revision_staff_read on public.medication_treatment_revisions using (private.medication_staff_current());
alter policy medication_application_staff_read on public.medication_applications using (private.medication_staff_current());

create function private.medication_resolve_local(p_local timestamp) returns timestamptz
language plpgsql stable set search_path='' as $$
declare v_values timestamptz[];
begin
 if p_local is null or p_local::date not between date '2000-01-01' and date '2100-12-31' then raise exception using errcode='22023',message='invalid_payload'; end if;
 select array_agg(candidate) into v_values from (
 select (p_local at time zone 'UTC')+make_interval(mins=>n) as candidate from generate_series(-840,840) n
 ) candidates where candidate at time zone 'America/Sao_Paulo'=p_local;
 if cardinality(v_values) is distinct from 1 then raise exception using errcode='22023',message='invalid_payload'; end if;
 return v_values[1];
end;$$;
revoke all on function private.medication_resolve_local(timestamp) from public,anon,authenticated;

create function private.medication_occurrences(p_mode text,p_start timestamptz,p_end timestamptz,p_times text[],p_interval integer)
returns timestamptz[] language plpgsql stable set search_path='' as $$
declare v_result timestamptz[]:='{}';v_date date;v_time text;v_instant timestamptz;v_count numeric;
begin
 if p_mode='interval' then
  v_count:=floor(extract(epoch from (p_end-p_start))/(p_interval*60))+1;
  if v_count not between 1 and 10000 then raise exception using errcode='22023',message='invalid_payload'; end if;
  select array_agg(g order by g) into v_result from generate_series(p_start,p_end,make_interval(mins=>p_interval)) g;
 else
  for v_date in select g::date from generate_series((p_start at time zone 'America/Sao_Paulo')::date::timestamp,(p_end at time zone 'America/Sao_Paulo')::date::timestamp,interval '1 day') g loop
   foreach v_time in array p_times loop
    v_instant:=private.medication_resolve_local(v_date+v_time::time);
    if v_instant>=p_start and v_instant<=p_end then v_result:=array_append(v_result,v_instant);end if;
   end loop;
  end loop;
  if cardinality(v_result) not between 1 and 10000 then raise exception using errcode='22023',message='invalid_payload'; end if;
 end if;
 return v_result;
end;$$;
revoke all on function private.medication_occurrences(text,timestamptz,timestamptz,text[],integer) from public,anon,authenticated;

create function private.medication_treatment_json(p_id uuid) returns jsonb
language sql stable security definer set search_path='' as $$
 select jsonb_build_object('id',t.id,'animal_id',t.animal_id,'revision',t.current_revision,'version',t.treatment_version,
 'status',t.status,'medication_name',r.medication_name,'instructions',r.instructions,'timezone',r.timezone,
 'schedule_mode',r.schedule_mode,'starts_on',to_char(r.starts_at at time zone r.timezone,'YYYY-MM-DD'),
 'starts_time',to_char(r.starts_at at time zone r.timezone,'HH24:MI'),'ends_on',to_char(r.ends_at at time zone r.timezone,'YYYY-MM-DD'),
 'ends_time',to_char(r.ends_at at time zone r.timezone,'HH24:MI'),'fixed_times',to_jsonb(r.fixed_times),'interval_minutes',r.interval_minutes)
 from public.medication_treatments t join public.medication_treatment_revisions r on r.treatment_id=t.id and r.revision=t.current_revision where t.id=p_id;
$$;
revoke all on function private.medication_treatment_json(uuid) from public,anon,authenticated;

create function private.medication_normalize_payload(p jsonb) returns jsonb
language plpgsql stable set search_path='' as $$
declare v_times text[];v_start timestamptz;v_end timestamptz;v_interval integer;v_name text;v_instructions text;v_mode text;
begin
 if jsonb_typeof(p) is distinct from 'object' then raise exception using errcode='22023',message='invalid_payload';end if;
 if exists(select 1 from jsonb_object_keys(p) k where k not in ('treatment_id','animal_id','expected_revision','expected_treatment_version','medication_name','instructions','schedule_mode','starts_on','starts_time','ends_on','ends_time','fixed_times','interval_minutes')) then raise exception using errcode='22023',message='invalid_payload';end if;
 if exists(select 1 from unnest(array['animal_id','medication_name','schedule_mode','starts_on','starts_time','ends_on','ends_time']) k where jsonb_typeof(p->k) is distinct from 'string') then raise exception using errcode='22023',message='invalid_payload';end if;
 if p ? 'instructions' and jsonb_typeof(p->'instructions') not in ('string','null') then raise exception using errcode='22023',message='invalid_payload';end if;
 if p->>'starts_on' !~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' or p->>'ends_on' !~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
 or p->>'starts_time' !~ '^([01][0-9]|2[0-3]):[0-5][0-9]$' or p->>'ends_time' !~ '^([01][0-9]|2[0-3]):[0-5][0-9]$' then raise exception using errcode='22023',message='invalid_payload';end if;
 if (p->>'ends_on')::date-(p->>'starts_on')::date not between 0 and 365 then raise exception using errcode='22023',message='invalid_payload';end if;
 v_name:=btrim(p->>'medication_name',E' \t\n\r');v_instructions:=coalesce(p->>'instructions','');v_mode:=p->>'schedule_mode';
 if char_length(v_name) not between 1 and 120 or char_length(v_instructions)>1000 or v_mode not in ('fixed_times','interval') then raise exception using errcode='22023',message='invalid_payload';end if;
 v_start:=private.medication_resolve_local((p->>'starts_on')::date+(p->>'starts_time')::time);
 v_end:=private.medication_resolve_local((p->>'ends_on')::date+(p->>'ends_time')::time);
 if v_end<=v_start then raise exception using errcode='22023',message='invalid_payload';end if;
 if p ? 'fixed_times' and jsonb_typeof(p->'fixed_times') is distinct from 'array' then raise exception using errcode='22023',message='invalid_payload';end if;
 if exists(select 1 from jsonb_array_elements(coalesce(p->'fixed_times','[]')) v where jsonb_typeof(v)<>'string') then raise exception using errcode='22023',message='invalid_payload';end if;
 select coalesce(array_agg(value order by value),'{}') into v_times from jsonb_array_elements_text(coalesce(p->'fixed_times','[]'));
 if v_mode='fixed_times' then
  if not private.medication_times_valid(v_times) or (p->>'interval_minutes') is not null then raise exception using errcode='22023',message='invalid_payload';end if;
 else
  if cardinality(v_times)<>0 or jsonb_typeof(p->'interval_minutes') is distinct from 'number' or p->>'interval_minutes' !~ '^[0-9]+$' then raise exception using errcode='22023',message='invalid_payload';end if;
  v_interval:=(p->>'interval_minutes')::integer;
  if v_interval not between 1 and 10080 then raise exception using errcode='22023',message='invalid_payload';end if;
 end if;
 if p->>'treatment_id' is not null and jsonb_typeof(p->'treatment_id')<>'string' then raise exception using errcode='22023',message='invalid_payload';end if;
 if exists(select 1 from jsonb_each(p) e where e.key in ('expected_revision','expected_treatment_version') and jsonb_typeof(e.value) not in ('number','null')) then raise exception using errcode='22023',message='invalid_payload';end if;
 return jsonb_build_object('treatment_id',(p->>'treatment_id')::uuid,'animal_id',(p->>'animal_id')::uuid,
 'expected_revision',p->'expected_revision','expected_treatment_version',p->'expected_treatment_version',
 'medication_name',v_name,'instructions',v_instructions,'schedule_mode',v_mode,'starts_at',v_start,'ends_at',v_end,'fixed_times',to_jsonb(v_times),'interval_minutes',v_interval);
exception when invalid_text_representation or numeric_value_out_of_range or sqlstate '22007' or sqlstate '22008' then
 raise exception using errcode='22023',message='invalid_payload';
end;$$;
revoke all on function private.medication_normalize_payload(jsonb) from public,anon,authenticated;

create function public.save_medication_treatment(p_operation_key text,p_payload jsonb) returns jsonb
language plpgsql security definer set search_path='' set timezone='UTC' as $$
declare v_actor uuid;v_data jsonb;v_digest text;v_existing private.medication_operations%rowtype;v_id uuid;v_now timestamptz;v_times text[];v_instants timestamptz[];v_result jsonb;
begin
 if not private.medication_staff_current() then raise exception using errcode='42501',message='staff_required';end if;
 if p_operation_key is null or p_operation_key !~ '^[A-Za-z0-9_-]{32}$' then raise exception using errcode='22023',message='invalid_payload';end if;
 v_actor:=auth.uid();v_data:=private.medication_normalize_payload(p_payload);v_digest:=encode(extensions.digest(v_data::text,'sha256'),'hex');
 perform pg_advisory_xact_lock(hashtextextended('medication:'||v_actor::text||':'||p_operation_key,0));
 if not private.medication_staff_current() then raise exception using errcode='42501',message='staff_required';end if;
 select * into v_existing from private.medication_operations where actor_id=v_actor and operation_key=p_operation_key;
 if found then
  if v_existing.operation_kind<>'save_treatment' or v_existing.payload_digest<>v_digest then raise exception using errcode='PT409',message='operation_conflict';end if;
  return v_existing.result;
 end if;
 if v_data->>'treatment_id' is not null or v_data->>'expected_revision' is not null or v_data->>'expected_treatment_version' is not null then raise exception using errcode='22023',message='invalid_payload';end if;
 perform 1 from public.animals where id=(v_data->>'animal_id')::uuid for update;
 if not found then raise exception using errcode='PT404',message='not_found';end if;
 select array_agg(value order by value) into v_times from jsonb_array_elements_text(v_data->'fixed_times');
 v_times:=coalesce(v_times,'{}');
 v_instants:=private.medication_occurrences(v_data->>'schedule_mode',(v_data->>'starts_at')::timestamptz,(v_data->>'ends_at')::timestamptz,v_times,(v_data->>'interval_minutes')::integer);
 if not private.medication_staff_current() then raise exception using errcode='42501',message='staff_required';end if;
 v_now:=clock_timestamp();
 insert into public.medication_treatments(animal_id,created_by,updated_by,created_at,updated_at) values((v_data->>'animal_id')::uuid,v_actor,v_actor,v_now,v_now) returning id into v_id;
 insert into public.medication_treatment_revisions(treatment_id,revision,medication_name,instructions,schedule_mode,starts_at,ends_at,fixed_times,interval_minutes,created_by,created_at)
 values(v_id,1,v_data->>'medication_name',v_data->>'instructions',v_data->>'schedule_mode',(v_data->>'starts_at')::timestamptz,(v_data->>'ends_at')::timestamptz,v_times,(v_data->>'interval_minutes')::integer,v_actor,v_now);
 insert into public.medication_applications(treatment_id,revision,scheduled_at) select v_id,1,g from unnest(v_instants) g;
 update private.medication_agenda_state set agenda_version=agenda_version+1 where singleton;
 v_result:=jsonb_build_object('operation_key',p_operation_key,'server_now',v_now,'result',jsonb_build_object('treatment',private.medication_treatment_json(v_id)));
 insert into private.medication_operations(actor_id,operation_key,operation_kind,payload_digest,result,created_at) values(v_actor,p_operation_key,'save_treatment',v_digest,v_result,v_now);
 return v_result;
end;$$;
revoke all on function public.save_medication_treatment(text,jsonb) from public,anon;
grant execute on function public.save_medication_treatment(text,jsonb) to authenticated;

create function public.get_medication_operation(p_operation_key text) returns jsonb
language plpgsql stable security definer set search_path='' as $$
declare v_result jsonb;
begin
 if not private.medication_staff_current() then raise exception using errcode='42501',message='staff_required';end if;
 if p_operation_key is null or p_operation_key !~ '^[A-Za-z0-9_-]{32}$' then raise exception using errcode='22023',message='invalid_payload';end if;
 select result into v_result from private.medication_operations where actor_id=auth.uid() and operation_key=p_operation_key;
 return v_result;
end;$$;
revoke all on function public.get_medication_operation(text) from public,anon;
grant execute on function public.get_medication_operation(text) to authenticated;

create function public.list_animal_medication_treatments(p_animal_id uuid,p_cursor text default null) returns jsonb
language plpgsql stable security definer set search_path='' as $$
declare v_cursor jsonb;v_after timestamptz;v_after_id uuid;v_rows jsonb;v_next text;v_last record;v_total integer;
begin
 if not private.medication_staff_current() then raise exception using errcode='42501',message='staff_required';end if;
 if p_animal_id is null then raise exception using errcode='22023',message='invalid_payload';end if;
 if p_cursor is not null then
  if octet_length(p_cursor)>1024 then raise exception using errcode='22023',message='invalid_payload';end if;
  v_cursor:=convert_from(decode(p_cursor,'base64'),'UTF8')::jsonb;
  if jsonb_typeof(v_cursor)<>'object' or v_cursor->>'animal_id' is distinct from p_animal_id::text or v_cursor->>'actor_id' is distinct from auth.uid()::text then raise exception using errcode='22023',message='invalid_payload';end if;
  v_after:=(v_cursor->>'created_at')::timestamptz;v_after_id:=(v_cursor->>'id')::uuid;
  if v_after is null or v_after_id is null then raise exception using errcode='22023',message='invalid_payload';end if;
 end if;
 select coalesce(jsonb_agg(private.medication_treatment_json(id) order by created_at,id),'[]') into v_rows from
 (select id,created_at from public.medication_treatments where animal_id=p_animal_id and (v_after is null or (created_at,id)>(v_after,v_after_id)) order by created_at,id limit 50) page;
 if jsonb_array_length(v_rows)=50 then
  select created_at,id into v_last from public.medication_treatments where id=(v_rows->49->>'id')::uuid;
  if exists(select 1 from public.medication_treatments where animal_id=p_animal_id and (created_at,id)>(v_last.created_at,v_last.id)) then
   v_next:=encode(convert_to(jsonb_build_object('animal_id',p_animal_id,'actor_id',auth.uid(),'created_at',v_last.created_at,'id',v_last.id)::text,'UTF8'),'base64');
  end if;
 end if;
 return jsonb_build_object('items',v_rows,'next_cursor',v_next);
exception when invalid_text_representation or sqlstate '22007' or sqlstate '22008' then raise exception using errcode='22023',message='invalid_payload';
end;$$;
revoke all on function public.list_animal_medication_treatments(uuid,text) from public,anon;
grant execute on function public.list_animal_medication_treatments(uuid,text) to authenticated;
