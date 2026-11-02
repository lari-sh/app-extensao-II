begin;
create extension if not exists pgtap with schema extensions;
select no_plan();
insert into auth.users(id,email) values
 ('86000000-0000-4000-8000-000000000001','inviter@example.test'),
 ('86000000-0000-4000-8000-000000000002','invite-employee@example.test'),
 ('86000000-0000-4000-8000-000000000003','existing-team@example.test');
insert into auth.sessions(id,user_id) values
 ('87000000-0000-4000-8000-000000000001','86000000-0000-4000-8000-000000000001'),
 ('87000000-0000-4000-8000-000000000002','86000000-0000-4000-8000-000000000002');
insert into public.staff_members(user_id,active,role) values
 ('86000000-0000-4000-8000-000000000001',true,'administrator'),
 ('86000000-0000-4000-8000-000000000002',true,'employee');
create temporary table invite_case(kind text primary key,value jsonb);
grant all on invite_case to authenticated,service_role;
select ok(not has_function_privilege('authenticated','public.reserve_team_invitation(uuid,uuid,numeric,text,text,jsonb)','EXECUTE'),'client cannot use privileged send reservation');
select ok(not has_function_privilege('anon','public.finish_team_invitation(uuid,uuid,numeric,text,text,uuid,text)','EXECUTE'),'visitor cannot finalize send');
set local role service_role;
select throws_ok($$select public.reserve_team_invitation('86000000-0000-4000-8000-000000000002','87000000-0000-4000-8000-000000000002',9999999999,'invite-employee-001','invite','{"name":"No","email":"no@example.test","role":"administrator"}')$$,'42501','administrator_required','employee denied even through verified server adapter');
select throws_ok($$select public.reserve_team_invitation('86000000-0000-4000-8000-000000000001','87000000-0000-4000-8000-000000000002',9999999999,'invite-forged-0001','invite','{"name":"No","email":"no@example.test","role":"employee"}')$$,'42501','administrator_required','session must belong to actor');
select throws_ok($$select public.reserve_team_invitation('86000000-0000-4000-8000-000000000001','87000000-0000-4000-8000-000000000001',1,'invite-expired-001','invite','{"name":"No","email":"no@example.test","role":"employee"}')$$,'42501','administrator_required','expired JWT denied');
select throws_ok($$select public.reserve_team_invitation('86000000-0000-4000-8000-000000000001','87000000-0000-4000-8000-000000000001',9999999999,'invite-existing-01','invite','{"name":"Existing","email":"existing-team@example.test","role":"employee"}')$$,'PT409','existing_account','existing Auth account cannot be silently linked');
insert into invite_case select 'reservation',public.reserve_team_invitation('86000000-0000-4000-8000-000000000001','87000000-0000-4000-8000-000000000001',9999999999,'invite-valid-00001','invite','{"name":"  Pessoa nova  ","email":"NEW-TEAM@example.test","role":"employee"}');
select is((select (value->>'should_send')::boolean from invite_case where kind='reservation'),true,'new operation sends once');
select is((public.reserve_team_invitation('86000000-0000-4000-8000-000000000001','87000000-0000-4000-8000-000000000001',9999999999,'invite-valid-00001','invite','{"name":"  Pessoa nova  ","email":"NEW-TEAM@example.test","role":"employee"}')->>'should_send')::boolean,false,'replay never repeats external send');
select throws_ok($$select public.reserve_team_invitation('86000000-0000-4000-8000-000000000001','87000000-0000-4000-8000-000000000001',9999999999,'invite-valid-00001','invite','{"name":"Pessoa nova","email":"another@example.test","role":"administrator"}')$$,'PT409','operation_conflict','same key cannot change payload');
reset role;
select is((select count(*) from public.staff_members where user_id not in ('86000000-0000-4000-8000-000000000001','86000000-0000-4000-8000-000000000002') and user_id in(select invited_auth_user_id from private.team_invitations where normalized_email='new-team@example.test')),0::bigint,'reservation never creates active staff');
-- Simulate the Auth server response, with no password set yet.
insert into auth.users(id,email,invited_at,email_confirmed_at,encrypted_password) values
 ('86000000-0000-4000-8000-000000000004','new-team@example.test',clock_timestamp(),null,'');
set local role service_role;
insert into invite_case select 'sent',public.finish_team_invitation('86000000-0000-4000-8000-000000000001','87000000-0000-4000-8000-000000000001',9999999999,'invite-valid-00001','sent','86000000-0000-4000-8000-000000000004',null);
select is((select value->>'state' from invite_case where kind='sent'),'confirmed','confirmed Auth response stored');
select is((select value->'invitation'->>'status' from invite_case where kind='sent'),'pending','sent is not accepted');
reset role;
-- Auth verification creates a temporary password before confirming the email.
update auth.users set encrypted_password='auth-generated-temporary' where id='86000000-0000-4000-8000-000000000004';
update auth.users set email_confirmed_at=clock_timestamp() where id='86000000-0000-4000-8000-000000000004';
insert into auth.sessions(id,user_id,created_at) values ('87000000-0000-4000-8000-000000000004','86000000-0000-4000-8000-000000000004',clock_timestamp());
select set_config('request.jwt.claims','{"sub":"86000000-0000-4000-8000-000000000004","session_id":"87000000-0000-4000-8000-000000000004","role":"authenticated"}',true);
set local role authenticated;
select is(public.get_my_invitation()->>'name','Pessoa nova','recipient sees only own invitation');
select is((public.get_my_invitation()->>'password_ready')::boolean,false,'Auth temporary password is not the recipient-defined password');
select is((public.access_context()->>'invitation_required')::boolean,true,'pending acceptance exposed without staff access');
select is((public.access_context()->>'is_staff_active')::boolean,false,'link session alone does not activate membership');
select throws_ok($$select public.accept_team_invitation(1,2,'accept-no-pass-001')$$,'22023','password_required','client cannot accept before password exists');
reset role;
update auth.users set encrypted_password='fixture-password-hash' where id='86000000-0000-4000-8000-000000000004';
select set_config('request.jwt.claims','{"sub":"86000000-0000-4000-8000-000000000002","session_id":"87000000-0000-4000-8000-000000000002","role":"authenticated"}',true);
set local role authenticated;
select is(public.get_my_invitation(),null::jsonb,'different identity cannot inspect recipient invitation');
select throws_ok($$select public.accept_team_invitation(1,2,'accept-wrong-00001')$$,'PT404','invitation_unavailable','other identity cannot activate invitation');
reset role;
select set_config('request.jwt.claims','{"sub":"86000000-0000-4000-8000-000000000004","session_id":"87000000-0000-4000-8000-000000000004","role":"authenticated"}',true);
set local role authenticated;
select throws_ok($$select public.accept_team_invitation(2,2,'accept-stale-00001')$$,'PT409','invitation_version_conflict','generation cannot be forged');
select lives_ok($$select public.accept_team_invitation(1,2,'accept-valid-00001')$$,'verified recipient accepts atomically');
select lives_ok($$select public.accept_team_invitation(1,2,'accept-valid-00001')$$,'acceptance reply can be reconciled after timeout');
select is((public.access_context()->>'is_staff_active')::boolean,true,'membership active after acceptance');
select is(public.access_context()->>'staff_role','employee','role comes from reserved invitation');
select is((public.access_context()->>'can_manage_team')::boolean,false,'employee acceptance never grants administrator');
reset role;
select is((select count(*) from private.team_access_events where action='invitation_accepted' and target_id='86000000-0000-4000-8000-000000000004'),1::bigint,'replay creates one acceptance audit event');
select is((select role from public.staff_members where user_id='86000000-0000-4000-8000-000000000004'),'employee','protected member role persisted');
select set_config('request.jwt.claims','{"sub":"86000000-0000-4000-8000-000000000001","session_id":"87000000-0000-4000-8000-000000000001","role":"authenticated"}',true);
set local role authenticated;
select throws_ok($$select public.cancel_team_invitation((select (value->>'invitation_id')::uuid from invite_case where kind='reservation'),3,'cancel-accepted-01')$$,'PT409','invitation_unavailable','accepted invitation cannot be cancelled as a pending invite');
select throws_ok($$select public.list_team_invitations('invalid',null)$$,'22023','invalid_invitation_filter','list filter validated');
reset role;
-- Unknown response is durable, and reconciliation never calls Auth again.
set local role service_role;
insert into invite_case select 'uncertain',public.reserve_team_invitation('86000000-0000-4000-8000-000000000001','87000000-0000-4000-8000-000000000001',9999999999,'invite-uncertain01','invite','{"name":"Incerto","email":"uncertain-team@example.test","role":"employee"}');
select is(public.finish_team_invitation('86000000-0000-4000-8000-000000000001','87000000-0000-4000-8000-000000000001',9999999999,'invite-uncertain01','uncertain',null,null)->>'state','pending','unknown send stays pending instead of resending');
reset role;
insert into auth.users(id,email,invited_at,encrypted_password) values ('86000000-0000-4000-8000-000000000005','uncertain-team@example.test',clock_timestamp(),'fixture-password-hash');
set local role service_role;
insert into invite_case select 'reconciled',public.finish_team_invitation('86000000-0000-4000-8000-000000000001','87000000-0000-4000-8000-000000000001',9999999999,'invite-uncertain01','uncertain',null,null);
select is((select value->>'code' from invite_case where kind='reconciled'),'delivery_uncertain','Auth identity found without claiming email delivery');
select throws_ok($$select public.reserve_team_invitation('86000000-0000-4000-8000-000000000001','87000000-0000-4000-8000-000000000001',9999999999,'resend-too-soon01','resend',jsonb_build_object('invitation_id',(select value->>'invitation_id' from invite_case where kind='uncertain'),'expected_version',2))$$,'PT429','invitation_cooldown','resend cooldown enforced in database');
reset role;
update private.team_invitations set send_started_at=clock_timestamp()-interval '2 minutes' where normalized_email='uncertain-team@example.test';
insert into auth.sessions(id,user_id,created_at) values ('87000000-0000-4000-8000-000000000005','86000000-0000-4000-8000-000000000005',clock_timestamp()-interval '1 minute');
set local role service_role;
insert into invite_case select 'resent',public.reserve_team_invitation('86000000-0000-4000-8000-000000000001','87000000-0000-4000-8000-000000000001',9999999999,'resend-current001','resend',jsonb_build_object('invitation_id',(select value->>'invitation_id' from invite_case where kind='uncertain'),'expected_version',2));
reset role;
update auth.users set invited_at=clock_timestamp(),email_confirmed_at=clock_timestamp() where id='86000000-0000-4000-8000-000000000005';
set local role service_role;
select lives_ok($$select public.finish_team_invitation('86000000-0000-4000-8000-000000000001','87000000-0000-4000-8000-000000000001',9999999999,'resend-current001','sent','86000000-0000-4000-8000-000000000005',null)$$,'resend finalized for generation two');
reset role;
select set_config('request.jwt.claims','{"sub":"86000000-0000-4000-8000-000000000005","session_id":"87000000-0000-4000-8000-000000000005","role":"authenticated"}',true);
set local role authenticated;
select is(public.get_my_invitation(),null::jsonb,'old session cannot accept a new generation');
reset role;
insert into auth.sessions(id,user_id,created_at) values ('87000000-0000-4000-8000-000000000015','86000000-0000-4000-8000-000000000005',clock_timestamp());
select set_config('request.jwt.claims','{"sub":"86000000-0000-4000-8000-000000000005","session_id":"87000000-0000-4000-8000-000000000015","role":"authenticated"}',true);
set local role authenticated;
select is((public.get_my_invitation()->>'generation')::integer,2,'new session sees current generation');
reset role;
select set_config('request.jwt.claims','{"sub":"86000000-0000-4000-8000-000000000001","session_id":"87000000-0000-4000-8000-000000000001","role":"authenticated"}',true);
set local role authenticated;
select lives_ok($$select public.cancel_team_invitation((select (value->>'invitation_id')::uuid from invite_case where kind='uncertain'),4,'cancel-pending001')$$,'administrator cancels current pending invitation');
select lives_ok($$select public.cancel_team_invitation((select (value->>'invitation_id')::uuid from invite_case where kind='uncertain'),4,'cancel-pending001')$$,'cancel replay returns original receipt');
reset role;
select set_config('request.jwt.claims','{"sub":"86000000-0000-4000-8000-000000000005","session_id":"87000000-0000-4000-8000-000000000015","role":"authenticated"}',true);
set local role authenticated;
select throws_ok($$select public.accept_team_invitation(2,4,'accept-revoked001')$$,'PT404','invitation_unavailable','revoked invitation cannot activate even with a valid Auth session');
reset role;
-- Recipient expiration and sender revocation are separate checks.
set local role service_role;
insert into invite_case select 'late',public.reserve_team_invitation('86000000-0000-4000-8000-000000000001','87000000-0000-4000-8000-000000000001',9999999999,'invite-late-00001','invite','{"name":"Tarde","email":"late-team@example.test","role":"administrator"}');
reset role;
insert into auth.users(id,email,invited_at,email_confirmed_at,encrypted_password) values
 ('86000000-0000-4000-8000-000000000006','late-team@example.test',clock_timestamp(),clock_timestamp(),'fixture-password-hash');
set local role service_role;
select lives_ok($$select public.finish_team_invitation('86000000-0000-4000-8000-000000000001','87000000-0000-4000-8000-000000000001',9999999999,'invite-late-00001','sent','86000000-0000-4000-8000-000000000006',null)$$,'administrator invitation remains pending, not active');
reset role;
insert into auth.sessions(id,user_id,created_at) values ('87000000-0000-4000-8000-000000000006','86000000-0000-4000-8000-000000000006',clock_timestamp());
update private.team_invitations set expires_at=clock_timestamp()-interval '1 second' where normalized_email='late-team@example.test';
select set_config('request.jwt.claims','{"sub":"86000000-0000-4000-8000-000000000006","session_id":"87000000-0000-4000-8000-000000000006","role":"authenticated"}',true);
set local role authenticated;
select is(public.get_my_invitation()->>'status','expired','expiry shown without granting access');
select throws_ok($$select public.accept_team_invitation(1,2,'accept-expired001')$$,'PT404','invitation_unavailable','expired invitation rejected using server time');
reset role;
set local role service_role;
insert into invite_case select 'revoked-sender',public.reserve_team_invitation('86000000-0000-4000-8000-000000000001','87000000-0000-4000-8000-000000000001',9999999999,'invite-revoke-001','invite','{"name":"Sem envio","email":"revoked-sender@example.test","role":"employee"}');
reset role;
update public.staff_members set role='administrator' where user_id='86000000-0000-4000-8000-000000000002';
update public.staff_members set active=false where user_id='86000000-0000-4000-8000-000000000001';
set local role service_role;
select throws_ok($$select public.finish_team_invitation('86000000-0000-4000-8000-000000000001','87000000-0000-4000-8000-000000000001',9999999999,'invite-revoke-001','uncertain',null,null)$$,'42501','administrator_required','sender access is checked again after external call');
reset role;
select is((select status from private.team_invitations where normalized_email='revoked-sender@example.test'),'preparing','revoked sender cannot finalize or grant membership');
update public.staff_members set active=true where user_id='86000000-0000-4000-8000-000000000001';
do $quota$ declare n integer:=0;begin
 while (select count(*) from private.team_operations where actor_id='86000000-0000-4000-8000-000000000001' and command in ('invite','resend'))<20 loop
  n:=n+1;
  perform public.reserve_team_invitation('86000000-0000-4000-8000-000000000001','87000000-0000-4000-8000-000000000001',9999999999,
   'quota-invitation-'||n,'invite',jsonb_build_object('name','Quota','email','quota-team-'||n||'@example.test','role','employee'));
 end loop;
end $quota$;
set local role service_role;
select throws_ok($$select public.reserve_team_invitation('86000000-0000-4000-8000-000000000001','87000000-0000-4000-8000-000000000001',9999999999,'quota-exceeded-001','invite','{"name":"Quota","email":"quota-over@example.test","role":"employee"}')$$,'PT429','invitation_rate_limited','server quota prevents unlimited privileged email requests');
reset role;
select * from finish();rollback;
