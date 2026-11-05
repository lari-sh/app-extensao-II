begin;
-- 006-FR-008: additive immutable server-generated identifiers; UUIDs stay unchanged.
lock table public.animals in access exclusive mode;
create sequence private.animal_code_sequence as bigint minvalue 1;
revoke all on sequence private.animal_code_sequence from public,anon,authenticated,service_role;

create function private.format_animal_code(p_number bigint) returns text
language plpgsql immutable set search_path='' as $$
begin
 if p_number is null or p_number<1 then
  raise exception using errcode='22023',message='invalid_animal_code_number';
 end if;
 return 'A'||pg_catalog.lpad(p_number::text,greatest(4,pg_catalog.length(p_number::text)),'0');
end;
$$;
revoke all on function private.format_animal_code(bigint) from public,anon,authenticated,service_role;

alter table public.animals add column animal_code text;
update public.animals a set animal_code=private.format_animal_code(n.number)
 from (select id,row_number() over(order by id) as number from public.animals) n where a.id=n.id;
select pg_catalog.setval('private.animal_code_sequence'::regclass,
 greatest(1,(select count(*) from public.animals)),exists(select 1 from public.animals));
alter table public.animals alter column animal_code set not null;
alter table public.animals add constraint animals_animal_code_unique unique(animal_code),
 add constraint animals_animal_code_format check (
 animal_code ~ '^(A[0-9]{4}|A[1-9][0-9]{4,18})$' and animal_code<>'A0000');

create function private.assign_animal_code() returns trigger
language plpgsql security definer set search_path='' as $$
begin
 if TG_OP='INSERT' then
  if NEW.animal_code is not null then
   raise exception using errcode='22023',message='animal_code_server_generated';
  end if;
  NEW.animal_code:=private.format_animal_code(pg_catalog.nextval('private.animal_code_sequence'::regclass));
 elsif NEW.animal_code is distinct from OLD.animal_code then
  raise exception using errcode='22023',message='animal_code_immutable';
 end if;
 return NEW;
end;
$$;
revoke all on function private.assign_animal_code() from public,anon,authenticated,service_role;
create trigger animal_code_guard before insert or update of animal_code on public.animals
 for each row execute function private.assign_animal_code();
comment on column public.animals.animal_code is
 'Immutable server-generated readable identifier. UUID remains the primary key. Gaps allowed; no reuse.';
commit;
