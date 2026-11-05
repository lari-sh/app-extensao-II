import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:abrigo_dos_anjos/data/services/supabase_auth_callback_service.dart';
import 'package:abrigo_dos_anjos/domain/models/auth_callback.dart';
import '../../support/auth_fixtures.dart';

void main() {
  test(
    'recovery survives refresh and delivers a buffered verified intent to late subscriber',
    () async {
      var refreshed = false;
      final client = SupabaseClient(
        'https://example.test',
        'public',
        authOptions: const AuthClientOptions(autoRefreshToken: false),
        httpClient: MockClient(
          (r) async => http.Response(
            jsonEncode(
              authSessionJson(
                expiresAt:
                    DateTime.now().millisecondsSinceEpoch ~/ 1000 +
                    (refreshed ? 7200 : 3600),
              ),
            ),
            200,
            request: r,
            headers: {'content-type': 'application/json'},
          ),
        ),
      );
      final service = SupabaseAuthCallbackService();
      service.start(client);
      expect(
        service.capture(Uri.parse('br.org.abrigodosanjos.app://auth/recovery')),
        isTrue,
      );
      await client.auth.verifyOTP(
        email: 'fixture@example.test',
        token: '123456',
        type: OtpType.recovery,
      );
      await Future<void>.delayed(Duration.zero);
      expect(await service.watch().first, AuthCallbackKind.recovery);
      expect(service.isVerifiedRecovery(client), isTrue);
      refreshed = true;
      await client.auth.refreshSession();
      await Future<void>.delayed(Duration.zero);
      expect(service.isVerifiedRecovery(client), isTrue);
      await service.dispose();
      await client.dispose();
    },
  );
  test(
    'SDK initial-session failure finishes redacted callback without granting access',
    () async {
      final client = SupabaseClient(
        'https://example.test',
        'public',
        authOptions: const AuthClientOptions(autoRefreshToken: false),
      );
      final service = SupabaseAuthCallbackService();
      service.start(client);
      service.capture(Uri.parse('br.org.abrigodosanjos.app://auth/invite'));
      final route = service.watch().first;
      await expectLater(
        client.auth.setInitialSession('{}'),
        throwsA(isA<AuthException>()),
      );
      expect(await route, AuthCallbackKind.invitation);
      expect(service.isVerifiedRecovery(client), isFalse);
      await service.dispose();
      await client.dispose();
    },
  );

  for (final lateSubscriber in [false, true]) {
    test(
      'verified SDK invite event is delivered once to ${lateSubscriber ? 'late' : 'current'} subscriber without URI data',
      () async {
        final client = SupabaseClient(
          'https://example.test',
          'public',
          authOptions: const AuthClientOptions(autoRefreshToken: false),
          httpClient: MockClient(
            (r) async => http.Response(
              jsonEncode(authSessionJson()),
              200,
              request: r,
              headers: {'content-type': 'application/json'},
            ),
          ),
        );
        final service = SupabaseAuthCallbackService();
        service.start(client);
        service.start(client);
        Future<AuthCallbackKind>? received;
        if (!lateSubscriber) received = service.watch().first;
        expect(
          service.capture(
            Uri.parse(
              'br.org.abrigodosanjos.app://auth/invite#access_token=test-only',
            ),
          ),
          isTrue,
        );
        await client.auth.signInWithPassword(
          email: 'p@example.test',
          password: 'test-only',
        );
        received ??= service.watch().first;
        expect(
          await received.timeout(const Duration(seconds: 1)),
          AuthCallbackKind.invitation,
        );
        await service.dispose();
        await client.dispose();
      },
    );
  }
  test(
    'replacing SDK client removes stale event source and completes current invitation',
    () async {
      SupabaseClient client() => SupabaseClient(
        'https://example.test',
        'public',
        authOptions: const AuthClientOptions(autoRefreshToken: false),
        httpClient: MockClient(
          (r) async => http.Response(
            jsonEncode(authSessionJson()),
            200,
            request: r,
            headers: {'content-type': 'application/json'},
          ),
        ),
      );
      final first = client(),
          second = client(),
          service = SupabaseAuthCallbackService();
      service.start(first);
      service.start(second);
      final received = service.watch().first;
      service.capture(Uri.parse('br.org.abrigodosanjos.app://auth/invite'));
      await second.auth.signInWithPassword(
        email: 'p@example.test',
        password: 'test-only',
      );
      expect(await received, AuthCallbackKind.invitation);
      await service.dispose();
      await first.dispose();
      await second.dispose();
    },
  );
}
