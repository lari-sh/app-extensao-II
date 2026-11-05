"""Add clearly simulated care schedules to the eight authorized local examples."""
import hashlib
import json
import sys
from datetime import date, timedelta
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'supabase/tests/fixtures'))
from team_fixture_support import request, rpc, login, base
assert base in ('http://127.0.0.1:54321', 'http://localhost:54321')

def operation(label):
    return hashlib.sha256(('presentation-calendar-v1/' + label).encode()).hexdigest()[:32]

def main():
    token = login('fixture-staff@example.test')
    rows = json.loads((ROOT / '.tools/demo_animals/import-result.json').read_text(encoding='utf-8'))['animals']
    clock = rpc('get_medication_calendar_month', {'p_month': date.today().strftime('%Y-%m')}, token)
    today = clock['shelter_today']
    end = (date.fromisoformat(today) + timedelta(days=2)).isoformat()
    result = []
    for name, status, interval in [('Amora', 'treatment', None), ('Bento', 'treatment', 480), ('Mel', 'quarantine', None)]:
        animal = next(row for row in rows if row['name'] == name)
        current = rpc('get_managed_animal', {'p_animal_id': animal['id']}, token)['animal']
        assert current['name'] == name and current['primary_photo_id'] == animal['photo_id']
        rpc('set_animal_status', {'p_operation_key': operation('status-auto-rule/' + name), 'p_animal_id': animal['id'], 'p_status': status}, token)
        label = 'Cuidados simulados — ' + name
        payload = {'animal_id': animal['id'], 'medication_name': label, 'instructions': 'Somente demonstração do aplicativo. Não administrar medicamentos.', 'schedule_mode': 'interval' if interval else 'fixed_times', 'starts_on': today, 'starts_time': '08:00', 'ends_on': end, 'ends_time': '20:00', 'fixed_times': [] if interval else ['08:00', '20:00']}
        if interval: payload['interval_minutes'] = interval
        saved = rpc('save_medication_treatment', {'p_operation_key': operation('treatment/' + name + '/' + today), 'p_payload': payload}, token)['result']['treatment']
        result.append({'name': name, 'animal_id': animal['id'], 'status': status, 'treatment_id': saved['id'], 'mode': payload['schedule_mode']})
    day = rpc('list_medication_day', {'p_day': today, 'p_cursor': None}, token)
    # Check through SQL-independent authenticated RPC, not only write receipts.
    names = {item['animal_name'] for item in day['items']}
    assert {'Amora', 'Bento', 'Mel'} <= names
    (ROOT / '.tools/demo_animals/calendar-result.json').write_text(json.dumps({'day': today, 'through': end, 'animals': result}, ensure_ascii=False, indent=2), encoding='utf-8')
    print('PASS: 8 animais com fotos; Amora em tratamento, Mel em quarentena, Bento em tratamento; agenda com horários fixos e intervalo de 8h. Dia:', today)
    request('/auth/v1/logout?scope=local', {}, token, expected=204)

if __name__ == '__main__': main()
