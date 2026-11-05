begin;
select plan(21);
insert into auth.users(id) values ('53000000-0000-4000-8000-000000000001');
insert into auth.sessions(id,user_id) values ('63000000-0000-4000-8000-000000000001','53000000-0000-4000-8000-000000000001');
insert into public.staff_members(user_id,active) values ('53000000-0000-4000-8000-000000000001',true);
select set_config('request.jwt.claims','{"sub":"53000000-0000-4000-8000-000000000001","session_id":"63000000-0000-4000-8000-000000000001","role":"authenticated"}',true);
insert into public.animals(id,name,species,sex,size,approximate_age) values ('73000000-0000-4000-8000-000000000001','Manejo','dog','female','small','2 anos');
insert into public.animal_internal_details(animal_id,clinical_notes) values ('73000000-0000-4000-8000-000000000001','Preservar');
set local role authenticated;
select is((public.set_animal_publication(repeat('a',32),'73000000-0000-4000-8000-000000000001',true)->>'is_published'),'true','publish confirmed');
select is((public.set_animal_status(repeat('b',32),'73000000-0000-4000-8000-000000000001','treatment')->>'status'),'treatment','status confirmed');
select is((public.set_animal_status(repeat('b',32),'73000000-0000-4000-8000-000000000001','treatment')->>'status'),'treatment','retry same key');
select throws_ok($$select public.set_animal_status(repeat('b',32),'73000000-0000-4000-8000-000000000001','quarantine')$$,'PT409','operation_conflict','different payload conflict');
select is((public.get_managed_animal('73000000-0000-4000-8000-000000000001')->>'clinical_notes'),'Preservar','notes preserved');
select is((public.set_animal_status(repeat('c',32),'73000000-0000-4000-8000-000000000001','adopted')->>'is_published'),'true','publication independent');
select throws_ok($$select public.set_animal_publication(repeat('d',32),'73000000-0000-4000-8000-000000000001',true)$$,'22023','adopted_publication_denied','adopted cannot publish');
select is((public.set_animal_publication(repeat('e',32),'73000000-0000-4000-8000-000000000001',false)->>'is_published'),'false','can hide adopted');
select is((public.get_write_operation(repeat('c',32))->'animal'->>'status'),'adopted','management result reconciles with aggregate envelope');
select ok((public.get_animal_status_counts()->>'adopted')::int >= 1,'global counts include adopted');
select throws_ok($$select public.set_animal_status(repeat('f',32),'73000000-0000-4000-8000-000000000001','invalid')$$,'22023','invalid_payload','enum validated');
select throws_ok($$update public.animals set status='available' where id='73000000-0000-4000-8000-000000000001'$$,'42501',null,'direct DML denied');
reset role;
-- More than one complete column page, without touching pre-existing records.
insert into public.animals(id,name,species,sex,size,approximate_age)
select ('74000000-0000-4000-8000-'||lpad(n::text,12,'0'))::uuid,'Página manejo '||lpad(n::text,3,'0'),'dog','female','small','2 anos'
from generate_series(1,55) n;
insert into public.animal_internal_details(animal_id) select id from public.animals where id::text like '74000000-0000-4000-8000-%';
set local role authenticated;
select ok((public.get_animal_status_counts()->>'available')::int>=55,'global counts cover more than 50');
select is(jsonb_array_length(public.list_managed_animals('available')->'items'),50,'column first page bounded');
select ok((public.list_managed_animals('available')->>'total')::int>=55,'column total independent of page');
select isnt(public.list_managed_animals('available')->'cursor','null'::jsonb,'first page exposes cursor');
select ok(jsonb_array_length(public.list_managed_animals('available',public.list_managed_animals('available')->'cursor')->'items')>=5,'second column page available');
select is((select count(*)::int from jsonb_array_elements(public.list_managed_animals('available')->'items') a
join jsonb_array_elements(public.list_managed_animals('available',public.list_managed_animals('available')->'cursor')->'items') b
on a->'animal'->>'id'=b->'animal'->>'id'),0,'pages have no duplicated animal');
reset role;
update public.staff_members set active=false where user_id='53000000-0000-4000-8000-000000000001';
set local role authenticated;
select throws_ok($$select public.get_animal_status_counts()$$,'42501','staff_required','counts reauthorize');
select throws_ok($$select public.set_animal_publication(repeat('e',32),'73000000-0000-4000-8000-000000000001',false)$$,'42501','staff_required','replay reauthorizes');
select throws_ok($$select public.set_animal_status(repeat('g',32),'73000000-0000-4000-8000-000000000001','available')$$,'42501','staff_required','status reauthorizes');
select * from finish();
rollback;
