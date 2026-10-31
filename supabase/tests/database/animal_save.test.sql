begin;
select plan(22);
insert into auth.users(id) values ('52000000-0000-4000-8000-000000000001');
insert into auth.sessions(id,user_id) values ('62000000-0000-4000-8000-000000000001','52000000-0000-4000-8000-000000000001');
insert into public.staff_members(user_id,active) values ('52000000-0000-4000-8000-000000000001',true);
select set_config('request.jwt.claims','{"sub":"52000000-0000-4000-8000-000000000001","session_id":"62000000-0000-4000-8000-000000000001","role":"authenticated"}',true);
create temporary table saved(value jsonb);
grant all on saved to authenticated;
set local role authenticated;
insert into saved select public.save_animal('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa','{"name":" Luna ","approximate_age":" 2 anos ","species":"dog","sex":"female","size":"medium","clinical_notes":"privado","care_records":[{"kind":"vaccination","description":" Vacina registrada "}]}');
select is((select value->'animal'->>'name' from saved),'Luna','server trims name');
select is((select value->'animal'->>'is_published' from saved),'false','new animal private');
select is((select value->>'clinical_notes' from saved),'privado','notes committed');
select is((select jsonb_array_length(value->'care_records') from saved),1,'care committed atomically');
select is(public.save_animal('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa','{"name":"Luna","approximate_age":"2 anos","species":"dog","sex":"female","size":"medium","clinical_notes":"privado","care_records":[{"kind":"vaccination","description":"Vacina registrada"}]}'),(select value from saved),'same normalized payload returns exact result');
select throws_ok($$select public.save_animal('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa','{"name":"Outro","approximate_age":"2 anos","species":"dog","sex":"female","size":"medium"}')$$,'PT409','operation_conflict','same key different payload conflicts');
select is(public.get_write_operation('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'),(select value from saved),'lost response reconciled');
select throws_ok($$select public.save_animal('bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb','{"name":"","approximate_age":"2 anos","species":"dog","sex":"female","size":"medium"}')$$,'22023','invalid_payload','invalid name rejected');
select throws_ok($$select public.save_animal('cccccccccccccccccccccccccccccccc','{"name":"Rollback","approximate_age":"2 anos","species":"dog","sex":"female","size":"medium","care_records":[{"kind":"medication","description":""}]}')$$,'22023','invalid_payload','invalid care rejects whole write');
select is(public.get_write_operation('cccccccccccccccccccccccccccccccc'),null::jsonb,'failed write has no operation');
select throws_ok($$select public.save_animal('dddddddddddddddddddddddddddddddd','{"name":"Luna","approximate_age":"2 anos","species":"dog","sex":"female","size":"medium","is_published":true}')$$,'22023','invalid_payload','privileged field forbidden');
reset role;
select is((select count(*)::int from public.animals where name='Rollback'),0,'no partial animal after rollback');
select is((select created_by::text from public.animal_internal_details where animal_id=(select (value->'animal'->>'id')::uuid from saved)),'52000000-0000-4000-8000-000000000001','author from server');
create function pg_temp.reject_test_care() returns trigger language plpgsql as $$
begin
 if new.description='forced failure' then raise exception 'forced_write_failure'; end if;
 return new;
end;
$$;
create trigger test_care_failure before insert on public.clinical_records for each row execute function pg_temp.reject_test_care();
set local role authenticated;
select throws_ok(format('select public.save_animal(%L,%L::jsonb)','eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee',
 jsonb_build_object('id',(select value->'animal'->>'id' from saved),'name','Must rollback','approximate_age','1','species','dog','sex','female','size','small','clinical_notes','changed','care_records',jsonb_build_array(jsonb_build_object('kind','medication','description','forced failure')))),
 'P0001','forced_write_failure','failure after animal update rolls back aggregate');
select is((public.get_managed_animal((select (value->'animal'->>'id')::uuid from saved))->'animal'->>'name'),'Luna','animal unchanged after mid-transaction failure');
select is((public.get_managed_animal((select (value->'animal'->>'id')::uuid from saved))->>'clinical_notes'),'privado','notes unchanged after mid-transaction failure');
select is((public.get_managed_animal((select (value->'animal'->>'id')::uuid from saved))->'care_records'->0->>'description'),'Vacina registrada','previous care retained after failure');
select lives_ok(format('select public.save_animal(%L,%L::jsonb)','ffffffffffffffffffffffffffffffff',
 jsonb_build_object('name',repeat('🐾',80),'approximate_age',repeat('a',80),'species','cat','sex','male','size','small','public_description',repeat('a',3000),'clinical_notes',repeat('a',3000),'care_records',jsonb_build_array(jsonb_build_object('kind','deworming','description',repeat('a',1000))))),'exact character limits accepted');
select throws_ok(format('select public.save_animal(%L,%L::jsonb)','gggggggggggggggggggggggggggggggg',
 jsonb_build_object('name',repeat('a',81),'approximate_age','1','species','dog','sex','female','size','small')),'22023','invalid_payload','81 character name denied');
select throws_ok(format('select public.save_animal(%L,%L::jsonb)','hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh',
 jsonb_build_object('name','Name','approximate_age','1','species','dog','sex','female','size','small','public_description',repeat('a',3001))),'22023','invalid_payload','3001 character description denied');
reset role;
update public.staff_members set active=false where user_id='52000000-0000-4000-8000-000000000001';
set local role authenticated;
select throws_ok($$select public.get_write_operation('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')$$,'42501','staff_required','reconciliation checks current membership');
reset role;
select ok(not has_table_privilege('authenticated','public.write_operations','SELECT'),'operation results not directly readable');
select * from finish();
rollback;
