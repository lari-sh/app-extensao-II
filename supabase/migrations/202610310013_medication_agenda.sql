-- Private calendar reads. Each page/counter is read in a single statement snapshot.
create function private.medication_read_date(p_value text) returns date
language plpgsql immutable set search_path='' as $$
declare v date;
begin
 if p_value is null or p_value !~ '^\d{4}-\d{2}-\d{2}$' then raise exception 'invalid_payload' using errcode='22023'; end if;
 begin v:=p_value::date; exception when others then raise exception 'invalid_payload' using errcode='22023'; end;
 if v not between date '2000-01-01' and date '2100-12-31' or to_char(v,'YYYY-MM-DD')<>p_value then raise exception 'invalid_payload' using errcode='22023'; end if;
 return v;
end;$$;

create function private.medication_application_json(p_id uuid) returns jsonb
language sql stable set search_path='' as $$
 select jsonb_build_object('id',a.id,'treatment_id',a.treatment_id,'animal_id',t.animal_id,
 'animal_name',n.name,'medication_name',r.medication_name,'instructions',r.instructions,
 'revision',a.revision,'version',a.version,'state',a.state,'scheduled_at',a.scheduled_at,
 'scheduled_local_date',to_char(a.scheduled_at at time zone 'America/Sao_Paulo','YYYY-MM-DD'),
 'scheduled_local_time',to_char(a.scheduled_at at time zone 'America/Sao_Paulo','HH24:MI'),
 'performed_by',a.performed_by,'performed_at',a.performed_at,
 'actor_label',case when a.state='completed' then coalesce((select e.actor_label from public.medication_application_events e where e.application_id=a.id and e.event_type='completed' order by e.application_version desc limit 1),s.display_name,'Funcionário') end,
 'performed_local_date',to_char(a.performed_at at time zone 'America/Sao_Paulo','YYYY-MM-DD'),
 'performed_local_time',to_char(a.performed_at at time zone 'America/Sao_Paulo','HH24:MI'))
 from public.medication_applications a
 join public.medication_treatments t on t.id=a.treatment_id
 join public.animals n on n.id=t.animal_id
 join public.medication_treatment_revisions r on r.treatment_id=a.treatment_id and r.revision=a.revision
 left join public.staff_members s on s.user_id=a.performed_by where a.id=p_id;
$$;

create function private.medication_read_cursor(p_cursor text) returns jsonb
language plpgsql immutable set search_path='' as $$
declare v jsonb;
begin
 if p_cursor is null then return null; end if;
 if octet_length(p_cursor) not between 1 and 1024 then raise exception 'invalid_payload' using errcode='22023'; end if;
 begin v:=convert_from(decode(p_cursor,'base64'),'UTF8')::jsonb;
 exception when others then raise exception 'invalid_payload' using errcode='22023'; end;
 if jsonb_typeof(v)<>'object' then raise exception 'invalid_payload' using errcode='22023'; end if;
 return v;
end;$$;

create function public.get_medication_calendar_month(p_month text) returns jsonb
language plpgsql security definer set search_path='' as $$
declare v_start date; v_end date;
begin
 if not private.medication_staff_current() then raise exception 'staff_required' using errcode='42501'; end if;
 if p_month is null or p_month !~ '^\d{4}-\d{2}$' then raise exception 'invalid_payload' using errcode='22023'; end if;
 v_start:=private.medication_read_date(p_month||'-01'); v_end:=(v_start+interval '1 month')::date;
 return (with days as (
 select (a.scheduled_at at time zone 'America/Sao_Paulo')::date d,
 count(*) filter(where a.state='pending') pending,count(*) filter(where a.state='completed') completed,
 count(*) filter(where a.state='cancelled') cancelled
 from public.medication_applications a
 where a.scheduled_at>=v_start::timestamp at time zone 'America/Sao_Paulo'
 and a.scheduled_at<v_end::timestamp at time zone 'America/Sao_Paulo' group by 1)
 select jsonb_build_object('month',p_month,'timezone','America/Sao_Paulo','server_now',statement_timestamp(),
 'shelter_today',to_char(statement_timestamp() at time zone 'America/Sao_Paulo','YYYY-MM-DD'),
 'days',coalesce(jsonb_agg(jsonb_build_object('day',to_char(d,'YYYY-MM-DD'),'pending',pending,'completed',completed,'cancelled',cancelled) order by d),'[]')) from days);
end;$$;

create function public.list_medication_day(p_day text,p_cursor text default null) returns jsonb
language plpgsql security definer set search_path='' as $$
declare v_day date; c jsonb; v_at timestamptz; v_id uuid; v_version bigint; response jsonb;
begin
 if not private.medication_staff_current() then raise exception 'staff_required' using errcode='42501'; end if;
 v_day:=private.medication_read_date(p_day); c:=private.medication_read_cursor(p_cursor);
 if c is not null then
  begin
   if c->>'kind' is distinct from 'day' or c->>'day' is distinct from p_day or c->>'actor' is distinct from auth.uid()::text
   or not (c ?& array['at','id','version']) then raise exception 'invalid_payload'; end if;
   v_at:=(c->>'at')::timestamptz; v_id:=(c->>'id')::uuid; v_version:=(c->>'version')::bigint;
   if v_at is null or v_id is null or v_version is null or v_version<0 then raise exception 'invalid_payload'; end if;
  exception when others then raise exception 'invalid_payload' using errcode='22023'; end;
 end if;
 with snapshot as materialized(select agenda_version from private.medication_agenda_state where singleton),
 page as materialized(
 select a.id,a.scheduled_at from public.medication_applications a
 where a.scheduled_at>=v_day::timestamp at time zone 'America/Sao_Paulo'
 and a.scheduled_at<(v_day+1)::timestamp at time zone 'America/Sao_Paulo'
 and (c is null or (a.scheduled_at,a.id)>(v_at,v_id)) order by a.scheduled_at,a.id limit 101),
 visible as materialized(select * from page order by scheduled_at,id limit 100),
 last_row as(select * from visible order by scheduled_at desc,id desc limit 1)
 select jsonb_build_object('day',p_day,'server_now',statement_timestamp(),'agenda_version',s.agenda_version,
 'items',coalesce((select jsonb_agg(private.medication_application_json(id) order by scheduled_at,id) from visible),'[]'),
 'next_cursor',case when (select count(*) from page)>100 then
 (select replace(encode(convert_to(jsonb_build_object('kind','day','actor',auth.uid(),'day',p_day,'version',s.agenda_version,'at',scheduled_at,'id',id)::text,'UTF8'),'base64'),E'\n','') from last_row) end)
 into response from snapshot s;
 if c is not null and (response->>'agenda_version')::bigint<>v_version then raise exception 'snapshot_changed' using errcode='PT409'; end if;
 return response;
end;$$;

create function public.get_medication_application_history(p_application_id uuid,p_cursor text default null) returns jsonb
language plpgsql security definer set search_path='' as $$
declare c jsonb; v_version integer; v_id uuid; response jsonb;
begin
 if not private.medication_staff_current() then raise exception 'staff_required' using errcode='42501'; end if;
 if p_application_id is null then raise exception 'invalid_payload' using errcode='22023'; end if;
 c:=private.medication_read_cursor(p_cursor);
 if c is not null then
  begin
   if c->>'kind' is distinct from 'history' or c->>'application' is distinct from p_application_id::text or c->>'actor' is distinct from auth.uid()::text or not(c ?& array['version','id']) then raise exception 'invalid_payload'; end if;
   v_version:=(c->>'version')::integer; v_id:=(c->>'id')::uuid;
   if v_version is null or v_version<1 or v_id is null then raise exception 'invalid_payload'; end if;
  exception when others then raise exception 'invalid_payload' using errcode='22023'; end;
 end if;
 with app as materialized(select private.medication_application_json(p_application_id) value),
 page as materialized(select e.* from public.medication_application_events e where e.application_id=p_application_id
 and(c is null or (e.application_version,e.id)>(v_version,v_id)) order by e.application_version,e.id limit 101),
 visible as materialized(select * from page order by application_version,id limit 100),
 last_row as(select * from visible order by application_version desc,id desc limit 1)
 select jsonb_build_object('application',app.value,'items',coalesce((select jsonb_agg(jsonb_build_object(
 'id',id,'application_id',application_id,'event_type',event_type,'actor_id',actor_id,'actor_label',actor_label,
 'occurred_at',occurred_at,'occurred_local_date',to_char(occurred_at at time zone 'America/Sao_Paulo','YYYY-MM-DD'),
 'occurred_local_time',to_char(occurred_at at time zone 'America/Sao_Paulo','HH24:MI'),
 'application_version',application_version,'reason',reason) order by application_version,id) from visible),'[]'),
 'next_cursor',case when(select count(*) from page)>100 then(select replace(encode(convert_to(jsonb_build_object('kind','history','actor',auth.uid(),'application',p_application_id,'version',application_version,'id',id)::text,'UTF8'),'base64'),E'\n','') from last_row) end)
 into response from app;
 if response->'application'='null'::jsonb then raise exception 'not_found' using errcode='PT404'; end if;
 return response;
end;$$;

revoke all on function private.medication_read_date(text),private.medication_read_cursor(text),private.medication_application_json(uuid) from public,anon,authenticated;
revoke all on function public.get_medication_calendar_month(text),public.list_medication_day(text,text),public.get_medication_application_history(uuid,text) from public,anon,authenticated;
grant execute on function public.get_medication_calendar_month(text),public.list_medication_day(text,text),public.get_medication_application_history(uuid,text) to authenticated;
