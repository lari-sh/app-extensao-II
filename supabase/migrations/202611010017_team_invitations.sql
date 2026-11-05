-- Durable invitation sends and recipient-only acceptance. Admin Auth stays server-side.
alter table private.team_invitations
 add column generation_started_at timestamptz,
 add column send_started_at timestamptz,
 add column password_fingerprint text,
 add column delivery_state text not null default 'sending'
  check(delivery_state in ('sending','sent','uncertain','failed'));
update private.team_invitations set generation_started_at=created_at,send_started_at=created_at;
update private.team_invitations i set password_fingerprint=encode(extensions.digest(coalesce(u.encrypted_password,''),'sha256'),'hex')
 from auth.users u where u.id=i.invited_auth_user_id;
alter table private.team_invitations alter column generation_started_at set not null;
alter table private.team_invitations alter column generation_started_at set default clock_timestamp();
alter table private.team_operations add column invitation_id uuid references private.team_invitations(id),
 add column invitation_generation bigint;
alter table private.team_access_events alter column target_id drop not null;
alter table private.team_access_events add column invitation_id uuid references private.team_invitations(id),
 add constraint team_event_target check(target_id is not null or invitation_id is not null);

-- Auth invitations already contain a random internal password hash. Capture its
-- fingerprint privately and require a subsequent password change, not non-emptiness.
create function private.capture_invitation_password() returns trigger
language plpgsql security definer set search_path='' as $$
begin
 if NEW.invited_auth_user_id is not null and (TG_OP='INSERT' or OLD.invited_auth_user_id is distinct from NEW.invited_auth_user_id) then
  select encode(extensions.digest(coalesce(encrypted_password,''),'sha256'),'hex') into NEW.password_fingerprint
   from auth.users where id=NEW.invited_auth_user_id;
 end if;
 return NEW;
end;
$$;
revoke all on function private.capture_invitation_password() from public,anon,authenticated,service_role;
create trigger team_invitation_password_baseline before insert or update of invited_auth_user_id on private.team_invitations
 for each row execute function private.capture_invitation_password();
-- GoTrue may generate its temporary password while verifying the invite link.
-- That server-generated change must also become the baseline, not user consent.
create function private.observe_invited_password_change() returns trigger
language plpgsql security definer set search_path='' as $$
begin
 if OLD.email_confirmed_at is null and NEW.invited_at is not null
  and NEW.encrypted_password is distinct from OLD.encrypted_password then
  update private.team_invitations set password_fingerprint=encode(extensions.digest(coalesce(NEW.encrypted_password,''),'sha256'),'hex')
   where invited_auth_user_id=NEW.id and status in ('preparing','pending');
 end if;
 return NEW;
end;
$$;
revoke all on function private.observe_invited_password_change() from public,anon,authenticated,service_role;
create trigger team_invited_password_baseline after update of encrypted_password on auth.users
 for each row execute function private.observe_invited_password_change();
create function private.invitation_password_ready(p_id uuid) returns boolean
language sql stable security definer set search_path='' as $$
 select exists(select 1 from private.team_invitations i join auth.users u on u.id=i.invited_auth_user_id
  where i.id=p_id and coalesce(u.encrypted_password,'')<>'' and i.password_fingerprint is not null
   and encode(extensions.digest(u.encrypted_password,'sha256'),'hex')<>i.password_fingerprint);
$$;
revoke all on function private.invitation_password_ready(uuid) from public,anon,authenticated,service_role;

create function private.require_team_sender(p_actor uuid,p_session uuid,p_exp numeric) returns void
language plpgsql security definer set search_path='' as $$
begin
 if p_exp is null or p_exp<=extract(epoch from clock_timestamp()) or p_exp>=100000000000
  or not private.is_current_staff(p_actor,p_session)
  or not exists(select 1 from public.staff_members where user_id=p_actor and active and role='administrator') then
  raise exception using errcode='42501',message='administrator_required';
 end if;
end;
$$;
create function private.team_invitation_json(p_id uuid) returns jsonb
language sql stable security definer set search_path='' as $$
 select jsonb_build_object('id',id,'name',display_name,'email',normalized_email,
  'role',intended_role,'status',case when status='pending' and expires_at<=clock_timestamp() then 'expired' else status end,
  'generation',generation,'version',version,'expires_at',expires_at,'delivery_state',delivery_state,
  'retry_after',greatest(0,ceil(extract(epoch from (send_started_at+interval '60 seconds'-clock_timestamp()))))::integer)
 from private.team_invitations where id=p_id;
$$;
create function private.team_invitation_event(p_id uuid,p_actor uuid,p_action text,p_key text) returns void
language sql security definer set search_path='' as $$
 insert into private.team_access_events(actor_kind,actor_id,actor_label,target_id,invitation_id,action,resulting_role,resulting_active,operation_key)
 select 'member',p_actor,coalesce(nullif(btrim((select display_name from public.staff_members where user_id=p_actor)),''),'Equipe'),
  invited_auth_user_id,id,p_action,intended_role,status='accepted',p_key
 from private.team_invitations where id=p_id;
$$;
revoke all on function private.require_team_sender(uuid,uuid,numeric),private.team_invitation_json(uuid),private.team_invitation_event(uuid,uuid,text,text) from public,anon,authenticated,service_role;

create function public.reserve_team_invitation(p_actor_id uuid,p_session_id uuid,p_jwt_exp numeric,p_operation_key text,p_command text,p_payload jsonb)
returns jsonb language plpgsql security definer set search_path='' as $$
declare v_inv private.team_invitations%rowtype;v_op private.team_operations%rowtype;
 v_email text;v_name text;v_role text;v_digest text;v_user auth.users%rowtype;v_receipt jsonb;
begin
 perform private.require_team_sender(p_actor_id,p_session_id,p_jwt_exp);
 if p_operation_key is null or p_operation_key !~ '^[A-Za-z0-9_-]{16,128}$'
  or p_command is null or p_command not in ('invite','resend') or jsonb_typeof(p_payload) is distinct from 'object' then
  raise exception using errcode='22023',message='invalid_invitation_input';
 end if;
 perform pg_advisory_xact_lock(hashtextextended('abrigo.team-members',0));
 perform private.require_team_sender(p_actor_id,p_session_id,p_jwt_exp);
 v_digest:=encode(extensions.digest(jsonb_build_object('command',p_command,'payload',p_payload)::text,'sha256'),'hex');
 select * into v_op from private.team_operations where actor_id=p_actor_id and operation_key=p_operation_key;
 if found then
  if v_op.command<>p_command or v_op.payload_fingerprint<>v_digest then raise exception using errcode='PT409',message='operation_conflict'; end if;
  return jsonb_build_object('should_send',false,'invitation_id',v_op.invitation_id,'receipt',v_op.receipt);
 end if;
 if (select count(*) from private.team_operations where actor_id=p_actor_id and command in ('invite','resend') and created_at>clock_timestamp()-interval '1 hour')>=20 then
  raise exception using errcode='PT429',message='invitation_rate_limited';
 end if;
 if p_command='invite' then
  if (select count(*) from jsonb_object_keys(p_payload))<>3 or not (p_payload ?& array['name','email','role'])
   or jsonb_typeof(p_payload->'name')<>'string' or jsonb_typeof(p_payload->'email')<>'string' or jsonb_typeof(p_payload->'role')<>'string' then
   raise exception using errcode='22023',message='invalid_invitation_input';
  end if;
  v_name:=btrim(p_payload->>'name');v_email:=lower(btrim(p_payload->>'email'));v_role:=p_payload->>'role';
  if char_length(v_name) not between 1 and 100 or char_length(v_email)>254 or v_email !~ '^[^[:space:]@]+@[^[:space:]@]+\.[^[:space:]@]+$' or v_role not in ('administrator','employee') then
   raise exception using errcode='22023',message='invalid_invitation_input';
  end if;
  if exists(select 1 from auth.users u join public.staff_members m on m.user_id=u.id where lower(u.email)=v_email) then raise exception using errcode='PT409',message='already_member'; end if;
  if exists(select 1 from private.team_invitations where normalized_email=v_email and status in ('preparing','pending')) then raise exception using errcode='PT409',message='invitation_exists'; end if;
  select * into v_user from auth.users where lower(email)=v_email limit 1;
  if found and (v_user.email_confirmed_at is not null or not exists(select 1 from private.team_invitations where invited_auth_user_id=v_user.id and normalized_email=v_email)) then
   raise exception using errcode='PT409',message='existing_account';
  end if;
  if exists(select 1 from private.team_invitations where normalized_email=v_email and send_started_at>clock_timestamp()-interval '60 seconds') then raise exception using errcode='PT429',message='invitation_cooldown'; end if;
  insert into private.team_invitations(normalized_email,display_name,intended_role,invited_auth_user_id,status,expires_at,created_by_kind,created_by,generation_started_at,send_started_at)
  values(v_email,v_name,v_role,v_user.id,'preparing',clock_timestamp()+interval '1 hour','member',p_actor_id,clock_timestamp(),clock_timestamp()) returning * into v_inv;
 else
  if (select count(*) from jsonb_object_keys(p_payload))<>2 or not (p_payload ?& array['invitation_id','expected_version']) then raise exception using errcode='22023',message='invalid_invitation_input'; end if;
  select * into v_inv from private.team_invitations where id=(p_payload->>'invitation_id')::uuid for update;
  if not found or v_inv.status in ('accepted','revoked') then raise exception using errcode='PT409',message='invitation_unavailable'; end if;
  if v_inv.version is distinct from (p_payload->>'expected_version')::bigint then raise exception using errcode='PT409',message='invitation_version_conflict'; end if;
  if v_inv.send_started_at>clock_timestamp()-interval '60 seconds' then raise exception using errcode='PT429',message='invitation_cooldown'; end if;
  if exists(select 1 from auth.users where id=v_inv.invited_auth_user_id and email_confirmed_at is not null) then raise exception using errcode='PT409',message='invitation_opened'; end if;
  update private.team_invitations set generation=generation+1,version=version+1,status='preparing',delivery_state='sending',
   generation_started_at=clock_timestamp(),send_started_at=clock_timestamp(),expires_at=clock_timestamp()+interval '1 hour',updated_at=clock_timestamp()
   where id=v_inv.id returning * into v_inv;
 end if;
 v_receipt:=jsonb_build_object('state','pending','code','sending','invitation',private.team_invitation_json(v_inv.id));
 insert into private.team_operations(actor_id,operation_key,command,target_id,payload_fingerprint,state,receipt,invitation_id,invitation_generation)
 values(p_actor_id,p_operation_key,p_command,v_inv.id,v_digest,'pending',v_receipt,v_inv.id,v_inv.generation);
 perform private.team_invitation_event(v_inv.id,p_actor_id,case when p_command='resend' then 'invitation_resend_requested' else 'invitation_requested' end,p_operation_key);
 return jsonb_build_object('should_send',true,'invitation_id',v_inv.id,'email',v_inv.normalized_email,'receipt',v_receipt);
end;
$$;

create function public.finish_team_invitation(p_actor_id uuid,p_session_id uuid,p_jwt_exp numeric,p_operation_key text,p_delivery text,p_auth_user_id uuid default null,p_error_code text default null)
returns jsonb language plpgsql security definer set search_path='' as $$
declare v_op private.team_operations%rowtype;v_inv private.team_invitations%rowtype;v_user auth.users%rowtype;
 v_receipt jsonb;v_state text;v_code text;
begin
 perform private.require_team_sender(p_actor_id,p_session_id,p_jwt_exp);
 if p_delivery is null or p_delivery not in ('sent','uncertain','failed') then raise exception using errcode='22023',message='invalid_delivery_state'; end if;
 perform pg_advisory_xact_lock(hashtextextended('abrigo.team-members',0));
 perform private.require_team_sender(p_actor_id,p_session_id,p_jwt_exp);
 select * into v_op from private.team_operations where actor_id=p_actor_id and operation_key=p_operation_key for update;
 if not found then raise exception using errcode='PT404',message='operation_not_found'; end if;
 if v_op.state<>'pending' or v_op.invitation_id is null then return v_op.receipt; end if;
 select * into v_inv from private.team_invitations where id=v_op.invitation_id for update;
 if v_inv.status not in ('preparing','pending') or v_inv.generation<>v_op.invitation_generation then
  v_receipt:=jsonb_build_object('state','failed','code','invitation_unavailable','invitation',private.team_invitation_json(v_inv.id));
  update private.team_operations set state='failed',receipt=v_receipt where actor_id=p_actor_id and operation_key=p_operation_key;
  return v_receipt;
 end if;
 if v_inv.expires_at<=clock_timestamp() then
  update private.team_invitations set status='expired',version=version+1,updated_at=clock_timestamp() where id=v_inv.id;
  v_state:='failed';v_code:='invitation_expired';
 else
  select * into v_user from auth.users where lower(email)=v_inv.normalized_email
   and (p_auth_user_id is null or id=p_auth_user_id)
   and (v_inv.invited_auth_user_id is null or id=v_inv.invited_auth_user_id)
   and greatest(invited_at,confirmation_sent_at)>=v_inv.send_started_at limit 1;
  if p_delivery='sent' and (p_auth_user_id is null or v_user.id is null) then raise exception using errcode='22023',message='invalid_delivery_identity'; end if;
  if p_delivery='failed' then
   v_code:=case when p_error_code in ('existing_account','rate_limited') then p_error_code else 'send_failed' end;
   update private.team_invitations set status='failed',delivery_state='failed',version=version+1,updated_at=clock_timestamp() where id=v_inv.id;
   v_state:='failed';
  elsif v_user.id is not null then
   update private.team_invitations set status='pending',delivery_state=case when p_delivery='sent' then 'sent' else 'uncertain' end,
    invited_auth_user_id=v_user.id,version=version+1,updated_at=clock_timestamp() where id=v_inv.id;
   v_state:='confirmed';v_code:=case when p_delivery='sent' then null else 'delivery_uncertain' end;
  else
   update private.team_invitations set delivery_state='uncertain',updated_at=clock_timestamp() where id=v_inv.id;
   v_state:='pending';v_code:='send_uncertain';
  end if;
 end if;
 v_receipt:=jsonb_build_object('state',v_state,'code',v_code,'invitation',private.team_invitation_json(v_inv.id));
 update private.team_operations set state=v_state,receipt=v_receipt where actor_id=p_actor_id and operation_key=p_operation_key;
 return v_receipt;
end;
$$;
revoke all on function public.reserve_team_invitation(uuid,uuid,numeric,text,text,jsonb),public.finish_team_invitation(uuid,uuid,numeric,text,text,uuid,text) from public,anon,authenticated;
grant execute on function public.reserve_team_invitation(uuid,uuid,numeric,text,text,jsonb),public.finish_team_invitation(uuid,uuid,numeric,text,text,uuid,text) to service_role;

create function public.list_team_invitations(p_status text,p_cursor uuid default null) returns jsonb
language plpgsql stable security definer set search_path='' as $$
declare v_items jsonb;v_next uuid;
begin
 if not private.is_team_administrator() then raise exception using errcode='42501',message='administrator_required'; end if;
 if p_status is null or p_status not in ('pending','history') then raise exception using errcode='22023',message='invalid_invitation_filter'; end if;
 select coalesce(jsonb_agg(private.team_invitation_json(id) order by id),'[]'::jsonb) into v_items from (
  select id from private.team_invitations where
   (case when p_status='pending' then status in ('preparing','pending','expired','failed') else status in ('accepted','revoked') end)
   and (p_cursor is null or id>p_cursor) order by id limit 50) page;
 if jsonb_array_length(v_items)=50 then v_next:=(v_items->49->>'id')::uuid; end if;
 return jsonb_build_object('items',v_items,'next_cursor',v_next);
end;
$$;
create function public.cancel_team_invitation(p_invitation_id uuid,p_expected_version bigint,p_operation_key text) returns jsonb
language plpgsql security definer set search_path='' as $$
declare v_inv private.team_invitations%rowtype;v_op private.team_operations%rowtype;v_digest text;v_receipt jsonb;v_actor uuid:=auth.uid();
begin
 if not private.is_team_administrator() then raise exception using errcode='42501',message='administrator_required'; end if;
 if p_invitation_id is null or p_expected_version is null or p_operation_key is null or p_operation_key !~ '^[A-Za-z0-9_-]{16,128}$' then raise exception using errcode='22023',message='invalid_invitation_input'; end if;
 perform pg_advisory_xact_lock(hashtextextended('abrigo.team-members',0));
 if not private.is_team_administrator() then raise exception using errcode='42501',message='administrator_required'; end if;
 v_digest:=encode(extensions.digest(jsonb_build_object('id',p_invitation_id,'version',p_expected_version)::text,'sha256'),'hex');
 select * into v_op from private.team_operations where actor_id=v_actor and operation_key=p_operation_key;
 if found then
  if v_op.command<>'cancel' or v_op.payload_fingerprint<>v_digest then raise exception using errcode='PT409',message='operation_conflict'; end if;
  return v_op.receipt;
 end if;
 select * into v_inv from private.team_invitations where id=p_invitation_id for update;
 if not found or v_inv.status in ('accepted','revoked') then raise exception using errcode='PT409',message='invitation_unavailable'; end if;
 if v_inv.version<>p_expected_version then raise exception using errcode='PT409',message='invitation_version_conflict'; end if;
 update private.team_invitations set status='revoked',version=version+1,updated_at=clock_timestamp() where id=v_inv.id;
 perform private.team_invitation_event(v_inv.id,v_actor,'invitation_revoked',p_operation_key);
 v_receipt:=jsonb_build_object('state','confirmed','invitation',private.team_invitation_json(v_inv.id));
 insert into private.team_operations(actor_id,operation_key,command,target_id,payload_fingerprint,state,receipt,invitation_id,invitation_generation)
 values(v_actor,p_operation_key,'cancel',v_inv.id,v_digest,'confirmed',v_receipt,v_inv.id,v_inv.generation);
 return v_receipt;
end;
$$;

-- Current Auth session must have been created after this invitation generation.
create function private.my_team_invitation() returns uuid
language sql stable security definer set search_path='' as $$
 select i.id from private.team_invitations i join auth.users u on u.id=i.invited_auth_user_id
 join auth.sessions s on s.user_id=u.id and s.id=(auth.jwt()->>'session_id')::uuid
 where u.id=auth.uid() and lower(u.email)=i.normalized_email and u.email_confirmed_at is not null
  and s.created_at>=i.generation_started_at and i.status in ('preparing','pending','accepted','expired','revoked','failed')
 order by i.generation_started_at desc,i.id desc limit 1;
$$;
revoke all on function private.my_team_invitation() from public,anon,authenticated,service_role;
create function public.get_my_invitation() returns jsonb
language plpgsql stable security definer set search_path='' as $$
begin
 if not private.is_session_current() then raise exception using errcode='42501',message='session_required'; end if;
 return private.team_invitation_json(private.my_team_invitation()) ||
  jsonb_build_object('password_ready',private.invitation_password_ready(private.my_team_invitation()));
end;
$$;
create function public.accept_team_invitation(p_expected_generation bigint,p_expected_version bigint,p_operation_key text) returns jsonb
language plpgsql security definer set search_path='' as $$
declare v_actor uuid:=auth.uid();v_id uuid;v_inv private.team_invitations%rowtype;v_op private.team_operations%rowtype;v_digest text;v_receipt jsonb;
begin
 if not private.is_session_current() then raise exception using errcode='42501',message='session_required'; end if;
 if p_expected_generation is null or p_expected_version is null or p_operation_key is null or p_operation_key !~ '^[A-Za-z0-9_-]{16,128}$' then raise exception using errcode='22023',message='invalid_invitation_input'; end if;
 perform pg_advisory_xact_lock(hashtextextended('abrigo.team-members',0));
 if not private.is_session_current() then raise exception using errcode='42501',message='session_required'; end if;
 v_digest:=encode(extensions.digest(jsonb_build_object('generation',p_expected_generation,'version',p_expected_version)::text,'sha256'),'hex');
 select * into v_op from private.team_operations where actor_id=v_actor and operation_key=p_operation_key;
 if found then
  if v_op.command<>'accept' or v_op.payload_fingerprint<>v_digest then raise exception using errcode='PT409',message='operation_conflict'; end if;
  return v_op.receipt;
 end if;
 v_id:=private.my_team_invitation();
 select * into v_inv from private.team_invitations where id=v_id for update;
 if not found or v_inv.status<>'pending' or v_inv.expires_at<=clock_timestamp() then raise exception using errcode='PT404',message='invitation_unavailable'; end if;
 if v_inv.generation<>p_expected_generation or v_inv.version<>p_expected_version then raise exception using errcode='PT409',message='invitation_version_conflict'; end if;
 if not private.invitation_password_ready(v_id) then raise exception using errcode='22023',message='password_required'; end if;
 if exists(select 1 from public.staff_members where user_id=v_actor) then raise exception using errcode='PT409',message='already_member'; end if;
 insert into public.staff_members(user_id,display_name,role,active) values(v_actor,v_inv.display_name,v_inv.intended_role,true);
 update private.team_invitations set status='accepted',accepted_by=v_actor,accepted_at=clock_timestamp(),version=version+1,updated_at=clock_timestamp() where id=v_id;
 perform private.team_invitation_event(v_id,v_actor,'invitation_accepted',p_operation_key);
 v_receipt:=jsonb_build_object('state','confirmed','member',private.team_member_json(v_actor),'invitation',private.team_invitation_json(v_id));
 insert into private.team_operations(actor_id,operation_key,command,target_id,payload_fingerprint,state,receipt,invitation_id,invitation_generation)
 values(v_actor,p_operation_key,'accept',v_actor,v_digest,'confirmed',v_receipt,v_id,v_inv.generation);
 return v_receipt;
end;
$$;
revoke all on function public.list_team_invitations(text,uuid),public.cancel_team_invitation(uuid,bigint,text),public.get_my_invitation(),public.accept_team_invitation(bigint,bigint,text) from public,anon;
grant execute on function public.list_team_invitations(text,uuid),public.cancel_team_invitation(uuid,bigint,text),public.get_my_invitation(),public.accept_team_invitation(bigint,bigint,text) to authenticated;

create or replace function public.access_context() returns jsonb
language plpgsql stable security definer set search_path='' as $$
declare v_current boolean:=private.is_session_current();v_staff boolean:=private.is_staff_current();v_id uuid;
begin
 if v_current then v_id:=private.my_team_invitation(); end if;
 return jsonb_build_object('user_id',auth.uid(),'is_session_current',v_current,'is_staff_active',v_staff,
  'staff_role',case when v_staff then (select role from public.staff_members where user_id=auth.uid() and active) else null end,
  'can_manage_team',private.is_team_administrator(),
  'invitation_required',v_current and not v_staff and exists(select 1 from private.team_invitations where id=v_id and status<>'accepted'));
end;
$$;
