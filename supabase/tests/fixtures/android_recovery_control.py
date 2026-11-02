"""Local-only recovery fixture and genuine Android callback; never logs credentials."""
import json, os, shlex, shutil, subprocess, threading
from http.server import BaseHTTPRequestHandler, HTTPServer
from pathlib import Path
from urllib.error import HTTPError
from urllib.parse import urlparse
from team_fixture_support import create_user, sql, env, email_link, NoRedirect, build_opener, cleanup
user_id,email=create_user('android-recovery')
sql(f"insert into public.staff_members(user_id,active,role,display_name) values('{user_id}',true,'employee','Recuperação Android');")
callback=None
class Handler(BaseHTTPRequestHandler):
 def log_message(self,*_): pass
 def reply(self,value,status=200):
  data=json.dumps(value).encode();self.send_response(status);self.send_header('Content-Type','application/json');self.send_header('Cache-Control','no-store');self.end_headers();self.wfile.write(data)
 def do_GET(self):
  if self.path=='/credentials':self.reply({'email':email,'password':env['FIXTURE_PASSWORD'],'new_password':env['FIXTURE_PASSWORD']+'-new'})
  else:self.reply({},404)
 def do_POST(self):
  global callback
  if self.path=='/cleanup':
   cleanup();self.reply({'cleaned':True});threading.Thread(target=self.server.shutdown,daemon=True).start();return
  if self.path not in ('/open-recovery','/replay-recovery','/prepare-recovery'):self.reply({},404);return
  try:
   if self.path in ('/open-recovery','/prepare-recovery'):
    link=email_link(email)
    try:response=build_opener(NoRedirect).open(link,timeout=20)
    except HTTPError as error:response=error
    assert response.code in (302,303)
    callback=response.headers['Location'];parsed=urlparse(callback)
    assert parsed.scheme=='br.org.abrigodosanjos.app' and parsed.netloc=='auth' and parsed.path=='/recovery' and 'code=' in parsed.query
   assert callback
   if self.path=='/prepare-recovery':self.reply({'ready':True});return
   adb=shutil.which('adb') or str(Path(os.environ['LOCALAPPDATA'])/'Android/Sdk/platform-tools/adb.exe')
   result=subprocess.run([adb,'-s','emulator-5554','shell','am','start','-a','android.intent.action.VIEW','-d',shlex.quote(callback),'br.org.abrigodosanjos.abrigo_dos_anjos'],capture_output=True,timeout=20)
   assert result.returncode==0
   self.reply({'opened':True})
  except Exception:self.reply({'opened':False},500)
try:HTTPServer(('127.0.0.1',58765),Handler).serve_forever()
finally:cleanup()
