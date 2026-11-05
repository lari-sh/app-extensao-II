"""Build an evaluation APK with public hosted Supabase configuration only."""
import argparse
import base64
import hashlib
import json
from pathlib import Path
import re
import shutil
import subprocess
from urllib.error import HTTPError, URLError
from urllib.request import HTTPRedirectHandler, Request, build_opener
import zipfile

ROOT = Path(__file__).resolve().parents[1]


def load_config(path):
    data = json.loads(Path(path).read_text(encoding='utf-8-sig'))
    expected = {'SUPABASE_URL', 'SUPABASE_PUBLISHABLE_KEY'}
    if not isinstance(data, dict) or set(data) != expected:
        raise ValueError('Informe somente URL e chave pública no JSON.')
    if not all(isinstance(value, str) for value in data.values()):
        raise ValueError('URL e chave pública devem ser textos.')
    data = {key: value.strip() for key, value in data.items()}
    match = re.fullmatch(r'https://([a-z0-9]{20})\.supabase\.co/?', data['SUPABASE_URL'])
    if not match:
        raise ValueError('Use a URL HTTPS oficial do projeto Supabase hospedado.')
    key = data['SUPABASE_PUBLISHABLE_KEY']
    valid = re.fullmatch(r'sb_publishable_[A-Za-z0-9_-]+', key) is not None
    if not valid:
        try:
            parts = key.split('.')
            claims = json.loads(base64.urlsafe_b64decode(parts[1] + '=' * (-len(parts[1]) % 4)))
            valid = (len(parts) == 3 and isinstance(claims, dict)
                     and claims.get('role') == 'anon'
                     and claims.get('ref') == match[1])
        except (ValueError, IndexError, UnicodeError):
            valid = False
    if not valid:
        raise ValueError('Use chave publishable ou anon do mesmo projeto; nunca chave administrativa.')
    data['SUPABASE_URL'] = data['SUPABASE_URL'].rstrip('/')
    return data


class NoRedirects(HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        # Do not forward the API key to an unexpected destination.
        return None


def check_backend(config):
    columns = ('id,name,animal_code,primary_photo_id,vaccinations,'
               'last_dewormed_on,weight_kg,color,is_neutered,temperament')
    request = Request(config['SUPABASE_URL'] + '/rest/v1/animals?select=' + columns
                      + '&is_published=eq.true&status=neq.adopted&limit=1',
                      headers={'apikey': config['SUPABASE_PUBLISHABLE_KEY']})
    try:
        with build_opener(NoRedirects()).open(request, timeout=30) as response:
            payload = json.loads(response.read(1_000_001))
    except (HTTPError, URLError, TimeoutError, ValueError, OSError):
        raise ValueError('Não foi possível ler o catálogo público; confira rede, chave, migrations e RLS.') from None
    if not isinstance(payload, list):
        raise ValueError('Resposta inesperada do catálogo público.')
    return len(payload)


def build_apk(config, flutter):
    folder = ROOT / '.tools/apk/cloud'
    folder.mkdir(parents=True, exist_ok=True)
    # Do not leave a previous successful artifact masquerading as this attempt.
    target = folder / 'abrigo-dos-anjos-avaliacao.apk'
    receipt = folder / 'validation.json'
    target.unlink(missing_ok=True)
    receipt.unlink(missing_ok=True)
    config_path = folder / 'public-config.json'
    config_path.write_text(json.dumps(config), encoding='utf-8')
    # Refresh plugin tooling when switching from integration tests/debug to release.
    command = [str(flutter), 'build', 'apk', '--release', '--pub',
               '--target=lib/main.dart', '--dart-define-from-file=' + str(config_path)]
    with (folder / 'build.log').open('w', encoding='utf-8') as log:
        result = subprocess.run(command, cwd=ROOT, stdout=log, stderr=subprocess.STDOUT)
    if result.returncode:
        raise ValueError('Build falhou; confira .tools/apk/cloud/build.log. Nenhum APK de avaliação foi entregue.')
    source = ROOT / 'build/app/outputs/flutter-apk/app-release.apk'
    with zipfile.ZipFile(source) as archive:
        if 'AndroidManifest.xml' not in archive.namelist() or archive.testzip() is not None:
            raise ValueError('APK inválido; nenhum arquivo entregue.')
    shutil.copy2(source, target)
    metadata = {'file': target.name, 'sha256': hashlib.sha256(target.read_bytes()).hexdigest(),
                'bytes': target.stat().st_size, 'mode': 'release', 'entry_point': 'lib/main.dart',
                'supabase_url': config['SUPABASE_URL'],
                'device_validation': 'pending', 'cloud_authorization_validation': 'pending'}
    receipt.write_text(json.dumps(metadata, indent=2) + '\n', encoding='utf-8')
    return target


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--config', type=Path, required=True)
    parser.add_argument('--flutter', default=shutil.which('flutter'))
    parser.add_argument('--check-only', action='store_true')
    args = parser.parse_args()
    try:
        config_path = args.config.resolve(strict=True)
        config = load_config(config_path)
        check_backend(config)
        print('HTTPS, chave pública e leitura do schema público: PASS (não substitui validação de permissões).')
        if args.check_only:
            return
        if not args.flutter:
            raise ValueError('Informe --flutter com o caminho do SDK instalado.')
        print('APK gerado:', build_apk(config, args.flutter))
        print('Validação no celular e autorização na nuvem ainda precisam ser registradas.')
    except (ValueError, OSError, zipfile.BadZipFile) as error:
        parser.exit(1, str(error) + '\n')


if __name__ == '__main__':
    main()
