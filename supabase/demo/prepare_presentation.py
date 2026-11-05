"""Prepare explicitly authorized local demonstration data; never production."""
import argparse, hashlib, json, secrets
from pathlib import Path
from urllib.error import HTTPError
from urllib.parse import urlencode, urlparse
from urllib.request import Request, urlopen

ROOT=Path(__file__).resolve().parents[2]
MANIFEST=json.loads((Path(__file__).with_name('animals.json')).read_text(encoding='utf-8'))
CACHE=ROOT/'.tools/demo_animals'

def operation(label):return hashlib.sha256(('presentation-v1/'+label).encode()).hexdigest()[:32]

def main():
 parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--apply',action='store_true');args=parser.parse_args()
 print('Apresentação fictícia:',', '.join(a['payload']['name'] for a in MANIFEST['animals']))
 if not args.apply:
  print('Dry-run: nenhum banco alterado. Use --apply somente no Supabase local de demonstração.');return
 env={}
 for line in (ROOT/'supabase/.env.local').read_text(encoding='utf-8').splitlines():
  if '=' in line and not line.lstrip().startswith('#'):
   k,v=line.split('=',1);env[k]=v.strip().strip('"').strip("'")
 base=env['SUPABASE_URL'].rstrip('/');parsed=urlparse(base)
 assert parsed.scheme=='http' and parsed.hostname in ('127.0.0.1','localhost') and parsed.port==54321 and not parsed.username and not parsed.password,'Somente projeto local permitido'
 assert env.get('ALLOW_LOCAL_FIXTURES')=='true','Autorização local ausente'
 CACHE.mkdir(parents=True,exist_ok=True);(CACHE/'photos').mkdir(exist_ok=True)
 def request(path,body=None,token=None,admin=False,method=None,mime='application/json'):
  key=env['SUPABASE_SERVICE_ROLE_KEY'] if admin else env['SUPABASE_ANON_KEY']
  headers={'apikey':key,'Content-Type':mime}
  if admin or token:headers['Authorization']='Bearer '+(token or key)
  data=body if isinstance(body,bytes) else json.dumps(body).encode() if body is not None else None
  try:
   with urlopen(Request(base+path,data=data,headers=headers,method=method),timeout=70) as response:
    raw=response.read();return json.loads(raw) if raw and 'json' in response.headers.get('Content-Type','') else raw
  except HTTPError as error:raise RuntimeError('Operação local falhou: HTTP '+str(error.code)) from None
 # Download and verify every source before creating any record.
 for item in MANIFEST['animals']:
  photo=item['photo'];path=CACHE/'photos'/(item['slug']+'.jpg')
  if not path.exists():
   assert urlparse(photo['source_url']).hostname=='images.unsplash.com'
   with urlopen(Request(photo['source_url'],headers={'User-Agent':'AbrigoDosAnjosLocalDemo/1.0'}),timeout=30) as response:data=response.read(5_000_001)
   assert len(data)<5_000_000 and data.startswith(b'\xff\xd8'),'Imagem inválida'
   path.write_bytes(data)
  assert hashlib.sha256(path.read_bytes()).hexdigest()==photo['sha256'],'Fonte alterada; revisar imagem antes de importar'
 session=request('/auth/v1/token?grant_type=password',{'email':'fixture-staff@example.test','password':env['FIXTURE_PASSWORD']});token=session['access_token']
 def rpc(name,payload):return request('/rest/v1/rpc/'+name,payload,token)
 result=[]
 try:
  for item in MANIFEST['animals']:
   slug=item['slug'];created=rpc('save_animal',{'p_operation_key':operation('create/'+slug),'p_payload':item['payload']});animal_id=created['animal']['id']
   current=rpc('get_managed_animal',{'p_animal_id':animal_id})['animal']
   if current['primary_photo_id'] is None:
    image=(CACHE/'photos'/(slug+'.jpg')).read_bytes();boundary='demo'+secrets.token_hex(12);body=b''
    for name,value in [('animal_id',animal_id),('operation_key',operation('photo/'+slug+'/'+item['photo']['sha256']))]:
     body+=f'--{boundary}\r\nContent-Disposition: form-data; name="{name}"\r\n\r\n{value}\r\n'.encode()
    body+=f'--{boundary}\r\nContent-Disposition: form-data; name="file"; filename="{slug}.jpg"\r\nContent-Type: image/jpeg\r\n\r\n'.encode()+image+f'\r\n--{boundary}--\r\n'.encode()
    request('/functions/v1/animal-photo-upload',body,token,mime='multipart/form-data; boundary='+boundary)
   rpc('set_animal_publication',{'p_operation_key':operation('publish/'+slug),'p_animal_id':animal_id,'p_is_published':True})
   current=rpc('get_managed_animal',{'p_animal_id':animal_id})['animal'];assert current['primary_photo_id'] and current['is_published']
   photo=request('/functions/v1/animal-photo-read?'+urlencode({'animal_id':animal_id,'photo_id':current['primary_photo_id']}))
   assert isinstance(photo,bytes) and len(photo)>1000,'Foto pública não entregue'
   result.append({'id':animal_id,'name':current['name'],'photo_id':current['primary_photo_id'],'photo_bytes':len(photo)})
   print('Validado:',current['name'],'— foto pública e ficha completas',flush=True)
  technical=request('/rest/v1/animals?'+urlencode({'select':'id,name,is_published,public_description'}),admin=True)
  owned=[a for a in technical if a['id'] in {f'00000000-0000-4000-8000-{i:012d}' for i in range(1,61)} and a['name'].startswith('Animal de teste ') and a['public_description']=='Fixture isolada; nunca importar para producao.']
  backup=CACHE/'technical-publication-backup.json'
  if not backup.exists():backup.write_text(json.dumps(owned,ensure_ascii=False,indent=2),encoding='utf-8')
  # Preserve every technical/manual record and all clinical/history/photo data.
  for a in owned:
   if a['is_published']:request('/rest/v1/animals?'+urlencode({'id':'eq.'+a['id']}),{'is_published':False},admin=True,method='PATCH')
  visible=request('/rest/v1/animals?'+urlencode({'select':'id,name,public_description,primary_photo_id','order':'name.asc'}))
  assert all(a['id'] not in {o['id'] for o in owned} for a in visible)
  assert {a['id'] for a in result}<={a['id'] for a in visible}
  assert all('Fixture isolada' not in a['public_description'] for a in visible)
  (CACHE/'import-result.json').write_text(json.dumps({'animals':result,'technical_hidden':len(owned),'public_total':len(visible)},ensure_ascii=False,indent=2),encoding='utf-8')
  print('PASS:',len(result),'exemplos com fotos;',len(owned),'registros técnicos preservados e ocultos do catálogo; total público:',len(visible))
 finally:
  request('/auth/v1/logout?scope=local',{},token)

if __name__=='__main__':main()
