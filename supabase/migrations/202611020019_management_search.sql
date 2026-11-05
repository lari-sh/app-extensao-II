-- 006-FR-002/003/006/009: one global, read-only, authorized search.
create function public.search_managed_animals(
 p_query text default null,p_species text default null,p_sex text default null,
 p_color text default null,p_size text default null,p_status text default null,
 p_cursor jsonb default null
) returns jsonb language plpgsql stable security definer set search_path='' as $$
declare
 v_query text:=nullif(btrim(p_query,E' \t\n\r'),'');
 v_color text:=nullif(btrim(p_color,E' \t\n\r'),'');
 v_name_pattern text;v_color_pattern text;v_code text;
 v_after_name text;v_after_id uuid;v_total bigint;v_items jsonb;v_cursor jsonb;
begin
 if not private.is_staff_current() then raise exception using errcode='42501',message='staff_required';end if;
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
 if p_cursor is not null then
  if jsonb_typeof(p_cursor)<>'array' then raise exception using errcode='22023',message='invalid_search_cursor';end if;
  if jsonb_array_length(p_cursor)<>2 or jsonb_typeof(p_cursor->0)<>'string' or jsonb_typeof(p_cursor->1)<>'string'
    or char_length(p_cursor->>0)>80 then raise exception using errcode='22023',message='invalid_search_cursor';end if;
  v_after_name:=p_cursor->>0;
  begin v_after_id:=(p_cursor->>1)::uuid;
  exception when invalid_text_representation then raise exception using errcode='22023',message='invalid_search_cursor';end;
 end if;
 with matched as materialized (
  select a.id,a.name from public.animals a
   where (v_query is null or (v_code is not null and a.animal_code=v_code)
      or (v_code is null and a.name ilike v_name_pattern escape chr(92)))
    and (p_species is null or a.species=p_species)
    and (p_sex is null or a.sex=p_sex)
    and (p_size is null or a.size=p_size)
    and (p_status is null or a.status=p_status)
    and (v_color is null or a.color ilike v_color_pattern escape chr(92))
 ), next_page as (
  select id,name from matched where p_cursor is null or (name,id)>(v_after_name,v_after_id)
   order by name,id limit 26
 ), shown as (
  select id,name from next_page order by name,id limit 25
 )
 select (select count(*) from matched),
  coalesce((select jsonb_agg(private.managed_animal_json(s.id) order by s.name,s.id) from shown s),'[]'::jsonb),
  case when (select count(*) from next_page)>25
   then (select jsonb_build_array(name,id) from shown order by name desc,id desc limit 1)
   else null end into v_total,v_items,v_cursor;
 return jsonb_build_object('items',v_items,'total',v_total,'cursor',v_cursor);
end;
$$;
revoke all on function public.search_managed_animals(text,text,text,text,text,text,jsonb) from public,anon;
grant execute on function public.search_managed_animals(text,text,text,text,text,text,jsonb) to authenticated;
