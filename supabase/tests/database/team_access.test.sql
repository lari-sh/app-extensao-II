begin;
create extension if not exists pgtap with schema extensions;
select no_plan();
select has_column('public','staff_members','role','staff role is server-owned');
select has_column('public','staff_members','version','staff access is versioned');
insert into auth.users(id,email,raw_user_meta_data) values
 ('84000000-0000-4000-8000-000000000001','team-admin-a@example.test','{}'),
 ('84000000-0000-4000-8000-000000000002','team-admin-b@example.test','{}'),
 ('84000000-0000-4000-8000-000000000003','team-employee@example.test','{"role":"administrator"}'),
 ('84000000-0000-4000-8000-000000000004','team-invite@example.test','{}');
insert into auth.sessions(id,user_id,not_after) select
 ('85000000-0000-4000-8000-'||lpad(n::text,12,'0'))::uuid,
 ('84000000-0000-4000-8000-'||lpad(n::text,12,'0'))::uuid,now()+interval '1 hour'
 from generate_series(1,3)n;
insert into public.staff_members(user_id,active) values
 ('84000000-0000-4000-8000-000000000003',true);
select is((select role from public.staff_members where user_id='84000000-0000-4000-8000-000000000003'),'employee','default/backfill never promotes employees');
select ok(not has_function_privilege('anon','private.bootstrap_team_administrator(uuid,text,text)','EXECUTE'),'visitor cannot bootstrap');
select ok(not has_function_privilege('authenticated','private.bootstrap_team_administrator(uuid,text,text)','EXECUTE'),'authenticated account cannot bootstrap');
select ok(not has_table_privilege('authenticated','private.team_invitations','SELECT'),'invitation table cannot be read directly');
select ok(not has_table_privilege('anon','private.team_access_events','SELECT'),'visitor cannot read audit');
select ok(not has_table_privilege('authenticated','public.staff_members','UPDATE'),'no direct staff updates');
select throws_ok($$insert into public.staff_members(user_id,role) values ('84000000-0000-4000-8000-000000000004','owner')$$,'23514',null,'unknown roles rejected');

select set_config('request.jwt.claims','{"sub":"84000000-0000-4000-8000-000000000003","session_id":"85000000-0000-4000-8000-000000000003","role":"authenticated","user_metadata":{"role":"administrator"}}',true);
set local role authenticated;
select is(public.access_context()->>'staff_role','employee','editable metadata cannot grant administrator');
select is((public.access_context()->>'can_manage_team')::boolean,false,'employee denied team capability');
select throws_ok($$select public.list_team_members('active',null)$$,'42501','administrator_required','employee cannot list team');
select throws_ok($$select public.change_team_member('84000000-0000-4000-8000-000000000003',1,'administrator',true,'employee-raise-00001')$$,'42501','administrator_required','employee cannot self-promote through RPC');
reset role;

-- Bootstrap only reserves a pending invitation; it does not open private access.
select lives_ok($$select private.bootstrap_team_administrator('84000000-0000-4000-8000-000000000004','team-invite@example.test','Primeira administradora')$$,'technical bootstrap reserves first administrator');
select is((select count(*) from public.staff_members where user_id='84000000-0000-4000-8000-000000000004'),0::bigint,'bootstrap recipient has no active member before acceptance');
select is((select intended_role from private.team_invitations where invited_auth_user_id='84000000-0000-4000-8000-000000000004'),'administrator','bootstrap role is reserved server-side');
select throws_ok($$select private.bootstrap_team_administrator('84000000-0000-4000-8000-000000000004','team-invite@example.test','Outra tentativa')$$,'PT409','bootstrap_already_reserved','bootstrap cannot be repeated as new reservation');

insert into public.staff_members(user_id,active,role) values
 ('84000000-0000-4000-8000-000000000001',true,'administrator'),
 ('84000000-0000-4000-8000-000000000002',true,'administrator');
select set_config('request.jwt.claims','{"sub":"84000000-0000-4000-8000-000000000001","session_id":"85000000-0000-4000-8000-000000000001","role":"authenticated"}',true);
set local role authenticated;
select is(public.access_context()->>'staff_role','administrator','administrator from protected table');
select is((public.access_context()->>'can_manage_team')::boolean,true,'administrator has team capability');
select ok(jsonb_array_length(public.list_team_members('active',null)->'items')>=3,'administrator lists active members');
select throws_ok($$select public.list_team_members('all',null)$$,'22023','invalid_team_filter','list validates filter');
select throws_ok($$select public.change_team_member('84000000-0000-4000-8000-000000000001',1,'employee',false,'self-change-0000001')$$,'PT409','self_access_change_denied','administrator cannot disable or demote own access');
select lives_ok($$select public.change_team_member('84000000-0000-4000-8000-000000000002',1,'employee',true,'demote-admin-000001')$$,'administrator demotes another administrator');
select is((public.get_team_operation('demote-admin-000001')->'member'->>'role'),'employee','receipt records resulting role');
select lives_ok($$select public.change_team_member('84000000-0000-4000-8000-000000000002',1,'employee',true,'demote-admin-000001')$$,'same operation replays despite stale expected version');
select throws_ok($$select public.change_team_member('84000000-0000-4000-8000-000000000002',1,'administrator',true,'demote-admin-000001')$$,'PT409','operation_conflict','key cannot be reused for different payload');
select throws_ok($$select public.change_team_member('84000000-0000-4000-8000-000000000002',1,'employee',false,'stale-version-00001')$$,'PT409','member_version_conflict','stale version rejected');
reset role;
select is((select version from public.staff_members where user_id='84000000-0000-4000-8000-000000000002'),2::bigint,'member version increases exactly once');
select is((select count(*) from private.team_access_events where operation_key='demote-admin-000001'),1::bigint,'replay creates one audit event');
select is((select actor_id from private.team_access_events where operation_key='demote-admin-000001'),'84000000-0000-4000-8000-000000000001'::uuid,'audit author is server identity');
select throws_ok($$update public.staff_members set active=false where user_id='84000000-0000-4000-8000-000000000001'$$,'PT409','last_administrator','last administrator protected even from direct trusted update');
select throws_ok($$delete from public.staff_members where user_id='84000000-0000-4000-8000-000000000001'$$,'PT409','last_administrator','last administrator cannot be deleted');

select set_config('request.jwt.claims','{"sub":"84000000-0000-4000-8000-000000000002","session_id":"85000000-0000-4000-8000-000000000002","role":"authenticated"}',true);
set local role authenticated;
select is((public.access_context()->>'can_manage_team')::boolean,false,'demotion affects still-valid session immediately');
select throws_ok($$select public.get_team_operation('demote-admin-000001')$$,'42501','administrator_required','demoted account cannot inspect team receipts');
reset role;
update auth.sessions set not_after=now()-interval '1 second' where id='85000000-0000-4000-8000-000000000001';
select set_config('request.jwt.claims','{"sub":"84000000-0000-4000-8000-000000000001","session_id":"85000000-0000-4000-8000-000000000001","role":"authenticated"}',true);
set local role authenticated;
select is(public.access_context()->>'staff_role',null::text,'expired session exposes no staff role');
select is((public.access_context()->>'can_manage_team')::boolean,false,'expired administrator denied capability');
reset role;
set local role anon;
select throws_ok($$select public.list_team_members('active',null)$$,'42501',null,'anonymous cannot execute team command');
reset role;
select * from finish();
rollback;
