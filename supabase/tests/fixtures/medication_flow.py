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


def validate_completion(animal_id, sessions):
    """Two actors, real row-lock waits, replay and revoked access; local fixtures only."""
    import time
    from datetime import datetime
    def sql(statement):
        result = subprocess.run(['docker','exec','-i',container,'psql','-X','-At','-v','ON_ERROR_STOP=1','-U','postgres','-d','postgres'],input=statement,encoding='utf-8',capture_output=True,timeout=15)
        assert result.returncode == 0, 'Completion fixture SQL failed'
        return result.stdout.strip()
    second = request('/auth/v1/token?grant_type=password',{'email':'fixture-revocable@example.test','password':environment['FIXTURE_PASSWORD']})['access_token']
    actor_a = str(uuid.UUID(request('/auth/v1/user',token=sessions[0])['id']))
    actor_b = str(uuid.UUID(request('/auth/v1/user',token=second)['id']))
    original_a = request('/rest/v1/staff_members?user_id=eq.'+actor_a+'&select=active,display_name',privileged=True)[0]
    original_b = request('/rest/v1/staff_members?user_id=eq.'+actor_b+'&select=active,display_name',privileged=True)[0]
    def staff(actor, payload):
        request('/rest/v1/staff_members?user_id=eq.'+actor,payload,method='PATCH',expected=204,privileged=True)
    def due():
        saved=rpc('save_medication_treatment',{'p_operation_key':uuid.uuid4().hex,'p_payload':{
            'animal_id':animal_id,'medication_name':'Conclusão descartável','schedule_mode':'fixed_times',
            'starts_on':'2020-01-01','starts_time':'08:00','ends_on':'2020-01-01','ends_time':'09:00','fixed_times':['08:00']}},sessions[0])
        return request('/rest/v1/medication_applications?'+urlencode({'select':'id,version,state,performed_at','treatment_id':'eq.'+saved['result']['treatment']['id']}),token=sessions[0])[0]
    def command(application, key):
        return {'p_operation_key':key,'p_application_id':application['id'],'p_expected_version':application['version']}
    def holder():
        name='fixture_medication_lock_'+uuid.uuid4().hex
        process=subprocess.Popen(['docker','exec','-i',container,'psql','-X','-At','-v','ON_ERROR_STOP=1','-U','postgres','-d','postgres','-c',
          "set application_name='"+name+"';begin;select id from public.animals where id='"+animal_id+"' for update;select pg_sleep(3);select extract(epoch from clock_timestamp());commit;"],stdout=subprocess.PIPE,stderr=subprocess.PIPE,encoding='utf-8')
        for _ in range(50):
            if sql("select count(*) from pg_stat_activity where application_name='"+name+"' and wait_event='PgSleep';")=='1':
                return process
            time.sleep(.03)
        process.communicate(timeout=10)
        raise AssertionError('Could not observe fixture row lock')
    def wait_for_request():
        for _ in range(50):
            if int(sql("select count(*) from pg_stat_activity where query like '%complete_medication_application%' and wait_event_type='Lock';"))>0:
                return
            time.sleep(.03)
        raise AssertionError('Completion request did not wait on row lock')
    try:
        staff(actor_a,{'display_name':'Equipe teste A'})
        staff(actor_b,{'active':True,'display_name':'Equipe teste B'})
        item=due(); key=uuid.uuid4().hex; payload=command(item,key)
        with concurrent.futures.ThreadPoolExecutor(max_workers=2) as pool:
            receipts=list(pool.map(lambda token:rpc('complete_medication_application',payload,token),sessions))
        assert receipts[0]==receipts[1]
        confirmed=receipts[0]['result']['application']
        assert confirmed['performed_by']==actor_a and confirmed['actor_label']=='Equipe teste A'
        assert confirmed['performed_at']==receipts[0]['result']['event']['occurred_at']
        assert rpc('get_medication_operation',{'p_operation_key':key},sessions[1])==receipts[0]
        assert rpc('get_medication_operation',{'p_operation_key':key},second) is None
        history=rpc('get_medication_application_history',{'p_application_id':item['id'],'p_cursor':None},second)
        assert len(history['items'])==1 and history['items'][0]['actor_id']==actor_a
        # Narrow RPC signature rejects forged actor and actual time without any update.
        forged=due(); forge=command(forged,uuid.uuid4().hex)
        request('/rest/v1/rpc/complete_medication_application',dict(forge,p_performed_by=actor_b,p_performed_at='2000-01-01T00:00:00Z'),sessions[0],expected=404)
        assert request('/rest/v1/medication_applications?id=eq.'+forged['id']+'&select=state',token=sessions[0])[0]['state']=='pending'
        # Different actors racing the same expected version: one event, one conflict.
        race=due()
        def compete(token):
            try:return rpc('complete_medication_application',command(race,uuid.uuid4().hex),token)
            except RuntimeError as error:
                assert '409' in str(error)
                return None
        with concurrent.futures.ThreadPoolExecutor(max_workers=2) as pool:
            result=list(pool.map(compete,[sessions[0],second]))
        assert sum(value is not None for value in result)==1
        history=rpc('get_medication_application_history',{'p_application_id':race['id'],'p_cursor':None},sessions[1])
        assert len(history['items'])==1 and history['application']['version']==2
        # Actual time must be captured after waiting, not at request start.
        delayed=due(); process=holder()
        with concurrent.futures.ThreadPoolExecutor(max_workers=1) as pool:
            future=pool.submit(rpc,'complete_medication_application',command(delayed,uuid.uuid4().hex),sessions[0])
            wait_for_request();output,errors=process.communicate(timeout=10);assert process.returncode==0
            released=float(next(line for line in output.splitlines() if re.fullmatch(r'\d+\.\d+',line)))
            completed=future.result()['result']['application']
            assert datetime.fromisoformat(completed['performed_at']).timestamp()>=released
        # Access is rechecked after the same lock wait; no receipt/event on denial.
        revoked=due(); revoke_key=uuid.uuid4().hex; process=holder()
        with concurrent.futures.ThreadPoolExecutor(max_workers=1) as pool:
            future=pool.submit(request,'/rest/v1/rpc/complete_medication_application',command(revoked,revoke_key),second,None,403)
            wait_for_request();staff(actor_b,{'active':False});process.communicate(timeout=10);future.result()
        staff(actor_b,{'active':True})
        assert rpc('get_medication_operation',{'p_operation_key':revoke_key},second) is None
        history=rpc('get_medication_application_history',{'p_application_id':revoked['id'],'p_cursor':None},sessions[0])
        assert history['application']['state']=='pending' and history['items']==[]
        print('Completion HTTP PASS: server actor/time, concurrent replay/race, forged values rejected, time after lock and revocation after wait.')
    finally:
        staff(actor_a,original_a);staff(actor_b,original_b)
        request('/auth/v1/logout?scope=local',{},second,expected=204)


def validate_revision(animal_id, sessions):
    import time
    from datetime import datetime
    def sql(statement):
        result=subprocess.run(['docker','exec','-i',container,'psql','-X','-At','-v','ON_ERROR_STOP=1','-U','postgres','-d','postgres'],input=statement,encoding='utf-8',capture_output=True,timeout=15)
        assert result.returncode==0,'Revision fixture SQL failed'
        return result.stdout.strip()
    def create():
        payload={'animal_id':animal_id,'medication_name':'Revisão descartável','schedule_mode':'fixed_times','starts_on':'2020-01-01','starts_time':'08:00','ends_on':'2020-01-01','ends_time':'20:00','fixed_times':['08:00','09:00','10:00']}
        saved=rpc('save_medication_treatment',{'p_operation_key':uuid.uuid4().hex,'p_payload':payload},sessions[0])['result']['treatment']
        rows=request('/rest/v1/medication_applications?'+urlencode({'select':'id,version,state,scheduled_at','treatment_id':'eq.'+saved['id'],'order':'scheduled_at,id'}),token=sessions[0])
        return saved,rows
    def edit_payload(treatment):
        return {'treatment_id':treatment['id'],'animal_id':animal_id,'expected_revision':treatment['revision'],'expected_treatment_version':treatment['version'],'medication_name':'Série revisada','schedule_mode':'fixed_times','starts_on':'2040-01-01','starts_time':'08:00','ends_on':'2040-01-02','ends_time':'20:00','fixed_times':['08:00','20:00']}
    treatment,rows=create()
    # One pending instant becomes overdue while the editor waits for the animal lock.
    sql("update public.medication_applications set scheduled_at=clock_timestamp()+interval '1 second' where id='"+rows[1]['id']+"';update public.medication_applications set scheduled_at=clock_timestamp()+interval '1 day' where id='"+rows[2]['id']+"';")
    name='fixture_revision_lock_'+uuid.uuid4().hex
    process=subprocess.Popen(['docker','exec','-i',container,'psql','-X','-At','-v','ON_ERROR_STOP=1','-U','postgres','-d','postgres','-c',"set application_name='"+name+"';begin;select id from public.animals where id='"+animal_id+"' for update;select pg_sleep(3);select extract(epoch from clock_timestamp());commit;"],stdout=subprocess.PIPE,stderr=subprocess.PIPE,encoding='utf-8')
    for _ in range(50):
        if sql("select count(*) from pg_stat_activity where application_name='"+name+"' and wait_event='PgSleep';")=='1':break
        time.sleep(.03)
    else:raise AssertionError('Revision lock was not observed')
    with concurrent.futures.ThreadPoolExecutor(max_workers=1) as pool:
        action=pool.submit(rpc,'save_medication_treatment',{'p_operation_key':uuid.uuid4().hex,'p_payload':edit_payload(treatment)},sessions[0])
        for _ in range(50):
            if int(sql("select count(*) from pg_stat_activity where query like '%save_medication_treatment%' and wait_event_type='Lock';"))>0:break
            time.sleep(.03)
        else:raise AssertionError('Revision did not wait for lock')
        output,_=process.communicate(timeout=10);assert process.returncode==0
        released=float(next(line for line in output.splitlines() if re.fullmatch(r'\d+\.\d+',line)))
        edited=action.result()
        assert datetime.fromisoformat(edited['server_now']).timestamp()>=released
    assert edited['result']['cancelled_count']==1
    becoming_due=rpc('get_medication_application_history',{'p_application_id':rows[1]['id'],'p_cursor':None},sessions[1])
    assert becoming_due['application']['state']=='pending' and becoming_due['items']==[]
    treatment=edited['result']['treatment']
    def compete(kind):
        try:
            if kind=='edit':return rpc('save_medication_treatment',{'p_operation_key':uuid.uuid4().hex,'p_payload':edit_payload(treatment)},sessions[0])
            if kind=='stop':return rpc('stop_medication_treatment',{'p_operation_key':uuid.uuid4().hex,'p_treatment_id':treatment['id'],'p_expected_revision':treatment['revision'],'p_expected_treatment_version':treatment['version']},sessions[1])
            return rpc('complete_medication_application',{'p_operation_key':uuid.uuid4().hex,'p_application_id':rows[0]['id'],'p_expected_version':1},sessions[1])
        except RuntimeError as error:
            assert kind!='complete' and '409' in str(error)
            return None
    with concurrent.futures.ThreadPoolExecutor(max_workers=3) as pool:
        raced=list(pool.map(compete,['edit','stop','complete']))
    assert sum(value is not None for value in raced[:2])==1 and raced[2] is not None
    original=raced[2]['result']['event']
    completed=raced[2]['result']['application']
    # A second staff actor corrects; simulate losing the HTTP success body and reconcile.
    data=request('/auth/v1/token?grant_type=password',{'email':'fixture-revocable@example.test','password':environment['FIXTURE_PASSWORD']})
    actor_b=str(uuid.UUID(data['user']['id']));token_b=data['access_token']
    staff=request('/rest/v1/staff_members?user_id=eq.'+actor_b+'&select=active',privileged=True)[0]
    try:
        request('/rest/v1/staff_members?user_id=eq.'+actor_b,{'active':True},method='PATCH',expected=204,privileged=True)
        key=uuid.uuid4().hex; reason='Marcação de teste feita por engano'
        command={'p_operation_key':key,'p_application_id':completed['id'],'p_expected_version':completed['version'],'p_reason':reason}
        rpc('reverse_medication_completion',command,token_b) # Deliberately discard success response.
        receipt=rpc('get_medication_operation',{'p_operation_key':key},token_b)
        assert receipt==rpc('reverse_medication_completion',dict(command,p_reason=' '+reason+' '),token_b)
        history=rpc('get_medication_application_history',{'p_application_id':completed['id'],'p_cursor':None},sessions[0])
        assert history['items'][0]==original and history['items'][1]['actor_id']==actor_b
        assert history['items'][1]['reason']==reason and history['application']['state']=='pending'
    finally:
        request('/rest/v1/staff_members?user_id=eq.'+actor_b,staff,method='PATCH',expected=204,privileged=True)
        request('/auth/v1/logout?scope=local',{},token_b,expected=204)
    # Public changes and general animal save never mutate medication identities/state.
    before=rpc('list_animal_medication_treatments',{'p_animal_id':animal_id,'p_cursor':None},sessions[0])
    before_apps=sql("select md5(coalesce(jsonb_agg(to_jsonb(a) order by a.id)::text,'')) from public.medication_applications a join public.medication_treatments t on t.id=a.treatment_id where t.animal_id='"+animal_id+"';")
    rpc('set_animal_status',{'p_operation_key':uuid.uuid4().hex,'p_animal_id':animal_id,'p_status':'adopted'},sessions[1])
    animal=rpc('get_managed_animal',{'p_animal_id':animal_id},sessions[1])
    rpc('save_animal',{'p_operation_key':uuid.uuid4().hex,'p_payload':{'id':animal_id,'name':animal['animal']['name'],'species':'dog','sex':'female','size':'small','approximate_age':'2 anos','clinical_notes':animal['clinical_notes']}},sessions[0])
    after=rpc('list_animal_medication_treatments',{'p_animal_id':animal_id,'p_cursor':None},sessions[1])
    assert before==after
    after_apps=sql("select md5(coalesce(jsonb_agg(to_jsonb(a) order by a.id)::text,'')) from public.medication_applications a join public.medication_treatments t on t.id=a.treatment_id where t.animal_id='"+animal_id+"';")
    assert before_apps==after_apps
    request('/rest/v1/medication_applications?select=id',expected=401)
    print('Revision HTTP PASS: cut after lock, overdue preserved, edit/stop/completion race, correction actor/history/replay and adoption/general save isolation.')

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
        validate_completion(animal_id,sessions)
        validate_revision(animal_id,sessions)

    finally:
        if animal_id:
            cleanup(animal_id)
        for token in sessions:
            try:
                request('/auth/v1/logout?scope=local', {}, token, expected=204)
            except RuntimeError:
                pass
