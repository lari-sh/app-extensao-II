insert into storage.buckets(id,name,public,file_size_limit,allowed_mime_types)
 values('animal-photos','animal-photos',false,5242880,array['image/jpeg','image/png']);
revoke all on storage.objects,storage.buckets from anon,authenticated;
create table public.photo_upload_jobs (
 id uuid primary key default gen_random_uuid(), animal_id uuid not null references public.animals(id),
 actor_id uuid not null references auth.users(id), actor_session_id uuid not null,
 operation_key text not null check(operation_key ~ '^[A-Za-z0-9_-]{32}$'),
 payload_digest text not null, object_path text not null unique,
 detected_mime text check(detected_mime in ('image/jpeg','image/png')),
 byte_size bigint check(byte_size between 1 and 5242880),
 state text not null default 'pending' check(state in ('pending','validated','attached','cleanup_needed','cleaned','failed')),
 previous_photo_id uuid references public.photo_upload_jobs(id),
 created_at timestamptz not null default now(),updated_at timestamptz not null default now(),error_code text,
 unique(actor_id,operation_key)
);
alter table public.animals add constraint animals_primary_photo_fk foreign key(primary_photo_id) references public.photo_upload_jobs(id);
create table public.photo_cleanup_queue (
 job_id uuid primary key references public.photo_upload_jobs(id),object_path text not null unique,
 reason text not null check(reason in ('failed_candidate','superseded')),
 attempts integer not null default 0 check(attempts>=0),next_attempt_at timestamptz not null default now(),
 last_error_code text,completed_at timestamptz
);
alter table public.photo_upload_jobs enable row level security;
alter table public.photo_cleanup_queue enable row level security;
revoke all on public.photo_upload_jobs,public.photo_cleanup_queue from public,anon,authenticated;
grant all on public.photo_upload_jobs,public.photo_cleanup_queue to service_role;
create index photo_jobs_pending on public.photo_upload_jobs(created_at) where state='pending';
create index photo_cleanup_pending on public.photo_cleanup_queue(next_attempt_at) where completed_at is null;
