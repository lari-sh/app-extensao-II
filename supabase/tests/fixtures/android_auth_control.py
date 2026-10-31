"""Temporary loopback controller for disposable Android fixture tests only.

Run from the repository root. Never use with remote or production projects.
No credentials are compiled into the integration APK or logged by this server.
"""
import json
from http.server import BaseHTTPRequestHandler, HTTPServer
from pathlib import Path
from urllib.parse import urlparse
from urllib.request import Request, urlopen

environment = {}
for line in Path('supabase/.env.local').read_text().splitlines():
    if '=' in line and not line.lstrip().startswith('#'):
        name, value = line.split('=', 1)
        environment[name] = value.strip().strip('"').strip("'")
base = environment['SUPABASE_URL'].rstrip('/')
assert urlparse(base).hostname in ('localhost', '127.0.0.1')
assert environment.get('ALLOW_LOCAL_FIXTURES') == 'true'


def api(path, body=None, method=None):
    key = environment['SUPABASE_SERVICE_ROLE_KEY']
    request = Request(base + path, data=json.dumps(body).encode() if body is not None else None,
                      headers={'apikey': key, 'Authorization': 'Bearer ' + key,
                               'Content-Type': 'application/json'}, method=method)
    with urlopen(request, timeout=10) as response:
        raw = response.read()
        return json.loads(raw) if raw else None


users = api('/auth/v1/admin/users?page=1&per_page=100')['users']
actor = next(user['id'] for user in users if user['email'] == 'fixture-revocable@example.test')


def membership(active):
    api('/rest/v1/staff_members?user_id=eq.' + actor, {'active': active}, 'PATCH')


class Handler(BaseHTTPRequestHandler):
    def log_message(self, *_):
        pass

    def do_GET(self):
        if self.path != '/fixture-password':
            self.send_error(404)
            return
        self.send_response(200)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Cache-Control', 'no-store')
        self.end_headers()
        self.wfile.write(json.dumps({'password': environment['FIXTURE_PASSWORD']}).encode())

    def do_POST(self):
        if self.path not in ('/revoke-membership', '/restore-membership'):
            self.send_error(404)
            return
        membership(self.path == '/restore-membership')
        self.send_response(204)
        self.end_headers()


if __name__ == '__main__':
    membership(True)
    print('Local Android fixture controller ready (loopback only).', flush=True)
    try:
        HTTPServer(('127.0.0.1', 58763), Handler).serve_forever()
    finally:
        membership(True)
