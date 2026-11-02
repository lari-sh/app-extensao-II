import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:abrigo_dos_anjos/data/services/supabase_team_service.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import '../../support/auth_fixtures.dart';

void main() {
  test(
    'send and reconciliation use different HTTP methods and preserve one operation key',
    () async {
      final requests = <http.Request>[];
      final client = SupabaseClient(
        'https://example.test',
        'public',
        httpClient: MockClient((r) async {
          requests.add(r);
          return http.Response(
            jsonEncode({'state': 'pending'}),
            202,
            request: r,
            headers: {'content-type': 'application/json'},
          );
        }),
      );
      addTearDown(client.dispose);
      final service = SupabaseTeamService(client);
      expect(
        await service.send({'action': 'invite', 'operation_key': 'stable-key'}),
        isA<Success<Map<String, Object?>>>(),
      );
      expect(
        await service.reconcile('stable-key'),
        isA<Success<Map<String, Object?>>>(),
      );
      expect(requests[0].method, 'POST');
      expect(jsonDecode(requests[0].body)['operation_key'], 'stable-key');
      expect(requests[1].method, 'GET');
      expect(requests[1].url.queryParameters, {'operation_key': 'stable-key'});
      expect(requests[1].body, isEmpty);
    },
  );
  for (final code in [
    'existing_account',
    'invitation_cooldown',
    'administrator_required',
  ]) {
    test(
      'function $code is translated without leaking server details',
      () async {
        final client = SupabaseClient(
          'https://example.test',
          'public',
          httpClient: MockClient(
            (r) async => http.Response(
              jsonEncode({'code': code, 'debug': 'private database detail'}),
              409,
              request: r,
              headers: {'content-type': 'application/json'},
            ),
          ),
        );
        addTearDown(client.dispose);
        final result = await SupabaseTeamService(
          client,
        ).send({'action': 'invite'});
        expect(result, isA<Failure<Map<String, Object?>>>());
        final failure = (result as Failure<Map<String, Object?>>).failure;
        expect(failure.fieldErrors['team'], isNotEmpty);
        expect(failure.fieldErrors.toString(), isNot(contains('private')));
      },
    );
  }
  test(
    'unknown function error is sanitized and null own invitation is allowed',
    () async {
      var error = true;
      final client = SupabaseClient(
        'https://example.test',
        'public',
        httpClient: MockClient(
          (r) async => http.Response(
            error ? jsonEncode({'code': 'internal_secret'}) : 'null',
            error ? 503 : 200,
            request: r,
            headers: {'content-type': 'application/json'},
          ),
        ),
      );
      addTearDown(client.dispose);
      final service = SupabaseTeamService(client);
      final failed = await service.send({});
      expect(
        (failed as Failure<Map<String, Object?>>).failure.fieldErrors,
        isEmpty,
      );
      error = false;
      expect(
        (await service.request('get_my_invitation', {})
                as Success<Map<String, Object?>?>)
            .value,
        isNull,
      );
    },
  );
  test(
    'password updates stay inside SDK service and return only Unit',
    () async {
      final requests = <http.Request>[];
      final client = SupabaseClient(
        'https://example.test',
        'public',
        authOptions: const AuthClientOptions(autoRefreshToken: false),
        httpClient: MockClient((r) async {
          requests.add(r);
          return http.Response(
            jsonEncode(
              r.url.path.endsWith('/token')
                  ? authSessionJson()
                  : authUserJson(),
            ),
            200,
            request: r,
            headers: {'content-type': 'application/json'},
          );
        }),
      );
      addTearDown(client.dispose);
      await client.auth.signInWithPassword(
        email: 'p@example.test',
        password: 'test-only',
      );
      expect(
        await SupabaseTeamService(
          client,
        ).definePassword('a-long-test-password'),
        isA<Success<Unit>>(),
      );
      expect(requests.last.method, 'PUT');
      expect(
        jsonDecode(requests.last.body)['password'],
        'a-long-test-password',
      );
    },
  );
}
