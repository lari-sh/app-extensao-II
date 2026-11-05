begin;
select plan(24);
insert into auth.users(id) values('8c000000-0000-4000-8000-000000000001');
insert into public.animals(id,name,species,sex,size,approximate_age,status)
 select ('8d000000-0000-4000-8000-'||lpad(n::text,12,'0'))::uuid,'Cenário medicação '||n,'dog','female','medium','2 anos',
 case n when 4 then 'quarantine' when 5 then 'adopted' when 6 then 'treatment' else 'available' end
 from generate_series(1,9) n;
insert into public.animal_internal_details(animal_id) select id from public.animals where id::text like '8d000000-0000-4000-8000-%';
create function pg_temp.a(n int) returns uuid language sql as $$ select ('8d000000-0000-4000-8000-'||lpad(n::text,12,'0'))::uuid $$;
create function pg_temp.t(n int,s timestamptz,e timestamptz,pending boolean default false) returns uuid language plpgsql as $$
declare tid uuid:=gen_random_uuid();
begin
 insert into public.medication_treatments(id,animal_id,created_by,updated_by) values(tid,pg_temp.a(n),'8c000000-0000-4000-8000-000000000001','8c000000-0000-4000-8000-000000000001');
 insert into public.medication_treatment_revisions(treatment_id,revision,medication_name,schedule_mode,starts_at,ends_at,fixed_times,created_by)
 values(tid,1,'Cuidados simulados','fixed_times',s,e,array['08:00'],'8c000000-0000-4000-8000-000000000001');
 insert into public.medication_applications(treatment_id,revision,scheduled_at,state,performed_by,performed_at)
 values(tid,1,s,case when pending then 'pending' else 'completed' end,case when pending then null else '8c000000-0000-4000-8000-000000000001'::uuid end,case when pending then null else s end);
 return tid;
end $$;
create temp table status_scenarios(n int,tid uuid);
insert into status_scenarios values
 (1,pg_temp.t(1,clock_timestamp()+interval '1 day',clock_timestamp()+interval '2 days',true)),
 (2,pg_temp.t(2,clock_timestamp()-interval '1 day',clock_timestamp()+interval '1 day',false)),
 (3,pg_temp.t(3,clock_timestamp()-interval '2 days',clock_timestamp()-interval '1 day',true)),
 (4,pg_temp.t(4,clock_timestamp()-interval '1 day',clock_timestamp()+interval '1 day',true)),
 (5,pg_temp.t(5,clock_timestamp()-interval '1 day',clock_timestamp()+interval '1 day',true)),
 (7,pg_temp.t(7,clock_timestamp()-interval '1 day',clock_timestamp()+interval '1 day',false)),
 (7,pg_temp.t(7,clock_timestamp()-interval '1 day',clock_timestamp()+interval '2 days',false)),
 (8,pg_temp.t(8,clock_timestamp()-interval '1 day',clock_timestamp()+interval '1 day',false)),
 (9,pg_temp.t(9,clock_timestamp()-interval '1 day',clock_timestamp()+interval '1 day',true));
select private.sync_animal_medication_status(pg_temp.a(n)) from generate_series(1,9) n;
select is((select status from public.animals where id=pg_temp.a(1)),'available','future prescription does not start care early');
select is((select status from public.animals where id=pg_temp.a(2)),'treatment','active course starts treatment even if doses already completed');
select is((select status from public.animals where id=pg_temp.a(3)),'treatment','overdue pending doses keep treatment after final date');
select is((select status from public.animals where id=pg_temp.a(4)),'quarantine','quarantine takes precedence over active medication');
select is((select status from public.animals where id=pg_temp.a(5)),'adopted','adopted animal is not silently reactivated');
select is((select status from public.animals where id=pg_temp.a(6)),'treatment','manual treatment without medication is not released');
update public.medication_treatment_revisions set ends_at=clock_timestamp()-interval '1 hour' where treatment_id in(select tid from status_scenarios where n=2);
select private.sync_animal_medication_status(pg_temp.a(2));
select is((select status from public.animals where id=pg_temp.a(2)),'available','completed course returns to available after end');
select is((select count(*)::int from private.animal_medication_status_events where animal_id=pg_temp.a(2)),2,'automatic transitions recorded once each');
select private.sync_animal_medication_status(pg_temp.a(2));
select is((select count(*)::int from private.animal_medication_status_events where animal_id=pg_temp.a(2)),2,'repeated sweep is idempotent');
update public.medication_applications set state='completed',performed_by='8c000000-0000-4000-8000-000000000001',performed_at=clock_timestamp() where treatment_id in(select tid from status_scenarios where n=3);
select private.sync_animal_medication_status(pg_temp.a(3));
select is((select status from public.animals where id=pg_temp.a(3)),'available','resolving last overdue dose permits release');
update public.medication_applications set state='pending',performed_by=null,performed_at=null where treatment_id in(select tid from status_scenarios where n=3);
select private.sync_animal_medication_status(pg_temp.a(3));
select is((select status from public.animals where id=pg_temp.a(3)),'treatment','reversal reopens care for overdue dose');
update public.medication_treatment_revisions set ends_at=clock_timestamp()-interval '1 hour' where treatment_id=(select min(tid::text)::uuid from status_scenarios where n=7);
select private.sync_animal_medication_status(pg_temp.a(7));
select is((select status from public.animals where id=pg_temp.a(7)),'treatment','another ongoing medication prevents release');
update public.medication_treatment_revisions set ends_at=clock_timestamp()-interval '1 hour' where treatment_id in(select tid from status_scenarios where n=7);
select private.sync_animal_medication_status(pg_temp.a(7));
select is((select status from public.animals where id=pg_temp.a(7)),'available','all courses ended and no pending doses releases');
update public.medication_treatments set status='stopped',stopped_at=clock_timestamp() where animal_id in(pg_temp.a(8),pg_temp.a(9));
select private.sync_animal_medication_status(pg_temp.a(8));
select private.sync_animal_medication_status(pg_temp.a(9));
select is((select status from public.animals where id=pg_temp.a(8)),'available','stopped course without pending doses releases');
select is((select status from public.animals where id=pg_temp.a(9)),'treatment','stopping course does not erase overdue pending doses');
select ok(not has_function_privilege('anon','private.sync_animal_medication_status(uuid)','execute'),'visitor cannot invoke automation');
select ok(not has_function_privilege('authenticated','private.refresh_animal_medication_statuses()','execute'),'staff cannot force scheduled execution or inject server time');
select ok(not has_table_privilege('authenticated','private.animal_medication_status','select'),'private automation state is not exposed');
select is((select count(*)::int from cron.job where jobname='animal-medication-status' and schedule='* * * * *' and active),1,'one active minute job registered');
-- Flush deferred hooks, then prove that later ordinary mutations drive the rule.
set constraints medication_status_treatment_sync,medication_status_revision_sync,medication_status_application_sync,medication_status_animal_sync immediate;
update public.medication_treatment_revisions set starts_at=clock_timestamp()-interval '1 hour',ends_at=clock_timestamp()+interval '1 hour' where treatment_id in(select tid from status_scenarios where n=1);
select is((select status from public.animals where id=pg_temp.a(1)),'treatment','revision trigger starts eligible medication automatically');
update public.animals set status='quarantine' where id=pg_temp.a(1);
select is((select status from public.animals where id=pg_temp.a(1)),'quarantine','manual quarantine is respected during treatment');
update public.animals set status='available' where id=pg_temp.a(1);
select is((select status from public.animals where id=pg_temp.a(1)),'treatment','cannot make ongoing medication available via manual status alone');
select lives_ok('select private.refresh_animal_medication_statuses()','scheduled sweep works without a client session');
insert into auth.sessions(id,user_id) values('8e000000-0000-4000-8000-000000000001','8c000000-0000-4000-8000-000000000001');
insert into public.staff_members(user_id,active) values('8c000000-0000-4000-8000-000000000001',true);
select set_config('request.jwt.claims','{"sub":"8c000000-0000-4000-8000-000000000001","session_id":"8e000000-0000-4000-8000-000000000001","role":"authenticated"}',true);
select is(public.set_animal_status(repeat('Z',32),pg_temp.a(1),'available')->>'status','treatment','manual status response matches reconciled server state');
select * from finish();
rollback;
