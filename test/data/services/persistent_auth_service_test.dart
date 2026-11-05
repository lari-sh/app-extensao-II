import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:abrigo_dos_anjos/data/services/supabase_auth_service.dart';
import 'package:abrigo_dos_anjos/data/services/session_storage_service.dart';
import 'package:abrigo_dos_anjos/data/models/session_dto.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import 'package:abrigo_dos_anjos/utils/app_failure.dart';
import '../../support/auth_fixtures.dart';

class PersistenceFake implements SessionPersistenceService {
  bool? choice;
  String? saved;
  bool deny = false, failCommit = false;
  @override
  Future<Result<int>> prepareSignIn(bool remember) async {
    choice = remember;
    return deny
        ? Failure<int>(AppFailure(FailureCode.configuration))
        : const Success(7);
  }

  @override
  Future<Result<Unit>> confirmSignIn(int ticket, String session) async {
    saved = session;
    return failCommit
        ? Failure<Unit>(AppFailure(FailureCode.configuration))
        : const Success(Unit.value);
  }
}

void main() {
  for (final remember in [true, false]) {
    test(
      'SDK confirms chosen persistence only after verified sign-in ($remember)',
      () async {
        final storage = PersistenceFake();
        final client = SupabaseClient(
          'https://example.test',
          'public',
          authOptions: const AuthClientOptions(autoRefreshToken: false),
          httpClient: MockClient(
            (r) async => http.Response(
              jsonEncode(
                r.url.path.endsWith('/token')
                    ? authSessionJson()
                    : r.url.path.endsWith('/user')
                    ? authUserJson()
                    : {
                        'user_id': authUserId,
                        'is_session_current': true,
                        'is_staff_active': true,
                        'staff_role': 'employee',
                      },
              ),
              200,
              request: r,
              headers: {'content-type': 'application/json'},
            ),
          ),
        );
        addTearDown(client.dispose);
        final result = await SupabaseAuthService(
          client,
          persistence: storage,
        ).signIn('p@example.test', 'test-password', remember: remember);
        expect(result, isA<Success<SessionDto>>());
        expect(storage.choice, remember);
        expect(
          (jsonDecode(storage.saved!) as Map).containsKey('password'),
          isFalse,
        );
      },
    );
  }
  test('preference preparation failure never calls Auth', () async {
    var calls = 0;
    final client = SupabaseClient(
      'https://example.test',
      'public',
      httpClient: MockClient((r) async {
        calls++;
        return http.Response('{}', 200, request: r);
      }),
    );
    addTearDown(client.dispose);
    expect(
      await SupabaseAuthService(
        client,
        persistence: PersistenceFake()..deny = true,
      ).signIn('p@example.test', 'test'),
      isA<Failure<SessionDto>>(),
    );
    expect(calls, 0);
  });
  test(
    'failed durable session write clears SDK session and cannot report login success',
    () async {
      final storage = PersistenceFake()..failCommit = true;
      final client = SupabaseClient(
        'https://example.test',
        'public',
        authOptions: const AuthClientOptions(autoRefreshToken: false),
        httpClient: MockClient(
          (r) async => r.url.path.endsWith('/logout')
              ? http.Response('', 204, request: r)
              : http.Response(
                  jsonEncode(
                    r.url.path.endsWith('/token')
                        ? authSessionJson()
                        : r.url.path.endsWith('/user')
                        ? authUserJson()
                        : {
                            'user_id': authUserId,
                            'is_session_current': true,
                            'is_staff_active': true,
                            'staff_role': 'employee',
                          },
                  ),
                  200,
                  request: r,
                  headers: {'content-type': 'application/json'},
                ),
        ),
      );
      addTearDown(client.dispose);
      expect(
        await SupabaseAuthService(
          client,
          persistence: storage,
        ).signIn('p@example.test', 'test'),
        isA<Failure<SessionDto>>(),
      );
      expect(client.auth.currentSession, isNull);
    },
  );
}
