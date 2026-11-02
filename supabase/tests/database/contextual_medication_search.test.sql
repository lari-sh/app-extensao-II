begin;
select no_plan();
-- Reserved distant fixture range avoids the user's current agenda; never delete
-- unrelated applications to manufacture an empty day/month for these assertions.
do $guard$ begin
 if exists(select 1 from public.medication_applications where scheduled_at>='2095-11-01T00:00:00Z' and scheduled_at<'2096-01-01T00:00:00Z') then
  raise exception 'agenda fixture range is occupied; choose another empty range';
 end if;
end $guard$;
insert into auth.users(id) values ('58000000-0000-4000-8000-000000000001'),('58000000-0000-4000-8000-000000000002');
insert into auth.sessions(id,user_id) values ('68000000-0000-4000-8000-000000000001','58000000-0000-4000-8000-000000000001'),('68000000-0000-4000-8000-000000000002','58000000-0000-4000-8000-000000000002');
insert into public.staff_members(user_id,active) values ('58000000-0000-4000-8000-000000000001',true),('58000000-0000-4000-8000-000000000002',true);
insert into public.animals(id,name,species,sex,size,approximate_age) values ('78000000-0000-4000-8000-000000000001','Fixture agenda','dog','female','small','2');
create temporary table context_test(kind text,value jsonb);grant all on context_test to authenticated;
select set_config('request.jwt.claims','{"sub":"58000000-0000-4000-8000-000000000001","session_id":"68000000-0000-4000-8000-000000000001","role":"authenticated"}',true);
set local role authenticated;
insert into context_test select 'saved',public.save_medication_treatment(repeat('q',32),'{"animal_id":"78000000-0000-4000-8000-000000000001","medication_name":"Agenda","schedule_mode":"interval","starts_on":"2095-11-01","starts_time":"22:20","ends_on":"2095-11-02","ends_time":"00:01","fixed_times":[],"interval_minutes":1}');

reset role;
insert into public.animals(id,name,species,sex,size,approximate_age,color,status) values ('78000000-0000-4000-8000-000000000002','Fixture agenda','cat','male','large','3','branco','available');
update public.animals set color='preto',status='quarantine' where id='78000000-0000-4000-8000-000000000001';
create temporary table search_filter as select jsonb_build_object('query',animal_code,'species','dog','sex','female','color','preto','size','small','status','quarantine') value from public.animals where id='78000000-0000-4000-8000-000000000001';
grant select on search_filter to authenticated;
set local role authenticated;
insert into context_test select 'first',public.search_medication_day('2095-11-01',(select value from search_filter));
select is((select jsonb_array_length(value->'items') from context_test where kind='first'),100,'filtered first page retains all matching medications before pagination');
select ok((select value->>'next_cursor' is null from context_test where kind='first'),'exactly 100 matching applications end without an extra empty page');
select is(jsonb_array_length(public.search_medication_day('2095-11-02',(select value from search_filter))->'items'),2,'date stays on selected day');
select is(jsonb_array_length(public.search_medication_day('2095-11-03',(select value from search_filter))->'items'),0,'no applications never jumps to another day');
select is(jsonb_array_length(public.search_medication_day('2095-11-01','{"query":"absent animal"}')->'items'),0,'missing animal leaves an empty agenda');
select is(jsonb_array_length(public.search_medication_day('2095-11-01','{"query":"Fixture agenda","species":"cat"}')->'items'),0,'homonym without medication cannot show the other animal medication');
select throws_ok($$select public.search_medication_day('2095-11-01','{"mode":"calendar"}')$$,'22023',null,'unknown filter rejected');
select throws_ok($$select public.search_medication_day('2095-11-01','{"species":"invalid"}')$$,'22023',null,'invalid enum rejected even with no matching applications');
select throws_ok($$select public.search_medication_day('2095-11-01','[]')$$,'22023',null,'invalid filter shape rejected');
select throws_ok($$select public.search_medication_day('2095-11-01','{"query":3}')$$,'22023',null,'nontext query rejected');
select is(jsonb_array_length(public.search_medication_day('2095-11-01','{"query":"Fixture%agenda"}')->'items'),0,'wildcards stay literal');
reset role;
set local role anon;
select throws_ok($$select public.search_medication_day('2095-11-01','{}')$$,'42501',null,'anonymous day search denied');
reset role;
select * from finish();rollback;
