-- Team authorization. Existing members remain employees; no implicit promotion.
alter table public.staff_members
 add column role text not null default 'employee' check(role in ('administrator','employee')),
 add column version bigint not null default 1 check(version>0);

create table private.team_invitations (
 id uuid primary key default gen_random_uuid(),
 normalized_email text not null check(normalized_email=lower(btrim(normalized_email))),
 display_name text not null check(char_length(btrim(display_name)) between 1 and 100),
 intended_role text not null check(intended_role in ('administrator','employee')),
 invited_auth_user_id uuid references auth.users(id),
 generation bigint not null default 1 check(generation>0),
 status text not null default 'preparing' check(status in ('preparing','pending','accepted','revoked','expired','failed')),
 expires_at timestamptz not null,
 created_by_kind text not null check(created_by_kind in ('bootstrap','member')),
 created_by uuid references auth.users(id),
 accepted_by uuid references auth.users(id), accepted_at timestamptz,
 version bigint not null default 1 check(version>0),
 created_at timestamptz not null default clock_timestamp(),
 updated_at timestamptz not null default clock_timestamp(),
 check((created_by_kind='bootstrap' and created_by is null) or (created_by_kind='member' and created_by is not null)),
 check((status='accepted' and accepted_by is not null and accepted_at is not null) or
       (status<>'accepted' and accepted_by is null and accepted_at is null))
);
create unique index team_invitation_current_email on private.team_invitations(normalized_email)
 where status in ('preparing','pending');
create index team_invitation_recipient on private.team_invitations(invited_auth_user_id,status);
create table private.team_operations (
 actor_id uuid not null references auth.users(id), operation_key text not null,
 command text not null, target_id uuid, payload_fingerprint text not null,
 state text not null check(state in ('pending','confirmed','failed')),
 receipt jsonb, created_at timestamptz not null default clock_timestamp(),
 primary key(actor_id,operation_key)
);
create table private.team_access_events (
 id uuid primary key default gen_random_uuid(),
 actor_kind text not null check(actor_kind in ('bootstrap','member')),
 actor_id uuid references auth.users(id), actor_label text not null,
 target_id uuid not null references auth.users(id), action text not null,
 previous_role text, previous_active boolean, resulting_role text, resulting_active boolean,
 occurred_at timestamptz not null default clock_timestamp(), operation_key text,
 check((actor_kind='bootstrap' and actor_id is null) or (actor_kind='member' and actor_id is not null))
);
create table private.team_bootstrap (
 singleton boolean primary key default true check(singleton),
 invitation_id uuid not null unique references private.team_invitations(id),
 reserved_at timestamptz not null default clock_timestamp()
);
alter table private.team_invitations enable row level security;
alter table private.team_operations enable row level security;
alter table private.team_access_events enable row level security;
alter table private.team_bootstrap enable row level security;
revoke all on private.team_invitations,private.team_operations,private.team_access_events,private.team_bootstrap from public,anon,authenticated,service_role;

create function private.is_team_administrator() returns boolean
language sql stable security definer set search_path='' as $$
 select private.is_staff_current() and exists(
  select 1 from public.staff_members where user_id=auth.uid() and active and role='administrator');
$$;
revoke all on function private.is_team_administrator() from public,anon,authenticated;

create or replace function public.access_context() returns jsonb
language sql stable security definer set search_path='' as $$
 select jsonb_build_object('user_id',auth.uid(),
  'is_session_current',private.is_session_current(),
  'is_staff_active',private.is_staff_current(),
  'staff_role',case when private.is_staff_current() then
    (select role from public.staff_members where user_id=auth.uid() and active) else null end,
  'can_manage_team',private.is_team_administrator());
$$;
revoke all on function public.access_context() from public,anon;
grant execute on function public.access_context() to authenticated;

-- Every member mutation takes the same lock, including trusted SQL operations.
create function private.guard_team_member() returns trigger
language plpgsql security definer set search_path='' as $$
begin
 perform pg_advisory_xact_lock(hashtextextended('abrigo.team-members',0));
 if TG_OP in ('UPDATE','DELETE') and OLD.active and OLD.role='administrator' then
  if TG_OP='DELETE' or not NEW.active or NEW.role<>'administrator' then
   if not exists(select 1 from public.staff_members where active and role='administrator' and user_id<>OLD.user_id) then
    raise exception using errcode='PT409',message='last_administrator';
   end if;
  end if;
 end if;
 if TG_OP='DELETE' then return OLD; end if;
 if TG_OP='UPDATE' then NEW.version:=OLD.version+1; end if;
 NEW.updated_at:=clock_timestamp();
 return NEW;
end;
$$;
revoke all on function private.guard_team_member() from public,anon,authenticated,service_role;
create trigger team_member_guard before insert or update or delete on public.staff_members
 for each row execute function private.guard_team_member();

create function private.team_member_json(p_user_id uuid) returns jsonb
language sql stable security definer set search_path='' as $$
 select jsonb_build_object('user_id',m.user_id,'display_name',
  coalesce(nullif(btrim(m.display_name),''),'Funcionário '||m.user_id::text),
  'email',u.email,'role',m.role,'active',m.active,'version',m.version)
 from public.staff_members m join auth.users u on u.id=m.user_id where m.user_id=p_user_id;
$$;
revoke all on function private.team_member_json(uuid) from public,anon,authenticated,service_role;

create function public.list_team_members(p_status text,p_cursor uuid default null) returns jsonb
language plpgsql stable security definer set search_path='' as $$
declare v_items jsonb;v_next uuid;
begin
 if not private.is_team_administrator() then raise exception using errcode='42501',message='administrator_required'; end if;
 if p_status is null or p_status not in ('active','inactive') then raise exception using errcode='22023',message='invalid_team_filter'; end if;
 select coalesce(jsonb_agg(private.team_member_json(user_id) order by user_id),'[]'::jsonb) into v_items
 from (select user_id from public.staff_members where active=(p_status='active')
  and (p_cursor is null or user_id>p_cursor) order by user_id limit 50) page;
 if jsonb_array_length(v_items)=50 then
  v_next:=(v_items->49->>'user_id')::uuid;
  if not exists(select 1 from public.staff_members where active=(p_status='active') and user_id>v_next) then v_next:=null; end if;
 end if;
 return jsonb_build_object('items',v_items,'next_cursor',v_next);
end;
$$;

create function public.change_team_member(p_user_id uuid,p_expected_version bigint,p_role text,p_active boolean,p_operation_key text)
returns jsonb language plpgsql security definer set search_path='' as $$
declare v_actor uuid:=auth.uid();v_old public.staff_members%rowtype;
 v_operation private.team_operations%rowtype;v_digest text;v_receipt jsonb;
begin
 if not private.is_team_administrator() then raise exception using errcode='42501',message='administrator_required'; end if;
 if p_user_id is null or p_expected_version is null or p_expected_version<1 or p_role is null
  or p_role not in ('administrator','employee') or p_active is null or p_operation_key is null
  or p_operation_key !~ '^[A-Za-z0-9_-]{16,128}$' then
  raise exception using errcode='22023',message='invalid_member_change';
 end if;
 perform pg_advisory_xact_lock(hashtextextended('abrigo.team-members',0));
 if not private.is_team_administrator() then raise exception using errcode='42501',message='administrator_required'; end if;
 v_digest:=encode(extensions.digest(jsonb_build_object('user_id',p_user_id,'version',p_expected_version,'role',p_role,'active',p_active)::text,'sha256'),'hex');
 select * into v_operation from private.team_operations where actor_id=v_actor and operation_key=p_operation_key;
 if found then
  if v_operation.command<>'change_member' or v_operation.payload_fingerprint<>v_digest then
   raise exception using errcode='PT409',message='operation_conflict';
  end if;
  return v_operation.receipt;
 end if;
 select * into v_old from public.staff_members where user_id=p_user_id for update;
 if not found then raise exception using errcode='PT404',message='member_not_found'; end if;
 if v_old.version<>p_expected_version then raise exception using errcode='PT409',message='member_version_conflict'; end if;
 if p_user_id=v_actor and (p_role<>'administrator' or not p_active) then
  raise exception using errcode='PT409',message='self_access_change_denied';
 end if;
 if v_old.role<>p_role or v_old.active<>p_active then
  update public.staff_members set role=p_role,active=p_active where user_id=p_user_id;
  insert into private.team_access_events(actor_kind,actor_id,actor_label,target_id,action,previous_role,previous_active,resulting_role,resulting_active,operation_key)
  values('member',v_actor,coalesce(nullif(btrim((select display_name from public.staff_members where user_id=v_actor)),''),'Funcionário '||v_actor::text),
   p_user_id,'member_changed',v_old.role,v_old.active,p_role,p_active,p_operation_key);
 end if;
 v_receipt:=jsonb_build_object('member',private.team_member_json(p_user_id));
 insert into private.team_operations(actor_id,operation_key,command,target_id,payload_fingerprint,state,receipt)
 values(v_actor,p_operation_key,'change_member',p_user_id,v_digest,'confirmed',v_receipt);
 return v_receipt;
end;
$$;
create function public.get_team_operation(p_operation_key text) returns jsonb
language plpgsql stable security definer set search_path='' as $$
begin
 if not private.is_team_administrator() then raise exception using errcode='42501',message='administrator_required'; end if;
 return (select receipt from private.team_operations where actor_id=auth.uid() and operation_key=p_operation_key);
end;
$$;
revoke all on function public.list_team_members(text,uuid),public.change_team_member(uuid,bigint,text,boolean,text),public.get_team_operation(text) from public,anon;
grant execute on function public.list_team_members(text,uuid),public.change_team_member(uuid,bigint,text,boolean,text),public.get_team_operation(text) to authenticated;

-- No public bootstrap endpoint. The trusted operator first uses Auth Admin to
-- invite the recipient, then reserves this user with a direct SQL connection.
create function private.bootstrap_team_administrator(p_user_id uuid,p_email text,p_display_name text)
returns jsonb language plpgsql security definer set search_path='' as $$
declare v_invitation uuid;v_email text:=lower(btrim(p_email));
begin
 perform pg_advisory_xact_lock(hashtextextended('abrigo.team-members',0));
 if exists(select 1 from private.team_bootstrap) or exists(select 1 from public.staff_members where active and role='administrator') then
  raise exception using errcode='PT409',message='bootstrap_already_reserved';
 end if;
 if p_user_id is null or v_email is null or v_email !~ '^[^[:space:]@]+@[^[:space:]@]+\.[^[:space:]@]+$'
  or p_display_name is null or char_length(btrim(p_display_name)) not between 1 and 100
  or exists(select 1 from public.staff_members where user_id=p_user_id)
  or not exists(select 1 from auth.users where id=p_user_id and lower(email)=v_email and email_confirmed_at is null) then
  raise exception using errcode='22023',message='invalid_bootstrap_recipient';
 end if;
 insert into private.team_invitations(normalized_email,display_name,intended_role,invited_auth_user_id,status,expires_at,created_by_kind)
 values(v_email,btrim(p_display_name),'administrator',p_user_id,'pending',clock_timestamp()+interval '1 hour','bootstrap') returning id into v_invitation;
 insert into private.team_bootstrap(invitation_id) values(v_invitation);
 insert into private.team_access_events(actor_kind,actor_label,target_id,action,resulting_role,resulting_active)
 values('bootstrap','Provisionamento técnico',p_user_id,'bootstrap_reserved','administrator',false);
 return jsonb_build_object('invitation_id',v_invitation,'status','pending');
end;
$$;
revoke all on function private.bootstrap_team_administrator(uuid,text,text) from public,anon,authenticated;
grant execute on function private.bootstrap_team_administrator(uuid,text,text) to service_role;
