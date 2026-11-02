import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:abrigo_dos_anjos/data/services/supabase_auth_service.dart';
import 'package:abrigo_dos_anjos/data/services/supabase_auth_callback_service.dart';
import 'package:abrigo_dos_anjos/data/models/session_dto.dart';
import 'package:abrigo_dos_anjos/data/repositories/auth_repository_impl.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import '../../support/auth_fixtures.dart';
import '../../support/fakes/fake_auth_service.dart';

class MemoryPkce extends GotrueAsyncStorage {
  final values = <String, String>{};
  @override
  Future<String?> getItem({required String key}) async => values[key];
  @override
  Future<void> setItem({required String key, required String value}) async {
    values[key] = value;
  }

  @override
  Future<void> removeItem({required String key}) async {
    values.remove(key);
  }
}

void main() {
  for (final status in [200, 429, 422, 500]) {
    test(
      'reset request sanitizes provider response $status and fixes callback',
      () async {
        Uri? target;
        final client = SupabaseClient(
          'https://example.test',
          'public',
          authOptions: AuthClientOptions(pkceAsyncStorage: MemoryPkce()),
          httpClient: MockClient((r) async {
            target = r.url;
            expect(jsonDecode(r.body)['email'], 'person@example.test');
            return http.Response(
              jsonEncode(
                status == 200
                    ? {}
                    : {
                        'error_code': status == 422
                            ? 'user_not_found'
                            : status == 429
                            ? 'over_email_send_rate_limit'
                            : 'server_error',
                        'msg': 'sensitive provider detail',
                      },
              ),
              status,
              request: r,
            );
          }),
        );
        addTearDown(client.dispose);
        final result = await SupabaseAuthService(
          client,
        ).requestPasswordReset('person@example.test');
        expect(
          result,
          status == 500 ? isA<Failure<Unit>>() : isA<Success<Unit>>(),
        );
        expect(
          target!.queryParameters['redirect_to'],
          'br.org.abrigodosanjos.app://auth/recovery',
        );
      },
    );
  }
  test(
    'normal authenticated session cannot update recovered password',
    () async {
      var updates = 0;
      final client = SupabaseClient(
        'https://example.test',
        'public',
        authOptions: const AuthClientOptions(autoRefreshToken: false),
        httpClient: MockClient((r) async {
          if (r.method == 'PUT') updates++;
          return http.Response(
            jsonEncode(
              (r.url.path.endsWith('/token') || r.url.path.endsWith('/verify'))
                  ? authSessionJson()
                  : authUserJson(),
            ),
            200,
            request: r,
          );
        }),
      );
      addTearDown(client.dispose);
      await client.auth.signInWithPassword(
        email: 'person@example.test',
        password: 'test-only',
      );
      final callbacks = SupabaseAuthCallbackService();
      callbacks.start(client);
      addTearDown(callbacks.dispose);
      final service = SupabaseAuthService(client, callbacks: callbacks);
      expect(
        (await service.canResetPassword() as Success<bool>).value,
        isFalse,
      );
      expect(
        await service.updateRecoveredPassword('long-new-password'),
        isA<Failure<Unit>>(),
      );
      expect(updates, 0);
    },
  );
  test(
    'verified recovery blocks private access, saves once and signs out',
    () async {
      var updates = 0;
      final client = SupabaseClient(
        'https://example.test',
        'public',
        authOptions: const AuthClientOptions(autoRefreshToken: false),
        httpClient: MockClient((r) async {
          if (r.method == 'PUT') updates++;
          if (r.url.path.endsWith('/logout')) {
            return http.Response('', 204, request: r);
          }
          return http.Response(
            jsonEncode(
              (r.url.path.endsWith('/token') || r.url.path.endsWith('/verify'))
                  ? authSessionJson()
                  : authUserJson(),
            ),
            200,
            request: r,
          );
        }),
      );
      addTearDown(client.dispose);
      final callbacks = SupabaseAuthCallbackService();
      callbacks.start(client);
      addTearDown(callbacks.dispose);
      callbacks.capture(Uri.parse('br.org.abrigodosanjos.app://auth/recovery'));
      await client.auth.signInWithPassword(
        email: 'person@example.test',
        password: 'test-only',
      );
      await client.auth.verifyOTP(tokenHash: 'fixture-only', type: OtpType.recovery);
      await Future<void>.delayed(Duration.zero);
      final service = SupabaseAuthService(client, callbacks: callbacks);
      expect(
        (await service.currentAccess() as Success<SessionDto>).value.userId,
        isNull,
      );
      expect((await service.canResetPassword() as Success<bool>).value, isTrue);
      expect(
        await service.updateRecoveredPassword('short'),
        isA<Failure<Unit>>(),
      );
      expect(
        await service.updateRecoveredPassword('long-new-password'),
        isA<Success<Unit>>(),
      );
      expect(updates, 1);
      expect(client.auth.currentSession, isNull);
      expect(
        await service.updateRecoveredPassword('long-new-password'),
        isA<Failure<Unit>>(),
      );
    },
  );
  test(
    'Repository forwards recovery results and contains thrown errors',
    () async {
      final service = FakeAuthService();
      addTearDown(service.dispose);
      service.handler = (method, args) async => switch (method) {
        'requestPasswordReset' => const Success(Unit.value),
        'canResetPassword' => const Success(true),
        _ => throw StateError('sensitive'),
      };
      final repo = AuthRepositoryImpl(service);
      expect(
        await repo.requestPasswordReset('p@example.test'),
        isA<Success<Unit>>(),
      );
      expect((await repo.canResetPassword() as Success<bool>).value, isTrue);
      expect(
        await repo.updateRecoveredPassword('test-password'),
        isA<Failure<Unit>>(),
      );
    },
  );
}
