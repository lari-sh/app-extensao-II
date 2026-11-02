-- 006 v3: filter medication applications before paging, keeping the selected day.
create function private.match_managed_animal_ids(p_query text,p_species text,p_sex text,p_color text,p_size text,p_status text)
returns setof uuid language plpgsql stable set search_path='' as $$
declare v_query text:=nullif(btrim(p_query,E' \t\n\r'),'');v_color text:=nullif(btrim(p_color,E' \t\n\r'),'');
v_name_pattern text;v_color_pattern text;v_code text;
begin
 if char_length(v_query)>80 or char_length(v_color)>80
   or (p_species is not null and p_species not in ('dog','cat'))
   or (p_sex is not null and p_sex not in ('female','male'))
   or (p_size is not null and p_size not in ('small','medium','large'))
   or (p_status is not null and p_status not in ('available','treatment','quarantine','adopted')) then
  raise exception using errcode='22023',message='invalid_search_filter';
 end if;
 if v_query ~ '^#?[Aa][0-9]{4,}$' then
  v_code:=upper(regexp_replace(v_query,'^#',''));
 elsif v_query is not null then
  v_name_pattern:='%'||replace(replace(replace(v_query,chr(92),chr(92)||chr(92)),'%',chr(92)||'%'),'_',chr(92)||'_')||'%';
 end if;
 if v_color is not null then
  v_color_pattern:='%'||replace(replace(replace(v_color,chr(92),chr(92)||chr(92)),'%',chr(92)||'%'),'_',chr(92)||'_')||'%';
 end if;
 return query
  select a.id from public.animals a
   where (v_query is null or (v_code is not null and a.animal_code=v_code)
      or (v_code is null and a.name ilike v_name_pattern escape chr(92)))
    and (p_species is null or a.species=p_species)
    and (p_sex is null or a.sex=p_sex)
    and (p_size is null or a.size=p_size)
    and (p_status is null or a.status=p_status)
    and (v_color is null or a.color ilike v_color_pattern escape chr(92));
end;$$;
revoke all on function private.match_managed_animal_ids(text,text,text,text,text,text) from public,anon,authenticated;
create function public.search_medication_day(p_day text,p_filter jsonb,p_cursor text default null) returns jsonb
language plpgsql security definer set search_path='' as $$
declare v_day date; c jsonb; v_at timestamptz; v_id uuid; v_version bigint; response jsonb;
begin
 if not private.medication_staff_current() then raise exception 'staff_required' using errcode='42501'; end if;
 if p_filter is null or jsonb_typeof(p_filter)<>'object' then raise exception 'invalid_payload' using errcode='22023';end if;
 if exists(select 1 from jsonb_each(p_filter) e where e.key not in ('query','species','sex','color','size','status') or jsonb_typeof(e.value) not in ('string','null')) then raise exception 'invalid_payload' using errcode='22023';end if;
 v_day:=private.medication_read_date(p_day); c:=private.medication_read_cursor(p_cursor);
 if c is not null then
  begin
   if c->>'kind' is distinct from 'search_day' or c->>'filter_hash' is distinct from md5(p_filter::text) or c->>'day' is distinct from p_day or c->>'actor' is distinct from auth.uid()::text
   or not (c ?& array['at','id','version']) then raise exception 'invalid_payload'; end if;
   v_at:=(c->>'at')::timestamptz; v_id:=(c->>'id')::uuid; v_version:=(c->>'version')::bigint;
   if v_at is null or v_id is null or v_version is null or v_version<0 then raise exception 'invalid_payload'; end if;
  exception when others then raise exception 'invalid_payload' using errcode='22023'; end;
 end if;
 with matched as materialized(select private.match_managed_animal_ids(p_filter->>'query',p_filter->>'species',p_filter->>'sex',p_filter->>'color',p_filter->>'size',p_filter->>'status') as id),
 snapshot as materialized(select agenda_version from private.medication_agenda_state where singleton),
 page as materialized(
 select a.id,a.scheduled_at from public.medication_applications a join public.medication_treatments t on t.id=a.treatment_id
 where t.animal_id in (select id from matched) and a.scheduled_at>=v_day::timestamp at time zone 'America/Sao_Paulo'
 and a.scheduled_at<(v_day+1)::timestamp at time zone 'America/Sao_Paulo'
 and (c is null or (a.scheduled_at,a.id)>(v_at,v_id)) order by a.scheduled_at,a.id limit 101),
 visible as materialized(select * from page order by scheduled_at,id limit 100),
 last_row as(select * from visible order by scheduled_at desc,id desc limit 1)
 select jsonb_build_object('day',p_day,'server_now',statement_timestamp(),'agenda_version',s.agenda_version,
 'items',coalesce((select jsonb_agg(private.medication_application_json(id) order by scheduled_at,id) from visible),'[]'),
 'next_cursor',case when (select count(*) from page)>100 then
 (select replace(encode(convert_to(jsonb_build_object('kind','search_day','filter_hash',md5(p_filter::text),'actor',auth.uid(),'day',p_day,'version',s.agenda_version,'at',scheduled_at,'id',id)::text,'UTF8'),'base64'),E'\n','') from last_row) end)
 into response from snapshot s;
 if c is not null and (response->>'agenda_version')::bigint<>v_version then raise exception 'snapshot_changed' using errcode='PT409'; end if;
 return response;
end;$$;

revoke all on function public.search_medication_day(text,jsonb,text) from public,anon;
grant execute on function public.search_medication_day(text,jsonb,text) to authenticated;
