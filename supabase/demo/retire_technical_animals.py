"""Retire explicitly identified local examples after verifying presentation photos."""
import argparse
import hashlib
import json
import sys
import uuid
from datetime import datetime, timezone
from pathlib import Path
from urllib.parse import quote, urlencode
from urllib.request import Request, urlopen

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'supabase/tests/fixtures'))

CALENDAR_NAMES = {'Teste de agenda - Nina', 'Teste de agenda - Bento', 'Teste de agenda - Mel'}
TECHNICAL_IDS = {f'00000000-0000-4000-8000-{i:012d}': f'Animal de teste {i:02d}' for i in range(1, 61)}

def retired_ids(rows):
    selected = []
    for row in rows:
        if row['id'] in TECHNICAL_IDS:
            if row['name'] != TECHNICAL_IDS[row['id']] or row['public_description'] != 'Fixture isolada; nunca importar para producao.':
                raise ValueError('Edited technical record requires review')
            selected.append(row['id'])
        elif row['name'] in CALENDAR_NAMES:
            if row.get('clinical_notes') != 'Animal fictício para testes da agenda. Não administrar medicamentos.' or row.get('creator') != 'fixture-staff@example.test':
                raise ValueError('Calendar example ownership not confirmed')
            selected.append(str(uuid.UUID(row['id'])))
    return selected

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--apply', action='store_true')
    args = parser.parse_args()
    # This helper rejects remote projects and requires ALLOW_LOCAL_FIXTURES=true.
    from team_fixture_support import sql, env, base, request
    assert base in ('http://127.0.0.1:54321', 'http://localhost:54321')
    rows = json.loads(sql("select coalesce(json_agg(x),'[]') from (select a.*, d.clinical_notes, u.email creator from public.animals a left join public.animal_internal_details d on d.animal_id=a.id left join auth.users u on u.id=d.created_by order by a.id) x;"))
    targets = retired_ids(rows)
    print('Retired local technical examples:', len(targets))
    if not args.apply or not targets:
        return
    presentation = json.loads((ROOT / '.tools/demo_animals/import-result.json').read_text(encoding='utf-8'))['animals']
    assert len(presentation) == 8
    for animal in presentation:
        assert animal['id'] not in targets
        with urlopen(Request(base + '/functions/v1/animal-photo-read?' + urlencode({'animal_id': animal['id'], 'photo_id': animal['photo_id']}), headers={'apikey': env['SUPABASE_ANON_KEY']}), timeout=40) as response:
            photo = response.read()
            assert len(photo) > 1000 and photo.startswith((b'\xff\xd8', b'\x89PNG'))
    ids = ','.join("'" + str(uuid.UUID(value)) + "'" for value in targets)
    clauses = {
        'public.animals': f'id in ({ids})',
        'public.animal_internal_details': f'animal_id in ({ids})',
        'public.clinical_records': f'animal_id in ({ids})',
        'public.photo_upload_jobs': f'animal_id in ({ids})',
        'public.photo_cleanup_queue': f'job_id in (select id from public.photo_upload_jobs where animal_id in ({ids}))',
        'public.medication_treatments': f'animal_id in ({ids})',
        'public.medication_treatment_revisions': f'treatment_id in (select id from public.medication_treatments where animal_id in ({ids}))',
        'public.medication_applications': f'treatment_id in (select id from public.medication_treatments where animal_id in ({ids}))',
        'public.medication_application_events': f'application_id in (select a.id from public.medication_applications a join public.medication_treatments t on t.id=a.treatment_id where t.animal_id in ({ids}))',
        'public.write_operations': f"result#>>'{{animal,id}}' in (select id::text from public.animals where id in ({ids}))",
        'private.medication_operations': f"result#>>'{{result,treatment,id}}' in (select id::text from public.medication_treatments where animal_id in ({ids})) or result#>>'{{result,application,id}}' in (select a.id::text from public.medication_applications a join public.medication_treatments t on t.id=a.treatment_id where t.animal_id in ({ids}))",
    }
    backup = {table: json.loads(sql(f"select coalesce(json_agg(t),'[]') from {table} t where {clause};")) for table, clause in clauses.items()}
    folder = ROOT / '.tools/demo_animals' / ('retired-' + datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%SZ'))
    folder.mkdir(parents=True)
    (folder / 'records.json').write_text(json.dumps(backup, ensure_ascii=False, indent=2), encoding='utf-8')
    # Preserve all non-target animals and their clinical/photo/medication data byte-for-byte.
    snapshots = {table: sql(f"select coalesce(json_agg(t order by row_to_json(t)::text),'[]') from {table} t where not coalesce(({clause}), false);") for table, clause in clauses.items()}
    (folder / 'remaining-records.json').write_text(json.dumps(snapshots, ensure_ascii=False, indent=2), encoding='utf-8')
    signatures = {table: hashlib.sha256(value.encode()).hexdigest() for table, value in snapshots.items()}
    jobs = backup['public.photo_upload_jobs']
    paths = [job['object_path'] for job in jobs]
    for index, path in enumerate(paths):
        req = Request(base + '/storage/v1/object/authenticated/animal-photos/' + quote(path, safe='/'), headers={'apikey': env['SUPABASE_SERVICE_ROLE_KEY'], 'Authorization': 'Bearer ' + env['SUPABASE_SERVICE_ROLE_KEY']})
        try:
            with urlopen(req, timeout=30) as response:
                (folder / f'photo-{index}.bin').write_bytes(response.read())
        except Exception:
            # Jobs may represent a failed upload without an object. A real attached
            # image must be backed up before deletion.
            assert jobs[index]['state'] != 'attached', 'Attached photo backup failed'
    guard = "select coalesce(json_agg(x),'[]') from (select a.*, d.clinical_notes, u.email creator from public.animals a left join public.animal_internal_details d on d.animal_id=a.id left join auth.users u on u.id=d.created_by order by a.id) x;"
    assert json.loads(sql(guard)) == rows, 'Concurrent change: repeat review'
    deletes = [f"delete from {table} where {clauses[table]};" for table in ['private.medication_operations', 'public.medication_application_events', 'public.medication_applications', 'public.medication_treatment_revisions', 'public.medication_treatments', 'public.write_operations', 'public.photo_cleanup_queue']]
    statement = f"begin; lock table public.animals in share row exclusive mode; update public.animals set primary_photo_id=null where id in ({ids}); update public.photo_upload_jobs set previous_photo_id=null where animal_id in ({ids});" + ''.join(deletes) + f"delete from public.photo_upload_jobs where animal_id in ({ids}); delete from public.animals where id in ({ids}); commit;"
    sql(statement)
    for table, value in snapshots.items():
        # Dependent selectors now return no removed IDs; compare by original PKs
        # through the original complete remaining rows, rather than target joins.
        current = sql(f"select coalesce(json_agg(t order by row_to_json(t)::text),'[]') from {table} t;")
        assert current == value, 'Unexpected non-target changes in ' + table
    if paths:
        request('/storage/v1/object/animal-photos', {'prefixes': paths}, privileged=True, method='DELETE', expected=(200, 201))
    report = {'removed_animals': len(targets), 'remaining_animals': len(rows) - len(targets), 'presentation_photos_verified': 8, 'non_target_sha256': signatures, 'removed_ids': targets}
    (folder / 'result.json').write_text(json.dumps(report, indent=2), encoding='utf-8')
    print('PASS:', len(targets), 'old examples removed;', len(rows)-len(targets), 'animals preserved; backup:', folder)

if __name__ == '__main__':
    main()
