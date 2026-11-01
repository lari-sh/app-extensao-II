-- Revision/stop/reversal preserve past applications and append-only event history.
create function private.medication_cancel_future(p_treatment uuid,p_cut timestamptz,p_reason text,p_actor uuid) returns integer
language plpgsql set search_path='' as $$
declare a record;v_count integer:=0;v_label text;
begin
 select coalesce(display_name,'Funcionário '||p_actor::text) into v_label from public.staff_members where user_id=p_actor;
 for a in select * from public.medication_applications where treatment_id=p_treatment and state='pending' and scheduled_at>p_cut order by id loop
  update public.medication_applications set state='cancelled',version=version+1,cancelled_at=p_cut,cancelled_reason=p_reason where id=a.id;
  insert into public.medication_application_events(application_id,event_type,actor_id,actor_label,occurred_at,reason,application_version,snapshot)
  values(a.id,'cancelled',p_actor,v_label,p_cut,p_reason,a.version+1,jsonb_build_object('scheduled_at',a.scheduled_at,'revision',a.revision,'previous_state',a.state));
  v_count:=v_count+1;
 end loop;
 return v_count;
end;$$;
revoke all on function private.medication_cancel_future(uuid,timestamptz,text,uuid) from public,anon,authenticated;

create or replace function public.save_medication_treatment(p_operation_key text,p_payload jsonb) returns jsonb
language plpgsql security definer set search_path='' set timezone='UTC' as $$
declare v_actor uuid;v_data jsonb;v_digest text;v_existing private.medication_operations%rowtype;
 v_id uuid;v_now timestamptz;v_times text[];v_instants timestamptz[];v_result jsonb;
 v_treatment public.medication_treatments%rowtype;v_revision integer;v_cancelled integer:=0;
begin
 if not private.medication_staff_current() then raise exception 'staff_required' using errcode='42501';end if;
 if p_operation_key is null or p_operation_key !~ '^[A-Za-z0-9_-]{32}$' then raise exception 'invalid_payload' using errcode='22023';end if;
 v_actor:=auth.uid();v_data:=private.medication_normalize_payload(p_payload);v_digest:=encode(extensions.digest(v_data::text,'sha256'),'hex');
 perform pg_advisory_xact_lock(hashtextextended('medication:'||v_actor::text||':'||p_operation_key,0));
 if not private.medication_staff_current() then raise exception 'staff_required' using errcode='42501';end if;
 select * into v_existing from private.medication_operations where actor_id=v_actor and operation_key=p_operation_key;
 if found then
  if v_existing.operation_kind<>'save_treatment' or v_existing.payload_digest<>v_digest then raise exception 'operation_conflict' using errcode='PT409';end if;
  return v_existing.result;
 end if;
 v_id:=(v_data->>'treatment_id')::uuid;
 if v_id is null and (v_data->>'expected_revision' is not null or v_data->>'expected_treatment_version' is not null) then raise exception 'invalid_payload' using errcode='22023';end if;
 if v_id is not null and (v_data->>'expected_revision' is null or v_data->>'expected_treatment_version' is null
 or v_data->>'expected_revision' !~ '^[1-9][0-9]*$' or v_data->>'expected_treatment_version' !~ '^[1-9][0-9]*$') then raise exception 'invalid_payload' using errcode='22023';end if;
 perform 1 from public.animals where id=(v_data->>'animal_id')::uuid for update;
 if not found then raise exception 'not_found' using errcode='PT404';end if;
 if v_id is not null then
  select * into v_treatment from public.medication_treatments where id=v_id and animal_id=(v_data->>'animal_id')::uuid for update;
  if not found then raise exception 'not_found' using errcode='PT404';end if;
  perform 1 from public.medication_applications where treatment_id=v_id and state='pending' order by id for update;
 end if;
 select coalesce(array_agg(value order by value),'{}') into v_times from jsonb_array_elements_text(v_data->'fixed_times');
 v_instants:=private.medication_occurrences(v_data->>'schedule_mode',(v_data->>'starts_at')::timestamptz,(v_data->>'ends_at')::timestamptz,v_times,(v_data->>'interval_minutes')::integer);
 perform 1 from private.medication_agenda_state where singleton for update;
 if not private.medication_staff_current() then raise exception 'staff_required' using errcode='42501';end if;
 v_now:=clock_timestamp();
 if v_id is null then
  v_revision:=1;
  insert into public.medication_treatments(animal_id,created_by,updated_by,created_at,updated_at)
  values((v_data->>'animal_id')::uuid,v_actor,v_actor,v_now,v_now) returning id into v_id;
 else
  if v_treatment.status='stopped' then raise exception 'treatment_stopped' using errcode='PT409';end if;
  if v_treatment.current_revision<>(v_data->>'expected_revision')::integer or v_treatment.treatment_version<>(v_data->>'expected_treatment_version')::integer then raise exception 'stale_version' using errcode='PT409';end if;
  v_revision:=v_treatment.current_revision+1;
  v_cancelled:=private.medication_cancel_future(v_id,v_now,'treatment_changed',v_actor);
  update public.medication_treatments set current_revision=v_revision,treatment_version=treatment_version+1,updated_by=v_actor,updated_at=v_now where id=v_id;
 end if;
 insert into public.medication_treatment_revisions(treatment_id,revision,medication_name,instructions,schedule_mode,starts_at,ends_at,fixed_times,interval_minutes,created_by,created_at)
 values(v_id,v_revision,v_data->>'medication_name',v_data->>'instructions',v_data->>'schedule_mode',(v_data->>'starts_at')::timestamptz,(v_data->>'ends_at')::timestamptz,v_times,(v_data->>'interval_minutes')::integer,v_actor,v_now);
 insert into public.medication_applications(treatment_id,revision,scheduled_at)
 select v_id,v_revision,g from unnest(v_instants) g where v_revision=1 or g>v_now;
 update private.medication_agenda_state set agenda_version=agenda_version+1 where singleton;
 v_result:=jsonb_build_object('operation_key',p_operation_key,'server_now',v_now,'result',jsonb_build_object('treatment',private.medication_treatment_json(v_id),'cancelled_count',v_cancelled));
 insert into private.medication_operations(actor_id,operation_key,operation_kind,payload_digest,result,created_at) values(v_actor,p_operation_key,'save_treatment',v_digest,v_result,v_now);
 return v_result;
exception when numeric_value_out_of_range then raise exception 'invalid_payload' using errcode='22023';
end;$$;

create function public.stop_medication_treatment(p_operation_key text,p_treatment_id uuid,p_expected_revision integer,p_expected_treatment_version integer) returns jsonb
language plpgsql security definer set search_path='' set timezone='UTC' as $$
declare v_actor uuid;v_digest text;v_existing private.medication_operations%rowtype;v_animal uuid;
 v_treatment public.medication_treatments%rowtype;v_now timestamptz;v_cancelled integer:=0;v_result jsonb;
begin
 if not private.medication_staff_current() then raise exception 'staff_required' using errcode='42501';end if;
 if p_operation_key is null or p_operation_key !~ '^[A-Za-z0-9_-]{32}$' or p_treatment_id is null or p_expected_revision is null or p_expected_revision<1 or p_expected_treatment_version is null or p_expected_treatment_version<1 then raise exception 'invalid_payload' using errcode='22023';end if;
 v_actor:=auth.uid();v_digest:=encode(extensions.digest(jsonb_build_object('treatment_id',p_treatment_id,'expected_revision',p_expected_revision,'expected_treatment_version',p_expected_treatment_version)::text,'sha256'),'hex');
 perform pg_advisory_xact_lock(hashtextextended('medication:'||v_actor::text||':'||p_operation_key,0));
 if not private.medication_staff_current() then raise exception 'staff_required' using errcode='42501';end if;
 select * into v_existing from private.medication_operations where actor_id=v_actor and operation_key=p_operation_key;
 if found then
  if v_existing.operation_kind<>'stop_treatment' or v_existing.payload_digest<>v_digest then raise exception 'operation_conflict' using errcode='PT409';end if;
  return v_existing.result;
 end if;
 select animal_id into v_animal from public.medication_treatments where id=p_treatment_id;
 if not found then raise exception 'not_found' using errcode='PT404';end if;
 perform 1 from public.animals where id=v_animal for update;
 select * into v_treatment from public.medication_treatments where id=p_treatment_id for update;
 perform 1 from public.medication_applications where treatment_id=p_treatment_id and state='pending' order by id for update;
 perform 1 from private.medication_agenda_state where singleton for update;
 if not private.medication_staff_current() then raise exception 'staff_required' using errcode='42501';end if;
 v_now:=clock_timestamp();
 if v_treatment.current_revision<>p_expected_revision or v_treatment.treatment_version<>p_expected_treatment_version then raise exception 'stale_version' using errcode='PT409';end if;
 if v_treatment.status='active' then
  v_cancelled:=private.medication_cancel_future(p_treatment_id,v_now,'treatment_stopped',v_actor);
  update public.medication_treatments set status='stopped',stopped_at=v_now,treatment_version=treatment_version+1,updated_by=v_actor,updated_at=v_now where id=p_treatment_id;
  update private.medication_agenda_state set agenda_version=agenda_version+1 where singleton;
 end if;
 v_result:=jsonb_build_object('operation_key',p_operation_key,'server_now',v_now,'result',jsonb_build_object('treatment',private.medication_treatment_json(p_treatment_id),'cancelled_count',v_cancelled));
 insert into private.medication_operations(actor_id,operation_key,operation_kind,payload_digest,result,created_at) values(v_actor,p_operation_key,'stop_treatment',v_digest,v_result,v_now);
 return v_result;
end;$$;

create function public.reverse_medication_completion(p_operation_key text,p_application_id uuid,p_expected_version integer,p_reason text) returns jsonb
language plpgsql security definer set search_path='' set timezone='UTC' as $$
declare v_actor uuid;v_digest text;v_existing private.medication_operations%rowtype;v_treatment uuid;v_animal uuid;
 v_application public.medication_applications%rowtype;v_now timestamptz;v_reason text;v_label text;v_event uuid;v_snapshot jsonb;v_result jsonb;
begin
 if not private.medication_staff_current() then raise exception 'staff_required' using errcode='42501';end if;
 v_reason:=btrim(p_reason,E' \t\n\r');
 if p_operation_key is null or p_operation_key !~ '^[A-Za-z0-9_-]{32}$' or p_application_id is null or p_expected_version is null or p_expected_version<1 or v_reason is null or char_length(v_reason) not between 1 and 500 then raise exception 'invalid_payload' using errcode='22023';end if;
 v_actor:=auth.uid();v_digest:=encode(extensions.digest(jsonb_build_object('application_id',p_application_id,'expected_version',p_expected_version,'reason',v_reason)::text,'sha256'),'hex');
 perform pg_advisory_xact_lock(hashtextextended('medication:'||v_actor::text||':'||p_operation_key,0));
 if not private.medication_staff_current() then raise exception 'staff_required' using errcode='42501';end if;
 select * into v_existing from private.medication_operations where actor_id=v_actor and operation_key=p_operation_key;
 if found then
  if v_existing.operation_kind<>'reverse_completion' or v_existing.payload_digest<>v_digest then raise exception 'operation_conflict' using errcode='PT409';end if;
  return v_existing.result;
 end if;
 select a.treatment_id,t.animal_id into v_treatment,v_animal from public.medication_applications a join public.medication_treatments t on t.id=a.treatment_id where a.id=p_application_id;
 if not found then raise exception 'not_found' using errcode='PT404';end if;
 perform 1 from public.animals where id=v_animal for update;
 perform 1 from public.medication_treatments where id=v_treatment for update;
 select * into v_application from public.medication_applications where id=p_application_id for update;
 perform 1 from private.medication_agenda_state where singleton for update;
 if not private.medication_staff_current() then raise exception 'staff_required' using errcode='42501';end if;
 v_now:=clock_timestamp();
 if v_application.version<>p_expected_version then raise exception 'stale_version' using errcode='PT409';end if;
 if v_application.state<>'completed' then raise exception 'not_completed' using errcode='PT409';end if;
 v_snapshot:=private.medication_application_json(p_application_id);
 select coalesce(display_name,'Funcionário '||v_actor::text) into v_label from public.staff_members where user_id=v_actor;
 update public.medication_applications set state='pending',version=version+1,performed_by=null,performed_at=null where id=p_application_id;
 insert into public.medication_application_events(application_id,event_type,actor_id,actor_label,occurred_at,reason,application_version,snapshot)
 values(p_application_id,'completion_reversed',v_actor,v_label,v_now,v_reason,v_application.version+1,v_snapshot) returning id into v_event;
 update private.medication_agenda_state set agenda_version=agenda_version+1 where singleton;
 v_result:=jsonb_build_object('operation_key',p_operation_key,'server_now',v_now,'result',jsonb_build_object('application',private.medication_application_json(p_application_id),'event',private.medication_event_json(v_event)));
 insert into private.medication_operations(actor_id,operation_key,operation_kind,payload_digest,result,created_at) values(v_actor,p_operation_key,'reverse_completion',v_digest,v_result,v_now);
 return v_result;
end;$$;
revoke all on function public.save_medication_treatment(text,jsonb),public.stop_medication_treatment(text,uuid,integer,integer),public.reverse_medication_completion(text,uuid,integer,text) from public,anon,authenticated;
grant execute on function public.save_medication_treatment(text,jsonb),public.stop_medication_treatment(text,uuid,integer,integer),public.reverse_medication_completion(text,uuid,integer,text) to authenticated;
