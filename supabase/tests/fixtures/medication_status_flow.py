"""Local authenticated journey for automatic animal management; owned rows only."""
import sys
import uuid
from datetime import date, timedelta
from team_fixture_support import login, rpc, request, sql
from medication_flow import cleanup

animals = []
token = None

def key(): return uuid.uuid4().hex

def read(animal):
    return rpc('get_managed_animal', {'p_animal_id': animal}, token)['animal']['status']

def create(label, status='available'):
    animal = rpc('save_animal', {'p_operation_key': key(), 'p_payload': {'name': '000 Fixture calendario medicacao status ' + label + ' ' + key()[:12], 'species': 'dog', 'sex': 'female', 'size': 'medium', 'approximate_age': '2 anos'}}, token)['animal']['id']
    animals.append(animal)
    if status != 'available': rpc('set_animal_status', {'p_operation_key': key(), 'p_animal_id': animal, 'p_status': status}, token)
    return animal

def prescribe(animal, start, end):
    return rpc('save_medication_treatment', {'p_operation_key': key(), 'p_payload': {'animal_id': animal, 'medication_name': 'Cuidados simulados', 'instructions': 'Teste isolado; não administrar.', 'schedule_mode': 'fixed_times', 'starts_on': start, 'starts_time': '08:00', 'ends_on': end, 'ends_time': '20:00', 'fixed_times': ['08:00']}}, token)['result']['treatment']

try:
    token = login('fixture-staff@example.test')
    today = date.fromisoformat(rpc('get_medication_calendar_month', {'p_month': date.today().strftime('%Y-%m')}, token)['shelter_today'])
    yesterday = (today - timedelta(days=1)).isoformat()
    tomorrow = (today + timedelta(days=1)).isoformat()
    animal = create('fim')
    treatment = prescribe(animal, yesterday, yesterday)
    assert read(animal) == 'treatment', 'expired pending care must still require treatment'
    application = request('/rest/v1/medication_applications?treatment_id=eq.' + treatment['id'] + '&select=id,version', token=token)[0]
    done = rpc('complete_medication_application', {'p_operation_key': key(), 'p_application_id': application['id'], 'p_expected_version': application['version']}, token)['result']['application']
    assert done['performed_by'] and done['performed_at']
    assert read(animal) == 'available', 'last pending completed after end must release'
    reversed_result = rpc('reverse_medication_completion', {'p_operation_key': key(), 'p_application_id': application['id'], 'p_expected_version': done['version'], 'p_reason': 'Correção de teste: verificar retomada do tratamento.'}, token)
    assert read(animal) == 'treatment', 'reversal must reopen treatment'
    future = create('futuro')
    prescribe(future, tomorrow, (today+timedelta(days=2)).isoformat())
    assert read(future) == 'available'
    quarantine = create('quarentena', 'quarantine')
    prescribe(quarantine, yesterday, tomorrow)
    assert read(quarantine) == 'quarantine'
    manual = create('manual', 'treatment')
    assert read(manual) == 'treatment'
    forbidden = request('/rest/v1/rpc/refresh_animal_medication_statuses', {}, expected=(404, 401, 403))
    assert int(sql("select count(*) from cron.job where jobname='animal-medication-status' and active")) == 1
    print('Automatic status HTTP PASS: past pending -> treatment; completion -> available with server actor/time; reversal -> treatment; future unchanged; quarantine and manual care preserved; automation not public.')
finally:
    for animal in reversed(animals): cleanup(animal)
    if token: request('/auth/v1/logout?scope=local', {}, token, expected=204)
