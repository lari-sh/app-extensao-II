"""Validate normal local Android APK with disposable recovery controller fixtures.

Start android_recovery_control.py with a fresh fixture first. Install normal debug
APK pointing to local Supabase. Never use real accounts or print credentials.
"""
import json,os,re,shlex,shutil,subprocess,time,urllib.request,xml.etree.ElementTree as ET
from pathlib import Path
os.environ.setdefault('ANDROID_USER_HOME',str(Path.home()/'.android'))
adb=shutil.which('adb') or str(Path(os.environ['LOCALAPPDATA'])/'Android/Sdk/platform-tools/adb.exe')
package='br.org.abrigodosanjos.abrigo_dos_anjos'
control='http://127.0.0.1:58765'
credentials=json.load(urllib.request.urlopen(control+'/credentials',timeout=10))
def run(*args):
 p=subprocess.run([adb,'-s','emulator-5554',*args],capture_output=True,timeout=30)
 assert p.returncode==0,'Android command failed'
 return p.stdout
def read_nodes():
 target='/sdcard/auth-check-'+str(time.time_ns())+'.xml'
 run('shell','uiautomator','dump',target);data=run('exec-out','cat',target).decode();run('shell','rm','-f',target)
 return list(ET.fromstring(data[data.index('<?xml'):]).iter('node'))
def nodes():
 for _ in range(8):
  try:return read_nodes()
  except (ValueError,ET.ParseError,AssertionError,subprocess.TimeoutExpired):time.sleep(1)
 raise AssertionError('Android UI inspection unavailable after retries')
def label(node):return node.get('content-desc','')+' '+node.get('text','')
def find(text):return next((n for n in nodes() if text in label(n)),None)
def tap(node):
 a,b,c,d=map(int,re.findall(r'\d+',node.get('bounds')));run('shell','input','tap',str((a+c)//2),str((b+d)//2));time.sleep(.6)
def click(text):
 for _ in range(9):
  n=find(text)
  if n is not None:tap(n);return
  run('shell','input','swipe','500','1600','500','900','250');time.sleep(.3)
 raise AssertionError('Requested control unavailable: '+text)
def wait(text):
 for _ in range(15):
  if find(text) is not None:return
  time.sleep(.5)
 raise AssertionError('Expected screen unavailable: '+text)
def relaunch():
 run('shell','am','force-stop',package);time.sleep(.5);run('shell','am','start','-n',package+'/.MainActivity');time.sleep(3)
def fields(values):
 for index,value in enumerate(values):
  controls=[n for n in nodes() if n.get('class')=='android.widget.EditText']
  assert len(controls)>=len(values),'Expected input unavailable'
  tap(controls[index]);run('shell','input','keyevent','123');run('shell','input','keyevent',*(['67']*100));run('shell','input','text',shlex.quote(value));time.sleep(.4)
 run('shell','input','keyevent','4');time.sleep(.6)
def login(remember):
 fields([credentials['email'],credentials['password']])
 for _ in range(6):
  checks=[n for n in nodes() if n.get('class')=='android.widget.CheckBox']
  if checks:break
  run('shell','input','swipe','500','1600','500','1000','250')
 assert checks,'Remember checkbox unavailable'
 if (checks[0].get('checked')=='true')!=remember:
  a,b,c,d=map(int,re.findall(r'\d+',checks[0].get('bounds')));run('shell','input','tap',str(a+45),str((b+d)//2));time.sleep(.5)
 assert (next(n for n in nodes() if n.get('class')=='android.widget.CheckBox').get('checked')=='true')==remember,'Choice did not change'
 click('Entrar no painel');wait('Acesso autorizado')
relaunch();click('Acesso Voluntário / Funcionário');wait('Acesso restrito')
login(False);relaunch();click('Acesso Voluntário / Funcionário');wait('Acesso restrito')
assert find('Acesso autorizado') is None
print('PASS: unchecked session does not survive process termination.',flush=True)
login(True);relaunch();click('Acesso Voluntário / Funcionário');wait('Acesso autorizado')
print('PASS: checked session restores after process termination.',flush=True)
click('Sair da conta');click('Acesso Voluntário / Funcionário');wait('Acesso restrito');click('Esqueci a senha');wait('Recuperar acesso')
# Form may be below fold on a compact viewport.
for _ in range(6):
 if any(n.get('class')=='android.widget.EditText' for n in nodes()):break
 run('shell','input','swipe','500','1600','500','1000','250')
fields([credentials['email']]);click('Enviar orientações');wait('Confira seu e-mail')
request=urllib.request.Request(control+'/prepare-recovery',method='POST');assert urllib.request.urlopen(request,timeout=30).status==200
run('shell','am','force-stop',package);time.sleep(1)
request=urllib.request.Request(control+'/replay-recovery',method='POST');assert urllib.request.urlopen(request,timeout=30).status==200
time.sleep(3);wait('Definir nova senha');wait('Salvar nova senha')
fields([credentials['new_password'],credentials['new_password']]);click('Salvar nova senha');wait('Senha atualizada')
assert find('Kanban') is None
click('Ir para o login');wait('Acesso restrito')
print('PASS: cold callback preserves PKCE, saves password and returns to normal login.',flush=True)
