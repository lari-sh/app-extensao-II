-- Medication-driven management stays authoritative even while the app is closed.
create table private.animal_medication_status (
 animal_id uuid primary key references public.animals(id) on delete cascade,
 managed_since timestamptz not null default clock_timestamp()
);
create table private.animal_medication_status_events (
 id bigint generated always as identity primary key,
 animal_id uuid not null references public.animals(id) on delete cascade,
 previous_status text not null,
 next_status text not null,
 occurred_at timestamptz not null default clock_timestamp(),
 reason text not null check(reason in ('medication_requires_care','medication_care_finished'))
);
alter table private.animal_medication_status enable row level security;
alter table private.animal_medication_status_events enable row level security;
revoke all on private.animal_medication_status,private.animal_medication_status_events from public,anon,authenticated,service_role;

create function private.sync_animal_medication_status(p_animal_id uuid) returns void
language plpgsql security definer set search_path='' as $$
declare v_status text; v_now timestamptz; v_needs_care boolean;
begin
 select status into v_status from public.animals where id=p_animal_id for update;
 if not found or v_status in ('quarantine','adopted') then return; end if;
 v_now:=clock_timestamp();
 select exists(
   select 1 from public.medication_treatments t
   join public.medication_treatment_revisions r on r.treatment_id=t.id and r.revision=t.current_revision
   where t.animal_id=p_animal_id and t.status='active' and r.starts_at<=v_now and r.ends_at>=v_now
 ) or exists(
   select 1 from public.medication_applications a join public.medication_treatments t on t.id=a.treatment_id
   where t.animal_id=p_animal_id and a.state='pending' and a.scheduled_at<=v_now
 ) into v_needs_care;
 if v_needs_care then
   insert into private.animal_medication_status(animal_id) values(p_animal_id) on conflict do nothing;
   if v_status='available' then
     update public.animals set status='treatment' where id=p_animal_id;
     insert into private.animal_medication_status_events(animal_id,previous_status,next_status,reason)
       values(p_animal_id,v_status,'treatment','medication_requires_care');
   end if;
 elsif exists(select 1 from private.animal_medication_status where animal_id=p_animal_id) then
   delete from private.animal_medication_status where animal_id=p_animal_id;
   if v_status='treatment' then
     update public.animals set status='available' where id=p_animal_id;
     insert into private.animal_medication_status_events(animal_id,previous_status,next_status,reason)
       values(p_animal_id,v_status,'available','medication_care_finished');
   end if;
 end if;
end; $$;
revoke all on function private.sync_animal_medication_status(uuid) from public,anon,authenticated,service_role;

create function private.refresh_animal_medication_statuses() returns void
language plpgsql security definer set search_path='' as $$
declare v_id uuid;
begin
 if not pg_try_advisory_xact_lock(hashtextextended('animal-medication-status-sweep',0)) then return; end if;
 for v_id in select a.id from public.animals a where a.status in ('available','treatment') and (
   exists(select 1 from public.medication_treatments t where t.animal_id=a.id) or
   exists(select 1 from private.animal_medication_status s where s.animal_id=a.id)
 ) order by a.id loop
   perform private.sync_animal_medication_status(v_id);
 end loop;
end; $$;
revoke all on function private.refresh_animal_medication_statuses() from public,anon,authenticated,service_role;

create function private.medication_status_changed() returns trigger
language plpgsql security definer set search_path='' as $$
declare v_animal uuid;
begin
 if tg_table_name='animals' then v_animal:=coalesce(new.id,old.id);
 elsif tg_table_name='medication_treatments' then v_animal:=coalesce(new.animal_id,old.animal_id);
 else
   select animal_id into v_animal from public.medication_treatments where id=coalesce(new.treatment_id,old.treatment_id);
 end if;
 if v_animal is not null then perform private.sync_animal_medication_status(v_animal); end if;
 return null;
end; $$;
revoke all on function private.medication_status_changed() from public,anon,authenticated,service_role;

create constraint trigger medication_status_treatment_sync after insert or update or delete on public.medication_treatments
 deferrable initially deferred for each row execute function private.medication_status_changed();
create constraint trigger medication_status_revision_sync after insert or update or delete on public.medication_treatment_revisions
 deferrable initially deferred for each row execute function private.medication_status_changed();
create constraint trigger medication_status_application_sync after insert or update or delete on public.medication_applications
 deferrable initially deferred for each row execute function private.medication_status_changed();
create constraint trigger medication_status_animal_sync after update of status on public.animals
 deferrable initially deferred for each row execute function private.medication_status_changed();

-- Partial lookup makes the periodic pending check proportional to open applications.
create index medication_pending_for_status on public.medication_applications(treatment_id,scheduled_at) where state='pending';
create extension if not exists pg_cron;
select cron.schedule('animal-medication-status','* * * * *','select private.refresh_animal_medication_statuses();');
select private.refresh_animal_medication_statuses();
