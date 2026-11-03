"""Loopback-only Android team fixtures; never invokes external email services."""
import json
import os
import shutil
import shlex
import subprocess
import threading
import uuid
from http.server import BaseHTTPRequestHandler, HTTPServer
from pathlib import Path
from urllib.parse import urlparse
from team_fixture_support import create_user, sql, prefix, suffix, env, email_link, verify_callback, cleanup

admin, admin_email = create_user('android-admin')
second, _ = create_user('android-second')
recipient = prefix + '-android-recipient@example.test'
sql(f"insert into public.staff_members(user_id,active,role,display_name) values('{admin}',true,'administrator','Admin Android'),('{second}',true,'administrator','Segundo Android');")

class Handler(BaseHTTPRequestHandler):
    def log_message(self, *_):
        pass
    def reply(self, value, status=200):
        data=json.dumps(value).encode()
        self.send_response(status); self.send_header('Content-Type','application/json'); self.send_header('Cache-Control','no-store'); self.end_headers(); self.wfile.write(data)
    def do_GET(self):
        if self.path == '/credentials':
            global recipient
            recipient=prefix+'-android-'+uuid.uuid4().hex[:8]+'@example.test'
            self.reply({'email':admin_email,'password':env['FIXTURE_PASSWORD'],'recipient':recipient})
        else: self.reply({},404)
    def do_POST(self):
        if self.path == '/cleanup':
            cleanup(); self.reply({'cleaned':True}); threading.Thread(target=self.server.shutdown,daemon=True).start(); return
        if self.path != '/open-invitation': self.reply({},404); return
        try:
            callback=verify_callback(email_link(recipient))
            assert urlparse(callback).path == '/invite'
            adb=shutil.which('adb')
            if not adb:
                adb=str(Path(os.environ['LOCALAPPDATA'])/'Android/Sdk/platform-tools/adb.exe')
            result=subprocess.run([adb,'-s',os.environ.get('TEST_ANDROID_SERIAL','emulator-5554'),'shell','am','start','-a','android.intent.action.VIEW','-d',shlex.quote(callback),'br.org.abrigodosanjos.abrigo_dos_anjos'],capture_output=True,timeout=20)
            assert result.returncode==0
            self.reply({'opened':True})
        except Exception:
            self.reply({'opened':False},500)

try:
    HTTPServer(('127.0.0.1',58764),Handler).serve_forever()
finally:
    cleanup()
