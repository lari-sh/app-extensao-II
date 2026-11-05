create function private.is_session_current() returns boolean
language plpgsql stable security definer set search_path='' as $$
begin
 if auth.uid() is null then return false; end if;
 if auth.jwt()->>'exp' is not null and (auth.jwt()->>'exp')::numeric<=extract(epoch from now()) then return false; end if;
 return exists(select 1 from auth.sessions s where s.user_id=auth.uid() and s.id=(auth.jwt()->>'session_id')::uuid and (s.not_after is null or s.not_after>now()));
exception when others then return false;
end;
$$;
revoke all on function private.is_session_current() from public,anon,authenticated;
create or replace function public.access_context() returns jsonb
language sql stable security definer set search_path='' as $$
 select jsonb_build_object('user_id',auth.uid(),'is_session_current',private.is_session_current(),'is_staff_active',private.is_staff_current());
$$;
revoke all on function public.access_context() from public,anon;
grant execute on function public.access_context() to authenticated;
