import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/config/app_config.dart';
import 'package:abrigo_dos_anjos/utils/app_failure.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';

void main() {
  test('missing, malformed and non-HTTPS remote config fails closed', () {
    for (final url in [
      '',
      'no-url',
      'http://example.com',
      'https://user:pass@example.com',
      'https://example.com/path',
    ]) {
      expect(
        (AppConfig.parse(url: url, key: 'sb_publishable_test') as Failure)
            .failure
            .code,
        FailureCode.configuration,
      );
    }
  });
  test('accepts public key with HTTPS and debug-only loopback HTTP', () {
    expect(
      AppConfig.parse(
        url: 'https://example.supabase.co',
        key: 'sb_publishable_test',
      ),
      isA<Success<AppConfig>>(),
    );
    expect(
      AppConfig.parse(url: 'http://10.0.2.2:54321', key: 'sb_publishable_test'),
      isA<Failure<AppConfig>>(),
    );
    expect(
      AppConfig.parse(
        url: 'http://10.0.2.2:54321',
        key: 'sb_publishable_test',
        allowLocalHttp: true,
      ),
      isA<Success<AppConfig>>(),
    );
    expect(
      AppConfig.parse(
        url: 'http://evil.test',
        key: 'sb_publishable_test',
        allowLocalHttp: true,
      ),
      isA<Failure<AppConfig>>(),
    );
  });
  test('rejects secret keys, service_role and user JWTs', () {
    String jwt(String role) =>
        'e30.${base64Url.encode(utf8.encode(jsonEncode({'role': role}))).replaceAll('=', '')}.signature';
    for (final key in [
      '',
      'sb_secret_test',
      jwt('service_role'),
      jwt('authenticated'),
      'garbage',
    ]) {
      expect(
        AppConfig.parse(url: 'https://example.supabase.co', key: key),
        isA<Failure<AppConfig>>(),
      );
    }
    expect(
      AppConfig.parse(url: 'https://example.supabase.co', key: jwt('anon')),
      isA<Success<AppConfig>>(),
    );
  });
}
