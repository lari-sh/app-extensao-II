create schema if not exists private;
revoke all on schema private from public;
create table public.staff_members (
 user_id uuid primary key references auth.users(id) on delete cascade,
 active boolean not null default false,
 created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
alter table public.staff_members enable row level security;
revoke all on public.staff_members from public,anon,authenticated;
grant all on public.staff_members to service_role;
create function private.is_current_staff(p_user_id uuid,p_session_id uuid)
returns boolean language sql stable security definer set search_path='' as $$
 select p_user_id is not null and p_session_id is not null and exists(
   select 1 from auth.sessions s join public.staff_members m on m.user_id=s.user_id
   where s.id=p_session_id and s.user_id=p_user_id and m.active
   and (s.not_after is null or s.not_after>now())
 );
$$;
revoke all on function private.is_current_staff(uuid,uuid) from public,anon,authenticated;
grant usage on schema private to anon,authenticated,service_role;
grant execute on function private.is_current_staff(uuid,uuid) to service_role;
create function private.is_staff_current() returns boolean
language plpgsql stable security definer set search_path='' as $$
begin
 if auth.jwt()->>'exp' is not null and (auth.jwt()->>'exp')::numeric<=extract(epoch from now()) then return false; end if;
 return private.is_current_staff(auth.uid(),(auth.jwt()->>'session_id')::uuid);
exception when others then return false;
end;
$$;
revoke all on function private.is_staff_current() from public;
grant execute on function private.is_staff_current() to anon,authenticated,service_role;
create function public.access_context() returns jsonb
language sql stable security definer set search_path='' as $$
 select jsonb_build_object('user_id',auth.uid(),'is_staff_active',private.is_staff_current());
$$;
revoke all on function public.access_context() from public,anon;
grant execute on function public.access_context() to authenticated;
grant select on public.animals,public.animal_internal_details,public.clinical_records to anon,authenticated;
create policy animals_read on public.animals for select to anon,authenticated
 using ((is_published and status<>'adopted') or private.is_staff_current());
create policy internal_read on public.animal_internal_details for select to anon,authenticated using(private.is_staff_current());
create policy care_read on public.clinical_records for select to anon,authenticated using(private.is_staff_current());
