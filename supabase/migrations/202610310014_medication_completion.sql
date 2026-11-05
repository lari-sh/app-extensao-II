-- Authenticated completion. Actor and actual time are exclusively server-owned.
create function private.medication_event_json(p_id uuid) returns jsonb
language sql stable set search_path='' as $$
 select jsonb_build_object('id',id,'application_id',application_id,'event_type',event_type,
 'actor_id',actor_id,'actor_label',actor_label,'occurred_at',occurred_at,
 'occurred_local_date',to_char(occurred_at at time zone 'America/Sao_Paulo','YYYY-MM-DD'),
 'occurred_local_time',to_char(occurred_at at time zone 'America/Sao_Paulo','HH24:MI'),
 'application_version',application_version,'reason',reason)
 from public.medication_application_events where id=p_id;
$$;
revoke all on function private.medication_event_json(uuid) from public,anon,authenticated;

create function public.complete_medication_application(p_operation_key text,p_application_id uuid,p_expected_version integer) returns jsonb
language plpgsql security definer set search_path='' set timezone='UTC' as $$
declare v_actor uuid; v_digest text; v_existing private.medication_operations%rowtype;
 v_treatment uuid;v_animal uuid;v_application public.medication_applications%rowtype;
 v_now timestamptz;v_label text;v_event uuid;v_result jsonb;
begin
 if not private.medication_staff_current() then raise exception 'staff_required' using errcode='42501';end if;
 if p_operation_key is null or p_operation_key !~ '^[A-Za-z0-9_-]{32}$' or p_application_id is null
 or p_expected_version is null or p_expected_version<1 then raise exception 'invalid_payload' using errcode='22023';end if;
 v_actor:=auth.uid();v_digest:=encode(extensions.digest(jsonb_build_object('application_id',p_application_id,'expected_version',p_expected_version)::text,'sha256'),'hex');
 perform pg_advisory_xact_lock(hashtextextended('medication:'||v_actor::text||':'||p_operation_key,0));
 if not private.medication_staff_current() then raise exception 'staff_required' using errcode='42501';end if;
 select * into v_existing from private.medication_operations where actor_id=v_actor and operation_key=p_operation_key;
 if found then
  if v_existing.operation_kind<>'complete_application' or v_existing.payload_digest<>v_digest then raise exception 'operation_conflict' using errcode='PT409';end if;
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
 if v_application.state<>'pending' then raise exception 'already_completed_or_cancelled' using errcode='PT409';end if;
 if v_application.scheduled_at>v_now then raise exception 'not_due' using errcode='PT409';end if;
 select coalesce(display_name,'Funcionário '||v_actor::text) into v_label from public.staff_members where user_id=v_actor;
 update public.medication_applications set state='completed',version=version+1,performed_by=v_actor,performed_at=v_now where id=p_application_id;
 insert into public.medication_application_events(application_id,event_type,actor_id,actor_label,occurred_at,application_version,snapshot)
 values(p_application_id,'completed',v_actor,v_label,v_now,v_application.version+1,
 jsonb_build_object('previous_state',v_application.state,'scheduled_at',v_application.scheduled_at,'revision',v_application.revision,'performed_by',v_actor,'performed_at',v_now)) returning id into v_event;
 update private.medication_agenda_state set agenda_version=agenda_version+1 where singleton;
 v_result:=jsonb_build_object('operation_key',p_operation_key,'server_now',v_now,'result',jsonb_build_object('application',private.medication_application_json(p_application_id),'event',private.medication_event_json(v_event)));
 insert into private.medication_operations(actor_id,operation_key,operation_kind,payload_digest,result,created_at)
 values(v_actor,p_operation_key,'complete_application',v_digest,v_result,v_now);
 return v_result;
end;$$;
revoke all on function public.complete_medication_application(text,uuid,integer) from public,anon,authenticated;
grant execute on function public.complete_medication_application(text,uuid,integer) to authenticated;
