"""Local-only concurrent team authorization check; owns and removes its fixtures."""
import concurrent.futures
import json
from pathlib import Path
import re
import subprocess
import threading
import time
from urllib.parse import urlparse
import uuid

root = Path(__file__).resolve().parents[3]
environment = {}
for line in (root / 'supabase/.env.local').read_text(encoding='utf-8').splitlines():
    if '=' in line and not line.lstrip().startswith('#'):
        key, value = line.split('=', 1)
        environment[key] = value.strip().strip('"').strip("'")
assert environment.get('ALLOW_LOCAL_FIXTURES') == 'true'
assert urlparse(environment['SUPABASE_URL']).hostname in ('localhost', '127.0.0.1')
project = re.search(r'^project_id\s*=\s*"([A-Za-z0-9_-]+)"', (root / 'supabase/config.toml').read_text(), re.M)[1]
container = 'supabase_db_' + project
command = ['docker', 'exec', '-i', container, 'psql', '-X', '-Atq', '-v', 'ON_ERROR_STOP=1', '-U', 'postgres', '-d', 'postgres']


def sql(statement):
    return subprocess.run(command, input=statement, text=True, encoding='utf-8', capture_output=True, timeout=20)


def checked(statement):
    result = sql(statement)
    assert result.returncode == 0, 'Team foundation SQL check failed'
    return result.stdout.strip()


users = [str(uuid.uuid4()), str(uuid.uuid4())]
sessions = [str(uuid.uuid4()), str(uuid.uuid4())]
suffix = uuid.uuid4().hex
operation_keys = [uuid.uuid4().hex, uuid.uuid4().hex]
setup = 'begin;'
for index in range(2):
    setup += f"insert into auth.users(id,email) values('{users[index]}','fixture-team-{suffix}-{index}@example.test');"
    setup += f"insert into auth.sessions(id,user_id,not_after) values('{sessions[index]}','{users[index]}',now()+interval '1 hour');"
    setup += f"insert into public.staff_members(user_id,active,role,display_name) values('{users[index]}',true,'administrator','Fixture equipe fundacao {suffix}');"
setup += 'commit;'
checked(setup)
holder = None
try:
    holder = subprocess.Popen(command, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, encoding='utf-8')
    holder.stdin.write("begin;select pg_advisory_xact_lock(hashtextextended('abrigo.team-members',0));select 'locked';select pg_sleep(5);commit;")
    holder.stdin.close()
    while holder.stdout.readline().strip() != 'locked':
        assert holder.poll() is None, 'Could not hold team lock'
    barrier = threading.Barrier(2)

    def change(index):
        claims = json.dumps({'sub': users[index], 'session_id': sessions[index], 'role': 'authenticated'})
        statement = f"begin;set local role authenticated;select set_config('request.jwt.claims','{claims}',true);"
        statement += f"select public.change_team_member('{users[1-index]}',1,'employee',true,'{operation_keys[index]}');commit;"
        barrier.wait(timeout=10)
        return sql(statement)

    with concurrent.futures.ThreadPoolExecutor(max_workers=2) as pool:
        futures = [pool.submit(change, index) for index in range(2)]
        deadline = time.monotonic() + 4
        waiting = False
        while time.monotonic() < deadline:
            count = checked("select count(*) from pg_stat_activity where query like '%select public.change_team_member%' and wait_event_type='Lock' and pid<>pg_backend_pid();")
            if int(count) == 2:
                waiting = True
                break
            time.sleep(.05)
        assert waiting, 'Both administrators did not queue on the shared lock'
        results = [future.result(timeout=20) for future in futures]
    assert sum(result.returncode == 0 for result in results) == 1
    rejected = next(result for result in results if result.returncode != 0)
    assert 'administrator_required' in rejected.stderr
    ids = ','.join("'" + value + "'" for value in users)
    assert checked(f"select count(*) from public.staff_members where user_id in ({ids}) and active and role='administrator';") == '1'
    assert checked(f"select count(*) from private.team_access_events where actor_id in ({ids}) and action='member_changed';") == '1'
    print('Team concurrency PASS: both administrators waited; one change committed; the demoted actor was denied after lock; one administrator and one audit event remain.')
finally:
    if holder and holder.poll() is None:
        holder.wait(timeout=10)
    ids = ','.join("'" + value + "'" for value in users)
    # The exclusive table lock prevents any other writer from observing the
    # temporary trigger disable; it is restored before the transaction commits.
    cleanup = f"""begin;
    lock table public.staff_members in access exclusive mode;
    do $guard$ begin
      if (select count(*) from public.staff_members where user_id in ({ids})
          and display_name='Fixture equipe fundacao {suffix}')<>2 then
        raise exception 'not owned team fixtures';
      end if;
    end $guard$;
    alter table public.staff_members disable trigger team_member_guard;
    delete from private.team_access_events where actor_id in ({ids});
    delete from private.team_operations where actor_id in ({ids});
    delete from public.staff_members where user_id in ({ids});
    delete from auth.sessions where user_id in ({ids});
    delete from auth.users where id in ({ids}) and email like 'fixture-team-{suffix}-%@example.test';
    alter table public.staff_members enable trigger team_member_guard;
    commit;"""
    checked(cleanup)
