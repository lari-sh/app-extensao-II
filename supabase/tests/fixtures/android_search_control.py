"""Isolated local Android search fixtures, never reset existing animals."""
from http.server import BaseHTTPRequestHandler,HTTPServer
import json,uuid,datetime
from team_fixture_support import create_user,sql,login,rpc,cleanup,env
from search_fixture_cleanup import cleanup_search_animals
actor,email=create_user('android-search')
sql(f"insert into public.staff_members(user_id,active,role,display_name) values('{actor}',true,'employee','Teste busca Android');")
animals=[]
def clean():
 if animals:
  cleanup_search_animals(actor, [a['id'] for a in animals])
 sql(f"delete from public.write_operations where actor_id='{actor}';")
 cleanup()
try:
 token=login(email);name='Luna Busca '+uuid.uuid4().hex[:8]
 for i in range(2):
  result=rpc('save_animal',{'p_operation_key':uuid.uuid4().hex,'p_payload':{'name':name,'species':'dog' if i==0 else 'cat','sex':'female' if i==0 else 'male','size':'small' if i==0 else 'large','approximate_age':'2 anos','color':'preto' if i==0 else 'branco'}},token)
  animals.append(result['animal'])
  if i==0:
   rpc('set_animal_status',{'p_animal_id':result['animal']['id'],'p_status':'quarantine','p_operation_key':uuid.uuid4().hex},token)
 today=sql("select (now() at time zone 'America/Sao_Paulo')::date;")
 for i,animal in enumerate(animals):
  rpc('save_medication_treatment',{'p_operation_key':uuid.uuid4().hex,'p_payload':{'animal_id':animal['id'],'medication_name':'Ilustrativa '+('A' if i==0 else 'B'),'schedule_mode':'fixed_times','starts_on':today,'starts_time':'00:00','ends_on':today,'ends_time':'23:59','fixed_times':['08:00' if i==0 else '10:00']}},token)
 class Handler(BaseHTTPRequestHandler):
  def log_message(self,*args):pass
  def do_GET(self):
   if self.path!='/fixtures':self.send_error(404);return
   body=json.dumps({'email':email,'password':env['FIXTURE_PASSWORD'],'name':name,'animals':animals,'day':today}).encode()
   self.send_response(200);self.send_header('Content-Type','application/json');self.end_headers();self.wfile.write(body)
  def do_POST(self):
   if self.path!='/cleanup':self.send_error(404);return
   clean();animals.clear();self.send_response(204);self.end_headers()
 HTTPServer(('127.0.0.1',58766),Handler).serve_forever()
finally:clean()
