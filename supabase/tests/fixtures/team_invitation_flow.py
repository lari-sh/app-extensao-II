"""Real local invitation journey; only unique test-owned fixtures."""
from team_fixture_support import (create_user, sql, suffix, prefix, login, request, uuid, invite,
    email_link, verify_link, users, rpc, time, concurrent, cleanup, env, mails)

try:
    admin_a, admin_email = create_user('admin-a')
    admin_b, _ = create_user('admin-b')
    sql(f"insert into public.staff_members(user_id,active,role,display_name) values('{admin_a}',true,'administrator','Fixture equipe {suffix}'),('{admin_b}',true,'administrator','Fixture equipe {suffix}');")
    actor = login(admin_email)
    request('/functions/v1/team-invitation', {'action': 'invite', 'operation_key': uuid.uuid4().hex, 'name': 'No', 'email': prefix + '-forged@example.test', 'role': 'employee', 'actor_id': admin_b}, actor, expected=400)
    existing, existing_email = create_user('existing')
    request('/functions/v1/team-invitation', {'action': 'invite', 'operation_key': uuid.uuid4().hex, 'name': 'Existing', 'email': existing_email, 'role': 'administrator'}, actor, expected=409)
    email, key, pending = invite(actor, 'employee')
    assert email_link(email)
    count_before = len(mails(email))
    replay = request('/functions/v1/team-invitation', {'action': 'invite', 'operation_key': key, 'name': 'Fixture equipe employee', 'email': email, 'role': 'employee'}, actor)
    assert replay['invitation']['id'] == pending['id'] and len(mails(email)) == count_before
    assert sql("select private.invitation_password_ready('" + pending['id'] + "');") == 'f'
    token = verify_link(email_link(email))
    assert sql("select private.invitation_password_ready('" + pending['id'] + "');") == 'f'
    assert token, 'Invite link must establish recipient session'
    own = rpc('get_my_invitation', {}, token)
    assert own['email'] == email and own['role'] == 'employee'
    command = {'p_expected_generation': own['generation'], 'p_expected_version': own['version'], 'p_operation_key': uuid.uuid4().hex}
    request('/rest/v1/rpc/accept_team_invitation', command, token, expected=400)
    request('/auth/v1/user', {'password': 'weak'}, token, method='PUT', expected=422)
    request('/auth/v1/user', {'password': env['FIXTURE_PASSWORD']}, token, method='PUT')
    accepted = rpc('accept_team_invitation', command, token)
    assert accepted == rpc('accept_team_invitation', command, token)
    assert accepted['member']['role'] == 'employee'
    employee = login(email)
    assert rpc('access_context', {}, employee)['can_manage_team'] is False
    request('/functions/v1/team-invitation', {'action': 'invite', 'operation_key': uuid.uuid4().hex, 'name': 'No', 'email': prefix + '-denied@example.test', 'role': 'administrator'}, employee, expected=403)
    request('/rest/v1/rpc/accept_team_invitation', dict(command, p_role='administrator'), token, expected=404)

    second_email, _, second = invite(actor, 'resend')
    original_link = email_link(second_email)
    resend = {'action': 'resend', 'operation_key': uuid.uuid4().hex, 'invitation_id': second['id'], 'expected_version': second['version']}
    request('/functions/v1/team-invitation', resend, actor, expected=429)
    sql("update private.team_invitations set send_started_at=clock_timestamp()-interval '2 minutes' where id='" + second['id'] + "';")
    time.sleep(1.1)
    resent = request('/functions/v1/team-invitation', resend, actor)
    assert resent['state'] == 'confirmed' and resent['invitation']['generation'] == 2
    assert verify_link(original_link) is None, 'Resent Auth link must reject old token'
    second_token = verify_link(email_link(second_email))
    assert second_token
    cancelled = rpc('cancel_team_invitation', {'p_invitation_id': second['id'], 'p_expected_version': resent['invitation']['version'], 'p_operation_key': uuid.uuid4().hex}, actor)
    assert cancelled['invitation']['status'] == 'revoked'
    request('/rest/v1/rpc/accept_team_invitation', {'p_expected_generation': 2, 'p_expected_version': resent['invitation']['version'], 'p_operation_key': uuid.uuid4().hex}, second_token, expected=404)

    race_email, _, race = invite(actor, 'race')
    race_token = verify_link(email_link(race_email))
    assert race_token
    request('/auth/v1/user', {'password': env['FIXTURE_PASSWORD']}, race_token, method='PUT')
    def accept_race():
        return request('/rest/v1/rpc/accept_team_invitation', {'p_expected_generation': race['generation'], 'p_expected_version': race['version'], 'p_operation_key': uuid.uuid4().hex}, race_token, expected=(200, 404))
    def cancel_race():
        return request('/rest/v1/rpc/cancel_team_invitation', {'p_invitation_id': race['id'], 'p_expected_version': race['version'], 'p_operation_key': uuid.uuid4().hex}, actor, expected=(200, 409))
    with concurrent.futures.ThreadPoolExecutor(max_workers=2) as pool:
        completed = list(pool.map(lambda action: action(), [accept_race, cancel_race]))
    assert sum(value.get('state') == 'confirmed' for value in completed) == 1
    print('Team HTTP PASS: real local email, callback, password policy, acceptance/replay, employee denial, forged role, resend/old token, cancellation and acceptance race.')
finally:
    cleanup()
