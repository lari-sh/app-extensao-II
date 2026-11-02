"""Concurrent code allocation on isolated local-only fixtures; no real records changed."""
import concurrent.futures,threading,uuid
from team_fixture_support import create_user,sql,login,rpc,request,cleanup
actor,_email=create_user('animal-code');animals=set()
sql(f"insert into public.staff_members(user_id,active,role,display_name) values('{actor}',true,'employee','Validação código');")
try:
 first,second=login(_email),login(_email)
 payload={'name':'Validação código '+uuid.uuid4().hex,'species':'dog','sex':'female','size':'small','approximate_age':'2 anos'}
 def create_together(keys):
  barrier=threading.Barrier(2)
  def create(args):
   token,key=args;barrier.wait(timeout=10)
   value=rpc('save_animal',{'p_operation_key':key,'p_payload':payload},token)['animal'];return value
  with concurrent.futures.ThreadPoolExecutor(max_workers=2) as pool:
   values=list(pool.map(create,zip([first,second],keys)))
  animals.update(a['id'] for a in values);return values
 independent=create_together([uuid.uuid4().hex,uuid.uuid4().hex])
 assert len({a['animal_code'] for a in independent})==2,'Concurrent identities must differ'
 key=uuid.uuid4().hex;replayed=create_together([key,key])
 assert replayed[0]==replayed[1] and len({a['id'] for a in replayed})==1,'Idempotent concurrent create must keep one identity'
 value=independent[0]
 edited=rpc('save_animal',{'p_operation_key':uuid.uuid4().hex,'p_payload':{**payload,'id':value['id'],'name':payload['name']+' editado'}},first)['animal']
 assert edited['animal_code']==value['animal_code'],'Renaming cannot change code'
 error=request('/rest/v1/rpc/save_animal',{'p_operation_key':uuid.uuid4().hex,'p_payload':{**payload,'animal_code':'A9999'}},first,expected=400)
 assert error['code']=='22023','Client-assigned code must fail'
 print('PASS: concurrent unique code allocation, same-key replay, rename stability and forged code denied.')
finally:
 if animals:
  ids=','.join("'"+str(uuid.UUID(a))+"'" for a in animals)
  sql(f"delete from public.animals where id in ({ids});")
 sql(f"delete from public.write_operations where actor_id='{actor}';")
 cleanup()
