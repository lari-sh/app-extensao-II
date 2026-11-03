import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:abrigo_dos_anjos/data/services/supabase_auth_service.dart';
import 'package:abrigo_dos_anjos/data/models/session_dto.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import 'package:abrigo_dos_anjos/utils/app_failure.dart';
import '../../support/auth_fixtures.dart';

void main() {
  test(
    'expired stored session stays recoverable on transport stream error and initial event',
    () async {
      final client = SupabaseClient(
        'https://example.test',
        'public',
        authOptions: const AuthClientOptions(autoRefreshToken: false),
      );
      addTearDown(client.dispose);
      await client.auth.setInitialSession(
        jsonEncode(
          authSessionJson(
            expiresAt: DateTime.now().millisecondsSinceEpoch ~/ 1000 - 60,
          ),
        ),
      );
      final events = StreamController<AuthState>();
      addTearDown(events.close);
      final service = SupabaseAuthService(client, events: events.stream);
      final received = <Result<SessionDto>>[];
      final sub = service.watchAccess().listen(received.add);
      addTearDown(sub.cancel);
      events.addError(StateError('private transport detail'));
      events.add(
        AuthState(AuthChangeEvent.initialSession, client.auth.currentSession),
      );
      await Future<void>.delayed(Duration.zero);
      expect(received, hasLength(2));
      for (final result in received) {
        expect(
          (result as Success<SessionDto>).value.recoverableExpiration,
          isTrue,
        );
      }
      expect(
        await service.signIn(
          'fixture@example.test',
          'test-only',
          remember: false,
        ),
        isA<Failure<SessionDto>>(),
      );
    },
  );

  test(
    'team permission is read from verified access context, never user metadata',
    () async {
      var serverRole = 'administrator';
      var allowed = true;
      final client = SupabaseClient(
        'https://example.test',
        'public',
        authOptions: const AuthClientOptions(autoRefreshToken: false),
        httpClient: MockClient((request) async {
          final body = request.url.path.endsWith('/token')
              ? authSessionJson()
              : request.url.path.endsWith('/user')
              ? authUserJson()
              : {
                  'user_id': authUserId,
                  'is_session_current': true,
                  'is_staff_active': true,
                  'staff_role': serverRole,
                  'can_manage_team': allowed,
                };
          return http.Response(
            jsonEncode(body),
            200,
            request: request,
            headers: {'content-type': 'application/json'},
          );
        }),
      );
      addTearDown(client.dispose);
      final service = SupabaseAuthService(client);
      final initial =
          (await service.signIn('fixture@example.test', 'fake')
                  as Success<SessionDto>)
              .value;
      expect(initial.staffRole, 'administrator');
      expect(initial.canManageTeam, isTrue);
      allowed = false;
      expect(
        (await service.currentAccess() as Success<SessionDto>)
            .value
            .canManageTeam,
        isFalse,
      );
      serverRole = 'employee';
      allowed = true;
      expect(
        (await service.currentAccess() as Success<SessionDto>)
            .value
            .canManageTeam,
        isFalse,
      );
      serverRole = 'owner';
      final unknown =
          (await service.currentAccess() as Success<SessionDto>).value;
      expect(unknown.canManageTeam, isFalse);
      expect(unknown.staffRole, isNull);
    },
  );
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final staff in [true, false]) {
    test('SDK verifies user and current session before staff=$staff', () async {
      final calls = <String>[];
      final client = SupabaseClient(
        'https://example.test',
        'public',
        authOptions: const AuthClientOptions(autoRefreshToken: false),
        httpClient: MockClient((request) async {
          calls.add(request.url.path);
          final Object body;
          if (request.url.path.endsWith('/token')) {
            body = authSessionJson();
          } else if (request.url.path.endsWith('/user')) {
            body = authUserJson();
          } else {
            body = {
              'user_id': authUserId,
              'is_session_current': true,
              'is_staff_active': staff,
            };
          }
          return http.Response(
            jsonEncode(body),
            200,
            request: request,
            headers: {'content-type': 'application/json'},
          );
        }),
      );
      addTearDown(client.dispose);
      final result = await SupabaseAuthService(
        client,
      ).signIn('fixture@example.test', 'fake-password');
      final dto = (result as Success<SessionDto>).value;
      expect(dto.userId, authUserId);
      expect(dto.isStaffActive, staff);
      expect(calls, [
        '/auth/v1/token',
        '/auth/v1/user',
        '/rest/v1/rpc/access_context',
      ]);
    });
  }
  test(
    'visitor needs no request; invalid credentials become typed failure',
    () async {
      var calls = 0;
      final client = SupabaseClient(
        'https://example.test',
        'public',
        httpClient: MockClient((request) async {
          calls++;
          return http.Response(
            '{"msg":"raw invalid login","error_code":"invalid_credentials"}',
            400,
            request: request,
            headers: {'content-type': 'application/json'},
          );
        }),
      );
      addTearDown(client.dispose);
      final service = SupabaseAuthService(client);
      expect(
        (await service.currentAccess() as Success<SessionDto>).value.userId,
        isNull,
      );
      expect(calls, 0);
      expect(
        (await service.signIn('fixture@example.test', 'bad') as Failure)
            .failure
            .code,
        FailureCode.unauthenticated,
      );
    },
  );
  test(
    'revoked session cannot become authenticated even if user endpoint succeeds',
    () async {
      final client = SupabaseClient(
        'https://example.test',
        'public',
        authOptions: const AuthClientOptions(autoRefreshToken: false),
        httpClient: MockClient((request) async {
          final body = request.url.path.endsWith('/token')
              ? authSessionJson()
              : request.url.path.endsWith('/user')
              ? authUserJson()
              : {
                  'user_id': authUserId,
                  'is_session_current': false,
                  'is_staff_active': false,
                };
          return http.Response(
            jsonEncode(body),
            200,
            request: request,
            headers: {'content-type': 'application/json'},
          );
        }),
      );
      addTearDown(client.dispose);
      final dto =
          (await SupabaseAuthService(
                    client,
                  ).signIn('fixture@example.test', 'fake')
                  as Success<SessionDto>)
              .value;
      expect(dto.userId, isNull);
      expect(dto.recoverableExpiration, isFalse);
    },
  );
  test(
    'stream errors are converted and stream continues with visitor',
    () async {
      final events = StreamController<AuthState>();
      final client = SupabaseClient('https://example.test', 'public');
      addTearDown(client.dispose);
      final received = <Result<SessionDto>>[];
      final sub = SupabaseAuthService(
        client,
        events: events.stream,
      ).watchAccess().listen(received.add);
      events.addError(const AuthException('raw stream secret'));
      events.add(const AuthState(AuthChangeEvent.signedOut, null));
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      expect(received.first, isA<Failure<SessionDto>>());
      expect((received.last as Success<SessionDto>).value.userId, isNull);
      await sub.cancel();
      await events.close();
    },
  );
  test(
    'logout clears SDK locally even when remote confirmation fails',
    () async {
      var logout = false;
      final client = SupabaseClient(
        'https://example.test',
        'public',
        authOptions: const AuthClientOptions(autoRefreshToken: false),
        httpClient: MockClient((request) async {
          if (request.url.path.endsWith('/logout')) {
            logout = true;
            return http.Response(
              '{"msg":"raw failure"}',
              500,
              request: request,
              headers: {'content-type': 'application/json'},
            );
          }
          final body = request.url.path.endsWith('/token')
              ? authSessionJson()
              : request.url.path.endsWith('/user')
              ? authUserJson()
              : {
                  'user_id': authUserId,
                  'is_session_current': true,
                  'is_staff_active': true,
                };
          return http.Response(
            jsonEncode(body),
            200,
            request: request,
            headers: {'content-type': 'application/json'},
          );
        }),
      );
      addTearDown(client.dispose);
      final service = SupabaseAuthService(client);
      await service.signIn('fixture@example.test', 'fake');
      expect(await service.signOut(), isA<Failure<Unit>>());
      expect(client.auth.currentSession, isNull);
      expect(logout, isTrue);
    },
  );
}
