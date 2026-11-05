-- Private medication identities, immutable revision references and transactional receipts.
alter table public.staff_members add column display_name text,
 add constraint staff_display_name_valid check (display_name is null or
 (display_name=btrim(display_name,E' \t\n\r') and char_length(display_name) between 1 and 120));

create function private.medication_times_valid(p_times text[]) returns boolean
language sql immutable set search_path='' as $$
 select p_times is not null and coalesce(array_ndims(p_times),1)=1 and cardinality(p_times) between 1 and 24
 and not exists(select 1 from unnest(p_times) t where t is null or t !~ '^([01][0-9]|2[0-3]):[0-5][0-9]$')
 and cardinality(p_times)=(select count(distinct t)::int from unnest(p_times) t);
$$;
revoke all on function private.medication_times_valid(text[]) from public,anon,authenticated;
grant execute on function private.medication_times_valid(text[]) to service_role;

create table public.medication_treatments (
 id uuid primary key default gen_random_uuid(),
 animal_id uuid not null references public.animals(id) on delete restrict,
 current_revision integer not null default 1 check (current_revision>=1),
 treatment_version integer not null default 1 check (treatment_version>=1),
 status text not null default 'active' check (status in ('active','stopped')),
 created_by uuid not null references auth.users(id) on delete restrict,
 updated_by uuid not null references auth.users(id) on delete restrict,
 created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
 stopped_at timestamptz,
 check ((status='active' and stopped_at is null) or (status='stopped' and stopped_at is not null))
);
create index medication_treatments_animal on public.medication_treatments(animal_id,created_at,id);

create table public.medication_treatment_revisions (
 treatment_id uuid not null references public.medication_treatments(id) on delete restrict,
 revision integer not null check (revision>=1),
 medication_name text not null check (medication_name=btrim(medication_name,E' \t\n\r') and char_length(medication_name) between 1 and 120),
 instructions text not null default '' check (char_length(instructions)<=1000),
 schedule_mode text not null check (schedule_mode in ('fixed_times','interval')),
 timezone text not null default 'America/Sao_Paulo' check (timezone='America/Sao_Paulo'),
 starts_at timestamptz not null, ends_at timestamptz not null,
 fixed_times text[] not null default '{}', interval_minutes integer,
 created_by uuid not null references auth.users(id) on delete restrict,
 created_at timestamptz not null default now(),
 primary key(treatment_id,revision),
 check (ends_at>starts_at),
 check ((starts_at at time zone 'America/Sao_Paulo')::date between date '2000-01-01' and date '2100-12-31'),
 check ((ends_at at time zone 'America/Sao_Paulo')::date between date '2000-01-01' and date '2100-12-31'),
 check ((ends_at at time zone 'America/Sao_Paulo')::date-(starts_at at time zone 'America/Sao_Paulo')::date between 0 and 365),
 check ((schedule_mode='fixed_times' and interval_minutes is null and private.medication_times_valid(fixed_times))
 or (schedule_mode='interval' and cardinality(fixed_times)=0 and interval_minutes is not null and interval_minutes between 1 and 10080))
);
alter table public.medication_treatments add constraint medication_current_revision_fk
 foreign key(id,current_revision) references public.medication_treatment_revisions(treatment_id,revision)
 deferrable initially deferred;

create table public.medication_applications (
 id uuid primary key default gen_random_uuid(),
 treatment_id uuid not null, revision integer not null,
 scheduled_at timestamptz not null,
 state text not null default 'pending' check (state in ('pending','completed','cancelled')),
 version integer not null default 1 check (version>=1),
 performed_by uuid references auth.users(id) on delete restrict, performed_at timestamptz,
 cancelled_at timestamptz, cancelled_reason text,
 foreign key(treatment_id,revision) references public.medication_treatment_revisions(treatment_id,revision) on delete restrict,
 unique(treatment_id,revision,scheduled_at),
 check ((state='completed' and performed_by is not null and performed_at is not null) or
 (state<>'completed' and performed_by is null and performed_at is null)),
 check ((state='cancelled' and cancelled_at is not null and cancelled_reason is not null and cancelled_reason in ('treatment_changed','treatment_stopped')) or
 (state<>'cancelled' and cancelled_at is null and cancelled_reason is null))
);
create unique index medication_one_active_instant on public.medication_applications(treatment_id,scheduled_at) where state in ('pending','completed');
create index medication_application_day on public.medication_applications(scheduled_at,id);
create index medication_application_treatment on public.medication_applications(treatment_id,scheduled_at);

create table public.medication_application_events (
 id uuid primary key default gen_random_uuid(),
 application_id uuid not null references public.medication_applications(id) on delete restrict,
 event_type text not null check (event_type in ('completed','completion_reversed','cancelled')),
 actor_id uuid not null references auth.users(id) on delete restrict,
 actor_label text not null check (char_length(actor_label) between 1 and 160),
 occurred_at timestamptz not null,
 reason text check (reason is null or char_length(btrim(reason)) between 1 and 500),
 application_version integer not null check (application_version>=1),
 snapshot jsonb not null check (jsonb_typeof(snapshot)='object'),
 unique(application_id,application_version),
 check (event_type<>'completion_reversed' or reason is not null)
);

create table private.medication_operations (
 actor_id uuid not null references auth.users(id) on delete restrict,
 operation_key text not null check (operation_key ~ '^[A-Za-z0-9_-]{32}$'),
 operation_kind text not null check (operation_kind in ('save_treatment','stop_treatment','complete_application','reverse_completion')),
 payload_digest text not null,
 result jsonb not null check (jsonb_typeof(result)='object'),
 created_at timestamptz not null default now(),
 primary key(actor_id,operation_key)
);
create table private.medication_agenda_state (
 singleton boolean primary key default true check (singleton),
 agenda_version bigint not null default 0 check (agenda_version>=0)
);
insert into private.medication_agenda_state(singleton) values (true);

alter table public.medication_treatments enable row level security;
alter table public.medication_treatment_revisions enable row level security;
alter table public.medication_applications enable row level security;
alter table public.medication_application_events enable row level security;
alter table private.medication_operations enable row level security;
alter table private.medication_agenda_state enable row level security;
revoke all on public.medication_treatments,public.medication_treatment_revisions,public.medication_applications,public.medication_application_events,private.medication_operations,private.medication_agenda_state from public,anon,authenticated;
grant select on public.medication_treatments,public.medication_treatment_revisions,public.medication_applications to authenticated;
grant all on public.medication_treatments,public.medication_treatment_revisions,public.medication_applications,public.medication_application_events,private.medication_operations,private.medication_agenda_state to service_role;
create policy medication_staff_read on public.medication_treatments for select to authenticated using (private.is_staff_current());
create policy medication_revision_staff_read on public.medication_treatment_revisions for select to authenticated using (private.is_staff_current());
create policy medication_application_staff_read on public.medication_applications for select to authenticated using (private.is_staff_current());
