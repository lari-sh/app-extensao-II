"""Local-only management contract journey. No credentials printed or compiled."""
import base64
import concurrent.futures
import json
import runpy
import secrets
import struct
import uuid
import zlib
from urllib.error import HTTPError
from urllib.parse import urlencode
from urllib.request import Request, urlopen

control = runpy.run_path('supabase/tests/fixtures/android_auth_control.py')
admin, env, base = control['api'], control['environment'], control['base']
public_key = env['SUPABASE_ANON_KEY']

def request(path, body=None, token=None, method=None, content_type='application/json'):
    data = body if isinstance(body, bytes) else json.dumps(body).encode() if body is not None else None
    headers = {'apikey': public_key, 'Content-Type': content_type}
    if token:
        headers['Authorization'] = 'Bearer ' + token
    try:
        with urlopen(Request(base + path, data=data, headers=headers, method=method), timeout=70) as response:
            raw = response.read()
            return response.status, json.loads(raw) if raw and 'json' in response.headers.get('Content-Type','') else raw
    except HTTPError as error:
        return error.code, None

def login():
    status, session = request('/auth/v1/token?grant_type=password', {'email':'fixture-staff@example.test','password':env['FIXTURE_PASSWORD']})
    assert status == 200, 'Fixture login failed'
    return session['access_token']

first, second = login(), login()
assert first != second, 'Independent sessions required'
def rpc(name, payload, token=first):
    status, result = request('/rest/v1/rpc/' + name, payload, token)
    assert status == 200, 'RPC failed: ' + name + ' status=' + str(status)
    return result
key = lambda: secrets.token_urlsafe(24)
animal_id = None
try:
    created = rpc('save_animal', {'p_operation_key':key(),'p_payload':{'name':'Validação manejo '+str(uuid.uuid4()),'species':'dog','sex':'female','size':'small','approximate_age':'2 anos','clinical_notes':'Preservar notas'}})
    animal_id = created['animal']['id']
    assert not created['animal']['is_published']
    assert rpc('get_managed_animal',{'p_animal_id':animal_id},second)['clinical_notes']=='Preservar notas'
    public_path = '/rest/v1/animals?' + urlencode({'id':'eq.'+animal_id,'select':'id'})
    assert request(public_path)[1] == []
    shared_key = key()
    payload={'p_operation_key':shared_key,'p_animal_id':animal_id,'p_status':'treatment'}
    with concurrent.futures.ThreadPoolExecutor(max_workers=2) as pool:
        results=list(pool.map(lambda token:rpc('set_animal_status',payload,token),[first,second]))
    assert results[0]==results[1], 'Concurrent replay must return original confirmation'
    assert request('/rest/v1/rpc/set_animal_status',{**payload,'p_status':'quarantine'},second)[0]==409
    rpc('set_animal_publication',{'p_operation_key':key(),'p_animal_id':animal_id,'p_is_published':True},second)
    assert len(request(public_path)[1])==1
    assert rpc('get_managed_animal',{'p_animal_id':animal_id},first)['animal']['is_published']
    # Real valid PNG, uploaded through the authenticated function.
    def chunk(tag,data):
        return struct.pack('>I',len(data))+tag+data+struct.pack('>I',zlib.crc32(tag+data)&0xffffffff)
    png=b'\x89PNG\r\n\x1a\n'+chunk(b'IHDR',struct.pack('>IIBBBBB',2,2,8,2,0,0,0))+chunk(b'IDAT',zlib.compress((b'\0'+bytes([197,29,42])*2)*2))+chunk(b'IEND',b'')
    boundary='abrigo'+uuid.uuid4().hex
    body=b''
    for name,value in [('animal_id',animal_id),('operation_key',key())]:
        body+=f'--{boundary}\r\nContent-Disposition: form-data; name="{name}"\r\n\r\n{value}\r\n'.encode()
    body+=f'--{boundary}\r\nContent-Disposition: form-data; name="file"; filename="test.png"\r\nContent-Type: image/png\r\n\r\n'.encode()+png+f'\r\n--{boundary}--\r\n'.encode()
    status, uploaded=request('/functions/v1/animal-photo-upload',body,first,'POST','multipart/form-data; boundary='+boundary)
    assert status==200, 'Real upload failed status='+str(status)
    photo_id=rpc('get_managed_animal',{'p_animal_id':animal_id})['animal']['primary_photo_id']
    photo_path='/functions/v1/animal-photo-read?'+urlencode({'animal_id':animal_id,'photo_id':photo_id})
    assert request(photo_path)[0]==200
    rpc('set_animal_publication',{'p_operation_key':key(),'p_animal_id':animal_id,'p_is_published':False},second)
    assert request(public_path)[1]==[] and request(photo_path)[0]==404
    rpc('set_animal_publication',{'p_operation_key':key(),'p_animal_id':animal_id,'p_is_published':True})
    assert request(photo_path)[0]==200
    rpc('set_animal_status',{'p_operation_key':key(),'p_animal_id':animal_id,'p_status':'adopted'},second)
    assert request(public_path)[1]==[] and request(photo_path)[0]==404
    assert request('/rest/v1/rpc/set_animal_publication',{'p_operation_key':key(),'p_animal_id':animal_id,'p_is_published':True},first)[0]==400
    final=rpc('get_managed_animal',{'p_animal_id':animal_id})
    assert final['clinical_notes']=='Preservar notas' and final['animal']['primary_photo_id']==photo_id
    print('PASS: independent sessions, concurrent idempotency/conflict, private create, publication/hiding/adoption, new photo requests denied, aggregate preserved.')
finally:
    if animal_id:
        jobs=admin('/rest/v1/photo_upload_jobs?'+urlencode({'animal_id':'eq.'+animal_id,'select':'id,object_path'}))
        admin('/rest/v1/animals?id=eq.'+animal_id,{'primary_photo_id':None},'PATCH')
        for job in jobs:
            admin('/storage/v1/object/animal-photos',{'prefixes':[job['object_path']]},'DELETE')
            admin('/rest/v1/photo_cleanup_queue?job_id=eq.'+job['id'],method='DELETE')
        admin('/rest/v1/photo_upload_jobs?animal_id=eq.'+animal_id,{'previous_photo_id':None},'PATCH')
        admin('/rest/v1/photo_upload_jobs?animal_id=eq.'+animal_id,method='DELETE')
        admin('/rest/v1/write_operations?'+urlencode({'result->animal->>id':'eq.'+animal_id}),method='DELETE')
        admin('/rest/v1/animals?id=eq.'+animal_id,method='DELETE')
