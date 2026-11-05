-- Narrow commands preserve the aggregate and serialize retries by actor/key.
create function private.change_animal_management(p_operation_key text,p_animal_id uuid,p_kind text,p_value jsonb)
returns jsonb language plpgsql security definer set search_path='' as $$
declare v_actor uuid; v_digest text; v_existing public.write_operations%rowtype;
 v_animal public.animals%rowtype; v_result jsonb;
begin
 if not private.is_staff_current() then raise exception using errcode='42501',message='staff_required'; end if;
 if p_animal_id is null or p_operation_key is null or p_operation_key !~ '^[A-Za-z0-9_-]{32}$'
   or p_kind not in ('set_status','set_publication') or p_value is null then
   raise exception using errcode='22023',message='invalid_payload'; end if;
 if (p_kind='set_status' and (jsonb_typeof(p_value)<>'string' or p_value#>>'{}' not in ('available','treatment','quarantine','adopted')))
   or (p_kind='set_publication' and jsonb_typeof(p_value)<>'boolean') then
   raise exception using errcode='22023',message='invalid_payload'; end if;
 v_actor:=auth.uid();
 v_digest:=encode(extensions.digest(jsonb_build_object('id',p_animal_id,'value',p_value)::text,'sha256'),'hex');
 perform pg_advisory_xact_lock(hashtextextended(v_actor::text||':'||p_operation_key,0));
 if not private.is_staff_current() then raise exception using errcode='42501',message='staff_required'; end if;
 select * into v_existing from public.write_operations where actor_id=v_actor and operation_key=p_operation_key;
 if found then
   if v_existing.operation_kind<>p_kind or v_existing.payload_digest<>v_digest then
     raise exception using errcode='PT409',message='operation_conflict'; end if;
   return v_existing.result->'animal';
 end if;
 select * into v_animal from public.animals where id=p_animal_id for update;
 if not found then raise exception using errcode='PT404',message='not_found'; end if;
 if not private.is_staff_current() then raise exception using errcode='42501',message='staff_required'; end if;
 if p_kind='set_status' then
   update public.animals set status=p_value#>>'{}' where id=p_animal_id;
 else
   if (p_value#>>'{}')::boolean and v_animal.status='adopted' then
     raise exception using errcode='22023',message='adopted_publication_denied'; end if;
   update public.animals set is_published=(p_value#>>'{}')::boolean where id=p_animal_id;
 end if;
 v_result:=private.managed_animal_json(p_animal_id);
 insert into public.write_operations(actor_id,operation_key,operation_kind,payload_digest,result)
 values(v_actor,p_operation_key,p_kind,v_digest,v_result);
 return v_result->'animal';
end;
$$;
revoke all on function private.change_animal_management(text,uuid,text,jsonb) from public,anon,authenticated;

create function public.set_animal_status(p_operation_key text,p_animal_id uuid,p_status text)
returns jsonb language sql security definer set search_path='' as $$
 select private.change_animal_management(p_operation_key,p_animal_id,'set_status',to_jsonb(p_status));
$$;
create function public.set_animal_publication(p_operation_key text,p_animal_id uuid,p_is_published boolean)
returns jsonb language sql security definer set search_path='' as $$
 select private.change_animal_management(p_operation_key,p_animal_id,'set_publication',to_jsonb(p_is_published));
$$;
create function public.get_animal_status_counts() returns jsonb
language plpgsql stable security definer set search_path='' as $$
begin
 if not private.is_staff_current() then raise exception using errcode='42501',message='staff_required'; end if;
 return (select jsonb_object_agg(s.status,(select count(*) from public.animals a where a.status=s.status))
   from unnest(array['available','treatment','quarantine','adopted']) s(status));
end;
$$;
revoke all on function public.set_animal_status(text,uuid,text),public.set_animal_publication(text,uuid,boolean),public.get_animal_status_counts() from public,anon;
grant execute on function public.set_animal_status(text,uuid,text),public.set_animal_publication(text,uuid,boolean),public.get_animal_status_counts() to authenticated;
