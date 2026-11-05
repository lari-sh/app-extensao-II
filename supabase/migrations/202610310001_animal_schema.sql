create table public.animals (
 id uuid primary key default gen_random_uuid(),
 name text not null check (name=btrim(name) and char_length(name) between 1 and 80),
 species text not null check (species in ('dog','cat')),
 sex text not null check (sex in ('female','male')),
 size text not null check (size in ('small','medium','large')),
 approximate_age text not null check (approximate_age=btrim(approximate_age) and char_length(approximate_age) between 1 and 80),
 public_description text not null default '' check (char_length(public_description)<=3000),
 status text not null default 'available' check (status in ('available','treatment','quarantine','adopted')),
 is_published boolean not null default false,
 is_vaccinated boolean not null default false,
 is_neutered boolean not null default false,
 primary_photo_id uuid
);
create index animals_public_catalog on public.animals(name,id) where is_published and status<>'adopted';
create index animals_filters on public.animals(species,size,sex,status);
create table public.animal_internal_details (
 animal_id uuid primary key references public.animals(id) on delete cascade,
 clinical_notes text not null default '' check (char_length(clinical_notes)<=3000),
 created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
 created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create table public.clinical_records (
 id uuid primary key default gen_random_uuid(), animal_id uuid not null references public.animals(id) on delete cascade,
 kind text not null check (kind in ('vaccination','deworming','medication')),
 description text not null check (description=btrim(description) and char_length(description) between 1 and 1000),
 created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
 created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index clinical_records_animal on public.clinical_records(animal_id);
alter table public.animals enable row level security;
alter table public.animal_internal_details enable row level security;
alter table public.clinical_records enable row level security;
revoke all on public.animals,public.animal_internal_details,public.clinical_records from public,anon,authenticated;
grant all on public.animals,public.animal_internal_details,public.clinical_records to service_role;
