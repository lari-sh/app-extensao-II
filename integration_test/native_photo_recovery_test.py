"""Disposable local Android debug test: destroy Activity while picker is open.

Install the normal configured debug APK first. Requires the two synthetic media
fixtures prepared with native_picker_driver.py --prepare-media. Never prints credentials or UI dumps.
"""
import argparse
import json
import re
import runpy
import shlex
import subprocess
import time
import uuid
import xml.etree.ElementTree as ET

parser = argparse.ArgumentParser()
parser.add_argument('--adb', required=True)
parser.add_argument('--serial', default='emulator-5554')
args = parser.parse_args()
fixture = runpy.run_path('supabase/tests/fixtures/android_auth_control.py')
api = fixture['api']
package = 'br.org.abrigodosanjos.abrigo_dos_anjos'
password = fixture['environment']['FIXTURE_PASSWORD']
assert password.isascii(), 'Fixture password must be ASCII for Android input automation'
animal_id = str(uuid.uuid4())
name = '000 Validação Android recuperação'


def adb(*commands):
    result = subprocess.run([args.adb, '-s', args.serial, *commands], capture_output=True)
    if result.returncode:
        raise RuntimeError('Android test command failed; arguments omitted')
    return result.stdout.decode('utf-8', errors='replace').strip()


def snapshot():
    adb('shell', 'uiautomator', 'dump', '/sdcard/abrigo-recovery.xml')
    return ET.fromstring(adb('exec-out', 'cat', '/sdcard/abrigo-recovery.xml'))


def text(node, label):
    return label == node.get('text') or label in node.get('content-desc', '').split('\n')


def wait(predicate, timeout=45):
    deadline = time.monotonic()+timeout
    while time.monotonic()<deadline:
        try:
            nodes = [node for node in snapshot().iter('node') if predicate(node)]
            if nodes:
                return nodes
        except (RuntimeError, ET.ParseError):
            pass
        time.sleep(.5)
    raise RuntimeError('Android recovery control did not appear')


def tap(node):
    bounds = list(map(int, re.findall(r'\d+', node.get('bounds', ''))))
    if len(bounds) != 4:
        raise RuntimeError('Invalid control bounds')
    adb('shell', 'input', 'tap', str((bounds[0]+bounds[2])//2), str((bounds[1]+bounds[3])//2))


def label(value):
    tap(wait(lambda node: text(node, value))[0])


def scroll_to(value):
    for _ in range(14):
        matches = [node for node in snapshot().iter('node') if text(node, value)]
        if matches:
            return matches[0]
        adb('shell', 'input', 'swipe', '540', '1830', '540', '850', '300')
    raise RuntimeError('Recovery panel control not found: '+value)


def set_activity_destruction(enabled):
    adb('shell','am','start','-a','android.settings.APPLICATION_DEVELOPMENT_SETTINGS')
    for _ in range(45):
        root=snapshot()
        def is_label(node):
            return "don't keep activities" in node.get('text','').replace('’',"'").lower()
        labels=[node for node in root.iter('node') if is_label(node)]
        if labels:
            rows=[node for node in root.iter('node') if any(is_label(child) for child in node.iter('node')) and any(child.get('checkable')=='true' for child in node.iter('node'))]
            def area(node):
                b=list(map(int,re.findall(r'\d+',node.get('bounds',''))))
                return (b[2]-b[0])*(b[3]-b[1]) if len(b)==4 else 10**12
            row=min(rows,key=area)
            switch=next(node for node in row.iter('node') if node.get('checkable')=='true')
            if (switch.get('checked')=='true')!=enabled:
                tap(labels[0])
            assert adb('shell','settings','get','global','always_finish_activities')==('1' if enabled else '0'), 'Native developer toggle must persist'
            return
        adb('shell','input','swipe','540','2050','540','550','350')
    raise RuntimeError('Native developer Activity option not found')


def cleanup(target=animal_id):
    api('/rest/v1/animals?id=eq.'+target, {'primary_photo_id': None}, 'PATCH')
    jobs = api('/rest/v1/photo_upload_jobs?animal_id=eq.'+target+'&select=id,object_path')
    for job in jobs:
        api('/storage/v1/object/animal-photos', {'prefixes': [job['object_path']]}, 'DELETE')
        api('/rest/v1/photo_cleanup_queue?job_id=eq.'+job['id'], method='DELETE')
    api('/rest/v1/photo_upload_jobs?animal_id=eq.'+target, {'previous_photo_id': None}, 'PATCH')
    api('/rest/v1/photo_upload_jobs?animal_id=eq.'+target, method='DELETE')
    api('/rest/v1/animals?id=eq.'+target, method='DELETE')


previous_finish = adb('shell','settings','get','global','always_finish_activities')
previous_developer = adb('shell','settings','get','global','development_settings_enabled')
assert previous_developer == '1', 'Enable developer options in the test emulator before running; the driver must not toggle the master ADB setting.'
try:
    for stale in api('/rest/v1/animals?name=eq.000%20Valida%C3%A7%C3%A3o%20Android%20recupera%C3%A7%C3%A3o&select=id'):
        cleanup(stale['id'])
    staff = next(user['id'] for user in fixture['users'] if user['email'] == 'fixture-staff@example.test')
    api('/rest/v1/animals', {'id': animal_id, 'name': name, 'species': 'dog', 'sex': 'female', 'size': 'small', 'approximate_age': '1'}, 'POST')
    api('/rest/v1/animal_internal_details', {'animal_id': animal_id, 'created_by': staff, 'updated_by': staff}, 'POST')
    adb('shell','am','force-stop',package)
    adb('shell', 'am', 'start', '-n', package+'/.MainActivity')
    label('Acesso Voluntário / Funcionário')
    entry = wait(lambda node: text(node, 'Acesso autorizado') or (node.get('class') == 'android.widget.EditText' and node.get('package') == package))
    if not any(text(node, 'Acesso autorizado') for node in entry):
        fields = wait(lambda node: node.get('class') == 'android.widget.EditText' and node.get('package') == package)
        tap(fields[0])
        adb('shell', 'input', 'text', 'fixture-staff@example.test')
        secret_field = wait(lambda node: node.get('class') == 'android.widget.EditText' and node.get('password') == 'true')[0]
        tap(secret_field)
        for character in password:
            adb('shell', 'input text '+shlex.quote(character))
        time.sleep(.5)
        ime = adb('shell', 'dumpsys', 'input_method')
        if 'mInputShown=true' in ime:
            adb('shell', 'input', 'keyevent', '4')
        label('Entrar')
    wait(lambda node: text(node, 'Acesso autorizado'))
    print('Normal APK authorized with runtime fixture credentials.', flush=True)
    label('Animais do abrigo')
    label(name)
    before = adb('logcat','-d','-s','flutter:I').count('Supabase init completed')
    set_activity_destruction(True)
    adb('shell','am','start','-n',package+'/.MainActivity')
    time.sleep(1)
    root=snapshot()
    if any(text(node,'Quero Adotar (Visitante)') for node in root.iter('node')):
        label('Acesso Voluntário / Funcionário');wait(lambda node:text(node,'Acesso autorizado'));label('Animais do abrigo');label(name)
    tap(scroll_to('Selecionar foto'))
    wait(lambda node: 'photopicker' in node.get('package', '') or 'providers.media' in node.get('package', ''))
    print('Android destroy-background-Activities enabled while native picker is open.', flush=True)
    # The modern half-height Photo Picker leaves the caller visible. Browse
    # opens an opaque DocumentsUI Activity, so Android actually stops/destroys
    # the Flutter Activity with this developer setting enabled.
    label('More')
    browse = wait(lambda node: node.get('text','').startswith('Browse') or node.get('content-desc','').startswith('Browse'))[0]
    tap(browse)
    wait(lambda node: 'documentsui' in node.get('package',''))
    tap(wait(lambda node: node.get('text')=='abrigo_photo_one.png' or node.get('content-desc','').startswith('abrigo_photo_one.png,'))[0])
    adb('shell', 'am', 'start', '-n', package+'/.MainActivity')
    wait(lambda node: text(node, 'Quero Adotar (Visitante)'))
    after = adb('logcat','-d','-s','flutter:I').count('Supabase init completed')
    assert after > before, 'A fresh Flutter engine and SDK must initialize after Activity destruction'
    label('Acesso Voluntário / Funcionário')
    wait(lambda node: text(node, 'Acesso autorizado'))
    label('Animais do abrigo')
    label(name)
    tap(scroll_to('Usar foto recuperada neste animal'))
    wait(lambda node: text(node, 'Nova foto, ainda não enviada'))
    row = api('/rest/v1/animals?id=eq.'+animal_id+'&select=primary_photo_id')[0]
    assert row['primary_photo_id'] is None, 'Recovery must never auto-upload'
    jobs = api('/rest/v1/photo_upload_jobs?animal_id=eq.'+animal_id+'&select=id')
    assert not jobs, 'No upload before explicit target confirmation'
    tap(scroll_to('Confirmar envio da foto'))
    wait(lambda node: text(node, 'Foto enviada com sucesso.'), timeout=80)
    row = api('/rest/v1/animals?id=eq.'+animal_id+'&select=primary_photo_id')[0]
    assert row['primary_photo_id'], 'Explicit recovered upload must persist'
    print('PASS: Activity recreation, SDK/session restore, recovery, no automatic upload, explicit target and confirmed persistence.', flush=True)
finally:
    try:
        set_activity_destruction(previous_finish=='1')
        if previous_finish == 'null':
            adb('shell','settings','delete','global','always_finish_activities')
        else:
            adb('shell','settings','put','global','always_finish_activities',previous_finish)
    finally:
        cleanup()
        adb('shell','am','force-stop',package)
        adb('shell','am','start','-n',package+'/.MainActivity')
