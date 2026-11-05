begin;
create extension if not exists pgtap with schema extensions;
select no_plan();
select has_table('public', 'animals', 'public animal table exists');
select has_table('public', 'animal_internal_details', 'clinical data separated');
select hasnt_column('public', 'animals', 'clinical_notes', 'no private notes in public select=*');
select hasnt_column('public', 'animals', 'created_by', 'no actor metadata in public table');
select ok(not has_table_privilege('authenticated','public.animals','INSERT'), 'no direct insert');
select ok(not has_table_privilege('authenticated','public.animals','UPDATE'), 'no direct update');
select ok(not has_table_privilege('authenticated','public.staff_members','SELECT'), 'staff list not accessible');
select ok(not has_table_privilege('anon','public.photo_upload_jobs','SELECT'), 'photo jobs private');
select ok(not has_table_privilege('authenticated','public.photo_upload_jobs','UPDATE'), 'photo state server only');
insert into auth.users(id) values ('20000000-0000-4000-8000-000000000001'), ('20000000-0000-4000-8000-000000000002');
insert into auth.sessions(id,user_id,not_after) values
 ('30000000-0000-4000-8000-000000000001','20000000-0000-4000-8000-000000000001',now()+interval '1 hour'),
 ('30000000-0000-4000-8000-000000000002','20000000-0000-4000-8000-000000000002',now()+interval '1 hour');
insert into public.staff_members(user_id,active) values ('20000000-0000-4000-8000-000000000001',true);
insert into public.animals(id,name,species,sex,size,approximate_age,is_published,status) values
 ('40000000-0000-4000-8000-000000000001','Public','dog','female','medium','2 anos',true,'available'),
 ('40000000-0000-4000-8000-000000000002','Private','cat','male','small','1 ano',false,'treatment'),
 ('40000000-0000-4000-8000-000000000003','Adopted','dog','male','large','3 anos',true,'adopted');
insert into public.animal_internal_details(animal_id,clinical_notes) values ('40000000-0000-4000-8000-000000000001','Private note');
set local role anon;
select is((select count(*)::integer from public.animals where id::text like '40000000-%'),1,'anon sees published non adopted only');
select is((select count(*)::integer from public.animal_internal_details where animal_id::text like '40000000-%'),0,'anon reads zero internal rows');
select throws_ok($$insert into public.staff_members(user_id,active) values ('20000000-0000-4000-8000-000000000002',true)$$, '42501', null, 'self approval forbidden');
reset role;
select set_config('request.jwt.claims','{"sub":"20000000-0000-4000-8000-000000000002","session_id":"30000000-0000-4000-8000-000000000002","role":"authenticated"}',true);
set local role authenticated;
select is((select count(*)::integer from public.animals where id::text like '40000000-%'),1,'nonstaff sees public only');
select is((select count(*)::integer from public.animal_internal_details where animal_id::text like '40000000-%'),0,'nonstaff sees zero private rows');
select is((public.access_context()->>'is_staff_active')::boolean,false,'nonstaff denied');
reset role;
select set_config('request.jwt.claims','{"sub":"20000000-0000-4000-8000-000000000001","session_id":"30000000-0000-4000-8000-000000000001","role":"authenticated"}',true);
set local role authenticated;
select is((select count(*)::integer from public.animals where id::text like '40000000-%'),3,'active staff sees management rows');
select is((select count(*)::integer from public.animal_internal_details where animal_id::text like '40000000-%'),1,'staff sees notes');
select is((public.access_context()->>'is_staff_active')::boolean,true,'staff verified');
reset role;
update public.staff_members set active=false where user_id='20000000-0000-4000-8000-000000000001';
set local role authenticated;
select is((select count(*)::integer from public.animals where id::text like '40000000-%'),1,'membership revocation effective immediately');
select is((select count(*)::integer from public.animal_internal_details where animal_id::text like '40000000-%'),0,'revocation hides notes');
reset role;
update public.staff_members set active=true where user_id='20000000-0000-4000-8000-000000000001';
delete from auth.sessions where id='30000000-0000-4000-8000-000000000001';
set local role authenticated;
select is((public.access_context()->>'is_staff_active')::boolean,false,'revoked JWT session rejected');
select is((select count(*)::integer from public.animal_internal_details where animal_id::text like '40000000-%'),0,'revoked session cannot read notes');
reset role;
select set_config('request.jwt.claims','{"sub":"20000000-0000-4000-8000-000000000001","session_id":"invalid"}',true);
set local role authenticated;
select is((public.access_context()->>'is_staff_active')::boolean,false,'malformed session fails closed');
reset role;
select * from finish();
rollback;
