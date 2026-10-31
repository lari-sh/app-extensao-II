begin;
select plan(6);
select ok(not has_function_privilege('anon','public.resolve_photo_read(uuid,uuid,uuid,uuid)','EXECUTE'),'anon cannot resolve storage path');
select ok(not has_function_privilege('authenticated','public.resolve_photo_read(uuid,uuid,uuid,uuid)','EXECUTE'),'authenticated cannot resolve storage path');
select ok(has_function_privilege('service_role','public.resolve_photo_read(uuid,uuid,uuid,uuid)','EXECUTE'),'server can resolve after identity verification');
select ok((select relrowsecurity from pg_class where oid='storage.objects'::regclass),'object RLS enabled');
-- Simulate a future broad allow: the bucket-specific restrictive policy must win.
grant select,insert on storage.objects to authenticated;
create policy fixture_broad_allow on storage.objects for all to authenticated using(true) with check(true);
set local role authenticated;
select is((select count(*)::integer from storage.objects where bucket_id='animal-photos'),0,'restrictive policy blocks direct reads despite a permissive allow');
select throws_ok($$insert into storage.objects(bucket_id,name) values ('animal-photos','fixture-denied-object')$$,'42501',null,'restrictive policy blocks direct insert');
reset role;
select * from finish();
rollback;
