"""Generate ephemeral local-only CI fixtures without repository/production secrets."""
import json
import os
from pathlib import Path
import secrets
import subprocess

if os.environ.get('GITHUB_ACTIONS') != 'true':
    raise SystemExit('This helper is restricted to disposable GitHub Actions runners.')
status = json.loads(subprocess.check_output(['supabase','status','-o','json'], text=True))
values = {
    'SUPABASE_URL': 'http://127.0.0.1:54321',
    'SUPABASE_ANON_KEY': status['ANON_KEY'],
    'SUPABASE_SERVICE_ROLE_KEY': status['SERVICE_ROLE_KEY'],
    'FIXTURE_PASSWORD': secrets.token_urlsafe(24),
    'PHOTO_CLEANUP_SECRET': secrets.token_urlsafe(32),
    'ALLOW_LOCAL_FIXTURES': 'true',
}
for name in ('SUPABASE_ANON_KEY','SUPABASE_SERVICE_ROLE_KEY','FIXTURE_PASSWORD','PHOTO_CLEANUP_SECRET'):
    print('::add-mask::'+values[name])
Path('supabase/.env.local').write_text(''.join(f'{key}={value}\n' for key,value in values.items()))
with open(os.environ['GITHUB_ENV'],'a') as output:
    output.writelines(f'{key}={value}\n' for key,value in values.items())
