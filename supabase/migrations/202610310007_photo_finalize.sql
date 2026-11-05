alter table public.photo_upload_jobs add column upload_token uuid not null default gen_random_uuid(),
 add column upload_expires_at timestamptz not null default (now()+interval '15 minutes'),
 add column attached_at timestamptz;
update public.photo_upload_jobs set attached_at=created_at where state='attached';
alter table public.photo_upload_jobs add constraint photo_animal_job_unique unique(animal_id,id);
alter table public.animals add constraint animal_current_photo_matches
 foreign key(id,primary_photo_id) references public.photo_upload_jobs(animal_id,id);
alter table public.photo_cleanup_queue add column lease_token uuid,add column leased_until timestamptz;

create function private.photo_job_result(p_id uuid) returns jsonb
language sql stable security definer set search_path='' as $$
 select jsonb_build_object('job_id',j.id,'state',case when j.attached_at is not null then 'attached' else j.state end,
  'photo_id',case when j.attached_at is not null then j.id else null end,
  'current_photo_id',a.primary_photo_id,'is_current',a.primary_photo_id=j.id,'correlation_id',j.id)
 from public.photo_upload_jobs j join public.animals a on a.id=j.animal_id where j.id=p_id;
$$;
revoke all on function private.photo_job_result(uuid) from public,anon,authenticated;

create function public.reserve_photo_upload(p_animal_id uuid,p_actor_id uuid,p_session_id uuid,p_operation_key text,p_digest text) returns jsonb
language plpgsql security definer set search_path='' as $$
declare j public.photo_upload_jobs%rowtype; v_id uuid:=gen_random_uuid();
begin
 if not private.is_current_staff(p_actor_id,p_session_id) then raise exception using errcode='42501',message='staff_required'; end if;
 if p_operation_key is null or p_operation_key!~'^[A-Za-z0-9_-]{32}$' or p_digest is null or p_digest!~'^[a-f0-9]{64}$' then raise exception using errcode='22023',message='invalid_job'; end if;
 perform pg_advisory_xact_lock(hashtextextended(p_actor_id::text||':'||p_operation_key,0));
 select * into j from public.photo_upload_jobs where actor_id=p_actor_id and operation_key=p_operation_key;
 if found then
  if j.animal_id<>p_animal_id or j.payload_digest<>p_digest then raise exception using errcode='PT409',message='operation_conflict'; end if;
  return to_jsonb(j)||jsonb_build_object('should_upload',false);
 end if;
 perform 1 from public.animals where id=p_animal_id;
 if not found then raise exception using errcode='PT404',message='not_found'; end if;
 insert into public.photo_upload_jobs(id,animal_id,actor_id,actor_session_id,operation_key,payload_digest,object_path)
 values(v_id,p_animal_id,p_actor_id,p_session_id,p_operation_key,p_digest,p_animal_id::text||'/'||v_id::text) returning * into j;
 return to_jsonb(j)||jsonb_build_object('should_upload',true);
end;
$$;

create function public.validate_photo_upload(p_id uuid,p_token uuid,p_mime text,p_size bigint) returns void
language plpgsql security definer set search_path='' as $$
declare j public.photo_upload_jobs%rowtype;
begin
 select * into j from public.photo_upload_jobs where id=p_id for update;
 if not found or j.upload_token<>p_token or j.state<>'pending' or j.upload_expires_at<=now()
 or p_mime not in ('image/png','image/jpeg') or p_size not between 1 and 5242880 then raise exception using errcode='22023',message='invalid_job'; end if;
 if not private.is_current_staff(j.actor_id,j.actor_session_id) then raise exception using errcode='42501',message='staff_required'; end if;
 update public.photo_upload_jobs set state='validated',detected_mime=p_mime,byte_size=p_size,updated_at=now() where id=p_id;
end;
$$;

create function public.fail_photo_upload(p_id uuid,p_token uuid) returns void
language plpgsql security definer set search_path='' as $$
begin
 perform 1 from public.photo_upload_jobs where id=p_id and upload_token=p_token and attached_at is null for update;
 if not found then return; end if;
 update public.photo_upload_jobs set state='cleanup_needed',error_code='candidate_failed',updated_at=now() where id=p_id;
 insert into public.photo_cleanup_queue(job_id,object_path,reason)
 select id,object_path,'failed_candidate' from public.photo_upload_jobs where id=p_id on conflict(job_id) do nothing;
end;
$$;

create function public.finalize_photo_upload(p_id uuid,p_actor_id uuid,p_session_id uuid,p_token uuid) returns jsonb
language plpgsql security definer set search_path='' as $$
declare j public.photo_upload_jobs%rowtype; v_animal uuid; v_previous uuid;
begin
 if not private.is_current_staff(p_actor_id,p_session_id) then raise exception using errcode='42501',message='staff_required'; end if;
 select animal_id into v_animal from public.photo_upload_jobs where id=p_id and actor_id=p_actor_id;
 if not found then raise exception using errcode='PT404',message='not_found'; end if;
 select primary_photo_id into v_previous from public.animals where id=v_animal for update;
 select * into j from public.photo_upload_jobs where id=p_id for update;
 if not private.is_current_staff(p_actor_id,p_session_id) then raise exception using errcode='42501',message='staff_required'; end if;
 if j.upload_token<>p_token then raise exception using errcode='42501',message='invalid_owner'; end if;
 if j.attached_at is not null then return private.photo_job_result(p_id); end if;
 if j.state<>'validated' or j.actor_session_id<>p_session_id or j.upload_expires_at<=now() then raise exception using errcode='22023',message='invalid_job'; end if;
 update public.photo_upload_jobs set state='attached',attached_at=now(),previous_photo_id=v_previous,updated_at=now() where id=p_id;
 update public.animals set primary_photo_id=p_id where id=v_animal;
 if v_previous is not null and v_previous<>p_id then
  update public.photo_upload_jobs set state='cleanup_needed',updated_at=now(),error_code='superseded' where id=v_previous;
  insert into public.photo_cleanup_queue(job_id,object_path,reason)
   select id,object_path,'superseded' from public.photo_upload_jobs where id=v_previous on conflict(job_id) do nothing;
 end if;
 return private.photo_job_result(p_id);
end;
$$;

create function public.get_photo_upload(p_operation_key text) returns jsonb
language plpgsql stable security definer set search_path='' as $$
begin
 if not private.is_staff_current() then raise exception using errcode='42501',message='staff_required'; end if;
 return (select private.photo_job_result(id) from public.photo_upload_jobs where actor_id=auth.uid() and operation_key=p_operation_key);
end;
$$;
revoke all on function public.get_photo_upload(text) from public,anon;
grant execute on function public.get_photo_upload(text) to authenticated;

create function public.claim_photo_cleanup() returns jsonb
language plpgsql security definer set search_path='' as $$
declare j public.photo_upload_jobs%rowtype; q record; result jsonb:='[]'; token uuid;
begin
 -- A pending/validated worker is bounded to minutes; stale jobs are terminalized
 -- before any object can be deleted. Lock order matches finalization: animal, job.
 for j in select * from public.photo_upload_jobs where state in ('pending','validated') and created_at<now()-interval '15 minutes' limit 50 loop
  perform 1 from public.animals where id=j.animal_id for update skip locked;
  if not found then continue; end if;
  perform 1 from public.photo_upload_jobs where id=j.id and state in ('pending','validated') for update skip locked;
  if not found then continue; end if;
  if exists(select 1 from public.animals where primary_photo_id=j.id) then continue; end if;
  update public.photo_upload_jobs set state='cleanup_needed',updated_at=now(),error_code='stale_candidate' where id=j.id;
  insert into public.photo_cleanup_queue(job_id,object_path,reason) values(j.id,j.object_path,'failed_candidate') on conflict(job_id) do nothing;
 end loop;
 for q in select c.job_id,c.object_path,pj.animal_id from public.photo_cleanup_queue c join public.photo_upload_jobs pj on pj.id=c.job_id
  where c.completed_at is null and c.next_attempt_at<=now() and (c.leased_until is null or c.leased_until<=now()) order by c.next_attempt_at limit 50 loop
  perform 1 from public.animals where id=q.animal_id for update skip locked;
  if not found then continue; end if;
  select * into j from public.photo_upload_jobs where id=q.job_id for update skip locked;
  if not found or j.state<>'cleanup_needed' then continue; end if;
  if exists(select 1 from public.animals where primary_photo_id=j.id) then continue; end if;
  token:=gen_random_uuid();
  update public.photo_cleanup_queue set lease_token=token,leased_until=now()+interval '5 minutes'
   where job_id=j.id and completed_at is null and (leased_until is null or leased_until<=now());
  if found then result:=result||jsonb_build_array(jsonb_build_object('job_id',j.id,'object_path',q.object_path,'lease_token',token)); end if;
 end loop;
 return result;
end;
$$;

create function public.complete_photo_cleanup(p_id uuid,p_token uuid,p_success boolean) returns void
language plpgsql security definer set search_path='' as $$
begin
 perform 1 from public.photo_cleanup_queue where job_id=p_id and lease_token=p_token and completed_at is null for update;
 if not found then return; end if;
 if p_success then
  update public.photo_upload_jobs set state='cleaned',updated_at=now() where id=p_id and state='cleanup_needed';
  update public.photo_cleanup_queue set completed_at=now(),lease_token=null,leased_until=null,last_error_code=null where job_id=p_id;
 else
  update public.photo_cleanup_queue set attempts=attempts+1,next_attempt_at=now()+least(interval '24 hours',interval '15 minutes'*power(2,least(attempts,6))),
   last_error_code='storage_remove_failed',lease_token=null,leased_until=null where job_id=p_id;
 end if;
end;
$$;

revoke all on function public.reserve_photo_upload(uuid,uuid,uuid,text,text),public.validate_photo_upload(uuid,uuid,text,bigint),
 public.fail_photo_upload(uuid,uuid),public.finalize_photo_upload(uuid,uuid,uuid,uuid),public.claim_photo_cleanup(),public.complete_photo_cleanup(uuid,uuid,boolean) from public,anon,authenticated;
grant execute on function public.reserve_photo_upload(uuid,uuid,uuid,text,text),public.validate_photo_upload(uuid,uuid,text,bigint),
 public.fail_photo_upload(uuid,uuid),public.finalize_photo_upload(uuid,uuid,uuid,uuid),public.claim_photo_cleanup(),public.complete_photo_cleanup(uuid,uuid,boolean) to service_role;

create extension if not exists pg_cron with schema pg_catalog;
create extension if not exists pg_net with schema extensions;
create function private.invoke_photo_cleanup() returns void language plpgsql security definer set search_path='' as $$
declare endpoint text; secret text;
begin
 select decrypted_secret into endpoint from vault.decrypted_secrets where name='photo_cleanup_url' limit 1;
 select decrypted_secret into secret from vault.decrypted_secrets where name='photo_cleanup_secret' limit 1;
 if endpoint is null or secret is null then return; end if;
 perform net.http_post(url:=endpoint,headers:=jsonb_build_object('Content-Type','application/json','Authorization','Bearer '||secret),body:='{}'::jsonb);
end;
$$;
revoke all on function private.invoke_photo_cleanup() from public,anon,authenticated;
select cron.schedule('animal-photo-cleanup','*/15 * * * *','select private.invoke_photo_cleanup();');
