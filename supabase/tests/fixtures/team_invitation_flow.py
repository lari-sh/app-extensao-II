"""Real local Auth/email/Function/RPC journey. Never sends to external addresses."""
import concurrent.futures
import html
import json
from pathlib import Path
import re
import subprocess
import time
from urllib.error import HTTPError
from urllib.parse import parse_qs, urlparse
from urllib.request import HTTPRedirectHandler, Request, build_opener, urlopen
import uuid

root = Path(__file__).resolve().parents[3]
env = {}
for line in (root / 'supabase/.env.local').read_text(encoding='utf-8').splitlines():
    if '=' in line and not line.lstrip().startswith('#'):
        key, value = line.split('=', 1)
        env[key] = value.strip().strip('"').strip("'")
base = env['SUPABASE_URL'].rstrip('/')
assert env.get('ALLOW_LOCAL_FIXTURES') == 'true'
assert urlparse(base).hostname in ('127.0.0.1', 'localhost')
assert len(env['FIXTURE_PASSWORD']) >= 12
project = re.search(r'^project_id\s*=\s*"([A-Za-z0-9_-]+)"', (root / 'supabase/config.toml').read_text(), re.M)[1]
container = 'supabase_db_' + project
suffix = uuid.uuid4().hex
prefix = 'fixture-team-' + suffix
users = []
invitations = []
sessions = []


def sql(statement):
    result = subprocess.run(['docker', 'exec', '-i', container, 'psql', '-X', '-Atq', '-v', 'ON_ERROR_STOP=1', '-U', 'postgres', '-d', 'postgres'], input=statement, encoding='utf-8', capture_output=True, timeout=20)
    assert result.returncode == 0, 'Local team fixture SQL failed'
    return result.stdout.strip()


def request(path, body=None, token=None, privileged=False, method=None, expected=200):
    key = env['SUPABASE_SERVICE_ROLE_KEY'] if privileged else env['SUPABASE_ANON_KEY']
    req = Request(base + path, data=None if body is None else json.dumps(body).encode(), headers={
        'apikey': key, 'Authorization': 'Bearer ' + (token or key), 'Content-Type': 'application/json'}, method=method)
    try:
        with urlopen(req, timeout=35) as response:
            status = response.status
            raw = response.read()
    except HTTPError as error:
        status, raw = error.code, error.read()
    value = json.loads(raw) if raw else None
    allowed = expected if isinstance(expected, tuple) else (expected,)
    assert status in allowed, 'Local team request returned HTTP ' + str(status) + ' / ' + str(value.get('code', 'request_failed') if isinstance(value, dict) else 'request_failed')
    return value


def rpc(name, payload, token):
    return request('/rest/v1/rpc/' + name, payload, token)


def create_user(label, confirmed=True):
    email = prefix + '-' + label + '@example.test'
    value = request('/auth/v1/admin/users', {'email': email, 'password': env['FIXTURE_PASSWORD'], 'email_confirm': confirmed}, privileged=True)
    user_id = str(uuid.UUID(value['id']))
    users.append(user_id)
    return user_id, email


def login(email):
    data = request('/auth/v1/token?grant_type=password', {'email': email, 'password': env['FIXTURE_PASSWORD']})
    sessions.append(data['access_token'])
    return data['access_token']


def mails(email):
    with urlopen('http://127.0.0.1:54324/api/v1/messages', timeout=10) as response:
        values = json.load(response)['messages']
    return [item for item in values if any(recipient.get('Address', '').lower() == email for recipient in item.get('To', []))]


def email_link(email):
    for _ in range(30):
        found = mails(email)
        if found:
            with urlopen('http://127.0.0.1:54324/api/v1/message/' + found[0]['ID'], timeout=10) as response:
                message = json.load(response)
            content = html.unescape(message.get('HTML', '') + ' ' + message.get('Text', ''))
            matches = re.findall(r'https?://[^\s"<>]+/auth/v1/verify\?[^\s"<>]+', content)
            assert matches, 'Local invitation email has no verification link'
            return matches[0]
        time.sleep(.2)
    raise AssertionError('Local invitation email was not captured')


class NoRedirect(HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        return None


def verify_link(link):
    assert urlparse(link).hostname in ('localhost', '127.0.0.1')
    try:
        response = build_opener(NoRedirect).open(link, timeout=20)
    except HTTPError as error:
        response = error
    assert response.code in (302, 303), 'Auth must redirect to the app'
    callback = response.headers['Location']
    parsed = urlparse(callback)
    assert parsed.scheme == 'br.org.abrigodosanjos.app' and parsed.netloc == 'auth' and parsed.path == '/invite', 'Invite callback allow-list mismatch'
    fields = parse_qs(parsed.fragment)
    token = fields.get('access_token', [None])[0]
    if token:
        sessions.append(token)
    return token


def invite(admin, label, role='employee'):
    email = prefix + '-' + label + '@example.test'
    key = uuid.uuid4().hex
    result = request('/functions/v1/team-invitation', {'action': 'invite', 'operation_key': key, 'name': 'Fixture equipe ' + label, 'email': email, 'role': role}, admin, expected=(200, 202))
    assert result['state'] == 'confirmed' and result['invitation']['status'] == 'pending', 'Invitation must remain pending'
    invitation = result['invitation']
    invitations.append(invitation['id'])
    user_id = sql("select id from auth.users where email='" + email + "';")
    assert user_id
    users.append(str(uuid.UUID(user_id)))
    assert sql("select count(*) from public.staff_members where user_id='" + user_id + "';") == '0'
    return email, key, invitation


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
    for token in sessions:
        try:
            request('/auth/v1/logout?scope=local', {}, token, expected=(204, 401, 403))
        except Exception:
            pass
    # No user data is removed: every id belongs to a unique email prefix created here.
    owned = sql(f"select id from auth.users where email like '{prefix}-%@example.test';")
    users = list(set(users + owned.splitlines()))
    if users:
        ids = ','.join("'" + str(uuid.UUID(value)) + "'" for value in users)
        sql(f"""begin;lock table public.staff_members in access exclusive mode;
        do $guard$ begin
         if exists(select 1 from auth.users where id in ({ids}) and email not like '{prefix}-%@example.test') then raise exception 'not owned team fixtures';end if;
        end $guard$;
        alter table public.staff_members disable trigger team_member_guard;
        delete from private.team_access_events where actor_id in ({ids}) or target_id in ({ids});
        delete from private.team_operations where actor_id in ({ids});
        delete from private.team_invitations where created_by in ({ids});
        delete from public.staff_members where user_id in ({ids});
        delete from auth.sessions where user_id in ({ids});
        delete from auth.users where id in ({ids});
        alter table public.staff_members enable trigger team_member_guard;commit;""")
