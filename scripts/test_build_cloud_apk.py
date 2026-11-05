"""Cloud packaging guardrails; no network, database changes or Flutter build."""
import base64
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import MagicMock, patch
from urllib.error import URLError
import zipfile

import build_cloud_apk as cloud

REF = 'abcdefghijklmnopqrst'
CONFIG = {'SUPABASE_URL': f'https://{REF}.supabase.co',
          'SUPABASE_PUBLISHABLE_KEY': 'sb_publishable_example'}


def jwt(role='anon', ref=REF):
    claims = base64.urlsafe_b64encode(json.dumps({'role': role, 'ref': ref}).encode()).decode().rstrip('=')
    return 'header.' + claims + '.signature'


class CloudApkTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.config = self.root / '.env.cloud.json'

    def load(self, data):
        self.config.write_text(json.dumps(data), encoding='utf-8')
        return cloud.load_config(self.config)

    def test_public_config_and_same_project_anon(self):
        self.assertEqual(self.load(CONFIG), CONFIG)
        data = {**CONFIG, 'SUPABASE_PUBLISHABLE_KEY': jwt()}
        self.assertEqual(self.load(data), data)

    def test_refuse_non_hosted_or_ambiguous_urls(self):
        for url in ['http://127.0.0.1:54321', 'https://localhost', 'https://10.0.0.1',
                    CONFIG['SUPABASE_URL'] + '@evil.example', CONFIG['SUPABASE_URL'] + '?x=1',
                    CONFIG['SUPABASE_URL'] + '/path', 'https://other.example']:
            with self.subTest(url=url), self.assertRaises(ValueError):
                self.load({**CONFIG, 'SUPABASE_URL': url})

    def test_refuse_secrets_wrong_project_and_invalid_claims(self):
        for key in ['sb_secret_example', jwt('service_role'), jwt(ref='different'),
                    'not-a-key', 'a.@@.b', 'a.W10.b', 'sb_publishable_']:
            with self.subTest(key=key), self.assertRaises(ValueError):
                self.load({**CONFIG, 'SUPABASE_PUBLISHABLE_KEY': key})

    def test_refuse_extra_defines_missing_keys_and_wrong_types(self):
        for data in [{**CONFIG, 'ALLOW_LOCAL_HTTP': True},
                     {**CONFIG, 'SUPABASE_SERVICE_ROLE_KEY': 'secret'},
                     {'SUPABASE_URL': CONFIG['SUPABASE_URL']}, [],
                     {**CONFIG, 'SUPABASE_PUBLISHABLE_KEY': None}]:
            with self.subTest(data=data), self.assertRaises(ValueError):
                self.load(data)

    def test_public_preflight_and_current_schema(self):
        opener = MagicMock()
        opener.open.return_value.__enter__.return_value.read.return_value = b'[]'
        with patch.object(cloud, 'build_opener', return_value=opener):
            self.assertEqual(cloud.check_backend(CONFIG), 0)
        request = opener.open.call_args.args[0]
        self.assertIn('vaccinations,last_dewormed_on', request.full_url)
        self.assertEqual(request.get_header('Apikey'), CONFIG['SUPABASE_PUBLISHABLE_KEY'])
        self.assertIsNone(request.get_header('Authorization'))

    def test_preflight_failure_does_not_leak_response_or_key(self):
        opener = MagicMock()
        opener.open.side_effect = URLError(CONFIG['SUPABASE_PUBLISHABLE_KEY'])
        with patch.object(cloud, 'build_opener', return_value=opener):
            with self.assertRaises(ValueError) as error:
                cloud.check_backend(CONFIG)
        self.assertNotIn(CONFIG['SUPABASE_PUBLISHABLE_KEY'], str(error.exception))

    def test_refuse_unexpected_response(self):
        opener = MagicMock()
        opener.open.return_value.__enter__.return_value.read.return_value = b'{}'
        with patch.object(cloud, 'build_opener', return_value=opener):
            with self.assertRaises(ValueError):
                cloud.check_backend(CONFIG)

    def test_refuse_redirect_with_public_key(self):
        self.assertIsNone(cloud.NoRedirects().redirect_request(None, None, 302, '', {}, 'https://other.example'))

    def test_build_failure_removes_old_artifact(self):
        folder = self.root / '.tools/apk/cloud'
        folder.mkdir(parents=True)
        target = folder / 'abrigo-dos-anjos-avaliacao.apk'
        target.write_bytes(b'old')
        with patch.object(cloud, 'ROOT', self.root), patch.object(cloud.subprocess, 'run') as run:
            run.return_value.returncode = 1
            with self.assertRaises(ValueError):
                cloud.build_apk(CONFIG, 'flutter')
        self.assertFalse(target.exists())
        self.assertFalse((folder / 'validation.json').exists())

    def test_build_uses_normal_release_entry_and_pending_validation(self):
        source = self.root / 'build/app/outputs/flutter-apk/app-release.apk'
        source.parent.mkdir(parents=True)
        with zipfile.ZipFile(source, 'w') as archive:
            archive.writestr('AndroidManifest.xml', b'example')
        with patch.object(cloud, 'ROOT', self.root), patch.object(cloud.subprocess, 'run') as run:
            run.return_value.returncode = 0
            target = cloud.build_apk(CONFIG, 'flutter')
        self.assertIn('--release', run.call_args.args[0])
        self.assertIn('--pub', run.call_args.args[0])
        self.assertNotIn('--no-pub', run.call_args.args[0])
        self.assertIn('--target=lib/main.dart', run.call_args.args[0])
        self.assertEqual(target.read_bytes(), source.read_bytes())
        receipt = json.loads(target.with_name('validation.json').read_text())
        self.assertEqual(receipt['device_validation'], 'pending')
        self.assertEqual(receipt['cloud_authorization_validation'], 'pending')
        self.assertEqual(len(receipt['sha256']), 64)

    def test_invalid_apk_is_not_delivered(self):
        source = self.root / 'build/app/outputs/flutter-apk/app-release.apk'
        source.parent.mkdir(parents=True)
        with zipfile.ZipFile(source, 'w') as archive:
            archive.writestr('unexpected.txt', b'example')
        with patch.object(cloud, 'ROOT', self.root), patch.object(cloud.subprocess, 'run') as run:
            run.return_value.returncode = 0
            with self.assertRaises(ValueError):
                cloud.build_apk(CONFIG, 'flutter')


if __name__ == '__main__':
    unittest.main()
