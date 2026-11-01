"""Disposable local-only medication contract journey; never run against a remote project."""
import concurrent.futures
import json
from pathlib import Path
import re
import subprocess
import sys
from urllib.error import HTTPError
from urllib.parse import urlencode, urlparse
from urllib.request import Request, urlopen
import uuid

root = Path(__file__).resolve().parents[3]
environment = {}
for line in (root / 'supabase/.env.local').read_text(encoding='utf-8').splitlines():
    if '=' in line and not line.lstrip().startswith('#'):
        key, value = line.split('=', 1)
        environment[key] = value.strip().strip('"').strip("'")
base = environment['SUPABASE_URL'].rstrip('/')
assert urlparse(base).hostname in ('127.0.0.1', 'localhost')
assert environment.get('ALLOW_LOCAL_FIXTURES') == 'true'
prefix = '000 Fixture calendario medicacao '
project = re.search(r'^project_id\s*=\s*"([A-Za-z0-9_-]+)"', (root / 'supabase/config.toml').read_text(), re.M)[1]
container = 'supabase_db_' + project

def request(path, body=None, token=None, method=None, expected=200, privileged=False):
    key = environment['SUPABASE_SERVICE_ROLE_KEY'] if privileged else environment['SUPABASE_ANON_KEY']
    req = Request(base + path, data=None if body is None else json.dumps(body).encode(), headers={
        'apikey': key, 'Authorization': 'Bearer ' + (token or key), 'Content-Type': 'application/json'}, method=method)
    try:
        with urlopen(req, timeout=45) as response:
            assert response.status == expected
            data = response.read()
            return json.loads(data) if data else None
    except HTTPError as error:
        if error.code == expected:
            return None
        raise RuntimeError('Local medication fixture HTTP status ' + str(error.code)) from None

def rpc(name, payload, token):
    return request('/rest/v1/rpc/' + name, payload, token)

def cleanup(animal_id):
    animal_id = str(uuid.UUID(animal_id))
    # All deletions are atomic because the treatment/revision identity has a deferred FK.
    sql = """begin;
    do $guard$ begin
      if not exists(select 1 from public.animals where id='%s'::uuid and name like '000 Fixture calendario medicacao %%' and primary_photo_id is null) then
        raise exception 'not an owned disposable medication fixture';
      end if;
    end $guard$;
    delete from private.medication_operations where result#>>'{result,treatment,id}' in
      (select id::text from public.medication_treatments where animal_id='%s') or result#>>'{result,application,id}' in
      (select a.id::text from public.medication_applications a join public.medication_treatments t on t.id=a.treatment_id where t.animal_id='%s');
    delete from public.medication_application_events where application_id in
      (select a.id from public.medication_applications a join public.medication_treatments t on t.id=a.treatment_id where t.animal_id='%s');
    delete from public.medication_applications where treatment_id in (select id from public.medication_treatments where animal_id='%s');
    delete from public.medication_treatment_revisions where treatment_id in (select id from public.medication_treatments where animal_id='%s');
    delete from public.medication_treatments where animal_id='%s';
    delete from public.write_operations where result#>>'{animal,id}'='%s';
    delete from public.animals where id='%s';
    commit;
    """ % ((animal_id,) * 9)
    result = subprocess.run(['docker', 'exec', '-i', container, 'psql', '-X', '-v', 'ON_ERROR_STOP=1', '-U', 'postgres', '-d', 'postgres'], input=sql, text=True, capture_output=True, timeout=30)
    if result.returncode:
        raise RuntimeError('Local disposable medication fixture cleanup failed')

def cleanup_owned():
    query = urlencode({'select': 'id,name', 'name': 'like.' + prefix + '*', 'limit': '100'})
    rows = request('/rest/v1/animals?' + query, privileged=True)
    for row in rows:
        assert row['name'].startswith(prefix)
        cleanup(row['id'])
    print('Disposable medication animals removed:', len(rows))

if __name__ == '__main__':
    if '--cleanup' in sys.argv:
        cleanup_owned()
        sys.exit(0)
    sessions = []
    animal_id = None
    try:
        for _ in range(2):
            data = request('/auth/v1/token?grant_type=password', {'email': 'fixture-staff@example.test', 'password': environment['FIXTURE_PASSWORD']})
            sessions.append(data['access_token'])
        created = rpc('save_animal', {'p_operation_key': uuid.uuid4().hex, 'p_payload': {
            'name': prefix + uuid.uuid4().hex[:12], 'species': 'dog', 'sex': 'female', 'size': 'small',
            'approximate_age': '2 anos', 'clinical_notes': 'Nota restrita da fixture de medicação'}}, sessions[0])
        animal_id = created['animal']['id']
        operation = uuid.uuid4().hex
        payload = {'animal_id': animal_id, 'medication_name': 'Medicação de teste', 'instructions': 'Instrução de teste',
                   'schedule_mode': 'fixed_times', 'starts_on': '2026-11-01', 'starts_time': '08:00',
                   'ends_on': '2026-11-02', 'ends_time': '20:00', 'fixed_times': ['20:00', '08:00']}
        with concurrent.futures.ThreadPoolExecutor(max_workers=2) as executor:
            confirmations = list(executor.map(lambda token: rpc('save_medication_treatment', {'p_operation_key': operation, 'p_payload': payload}, token), sessions))
        assert confirmations[0] == confirmations[1]
        treatment_id = confirmations[0]['result']['treatment']['id']
        rows = request('/rest/v1/medication_applications?' + urlencode({'select': 'id', 'treatment_id': 'eq.' + treatment_id}), token=sessions[1])
        assert len(rows) == 4
        page = rpc('list_animal_medication_treatments', {'p_animal_id': animal_id, 'p_cursor': None}, sessions[1])
        assert len(page['items']) == 1 and page['items'][0]['id'] == treatment_id
        receipt = rpc('get_medication_operation', {'p_operation_key': operation}, sessions[1])
        assert receipt == confirmations[0]
        rpc('set_animal_publication', {'p_operation_key': uuid.uuid4().hex, 'p_animal_id': animal_id, 'p_is_published': True}, sessions[0])
        request('/rest/v1/medication_treatments?select=id', expected=401)

        # Independent US2 journey: every page, server civil values and a changed snapshot.
        agenda_payload = {'animal_id': animal_id, 'medication_name': 'Paginação da agenda',
            'schedule_mode':'interval', 'starts_on':'2026-11-03','starts_time':'00:00',
            'ends_on':'2026-11-03','ends_time':'01:40','fixed_times':[],'interval_minutes':1}
        agenda_saved = rpc('save_medication_treatment',{'p_operation_key':uuid.uuid4().hex,'p_payload':agenda_payload},sessions[0])
        agenda_id = agenda_saved['result']['treatment']['id']
        month = rpc('get_medication_calendar_month',{'p_month':'2026-11'},sessions[1])
        assert month['timezone']=='America/Sao_Paulo'
        assert next(day['pending'] for day in month['days'] if day['day']=='2026-11-03')>=101
        first_page = rpc('list_medication_day',{'p_day':'2026-11-03','p_cursor':None},sessions[1])
        assert len(first_page['items'])==100 and first_page['next_cursor']
        all_items = list(first_page['items'])
        cursor = first_page['next_cursor']
        while cursor:
            following = rpc('list_medication_day',{'p_day':'2026-11-03','p_cursor':cursor},sessions[1])
            assert following['agenda_version']==first_page['agenda_version']
            all_items.extend(following['items'])
            cursor = following['next_cursor']
        owned = [item for item in all_items if item['treatment_id']==agenda_id]
        assert len(owned)==101 and len({item['id'] for item in owned})==101
        assert owned[0]['scheduled_local_date']=='2026-11-03' and owned[0]['scheduled_local_time']=='00:00'
        assert owned[-1]['scheduled_local_time']=='01:40'
        changed = dict(agenda_payload, medication_name='Mutação do snapshot',interval_minutes=100)
        rpc('save_medication_treatment',{'p_operation_key':uuid.uuid4().hex,'p_payload':changed},sessions[0])
        request('/rest/v1/rpc/list_medication_day',{'p_day':'2026-11-03','p_cursor':first_page['next_cursor']},sessions[1],expected=409)
        request('/rest/v1/rpc/get_medication_calendar_month',{'p_month':'2026-11'},expected=401)
        print('Medication HTTP PASS: two sessions, replay, full 101-item agenda, civil times, snapshot conflict and visitor denial.')

    finally:
        if animal_id:
            cleanup(animal_id)
        for token in sessions:
            try:
                request('/auth/v1/logout?scope=local', {}, token, expected=204)
            except RuntimeError:
                pass
