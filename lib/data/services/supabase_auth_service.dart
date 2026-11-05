import 'dart:convert';
import 'session_storage_service.dart';
import 'supabase_auth_callback_service.dart';
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../utils/app_failure.dart';
import '../../utils/result.dart';
import '../models/session_dto.dart';
import 'auth_service.dart';
import 'service_result.dart';

class SupabaseAuthService implements AuthService {
  SupabaseAuthService(
    this.client, {
    Stream<AuthState>? events,
    this.persistence,
    SupabaseAuthCallbackService? callbacks,
  }) : callbacks = callbacks ?? SupabaseAuthCallbackService.instance,
       events = events ?? client.auth.onAuthStateChange;
  final SupabaseAuthCallbackService callbacks;
  final SessionPersistenceService? persistence;
  final SupabaseClient client;
  final Stream<AuthState> events;
  SessionDto? _expiredSession() {
    final session = client.auth.currentSession;
    if (session != null &&
        session.expiresAt != null &&
        session.expiresAt! <= DateTime.now().millisecondsSinceEpoch ~/ 1000) {
      return SessionDto(userId: session.user.id, recoverableExpiration: true);
    }
    return null;
  }

  @override
  Future<Result<SessionDto>> signIn(
    String email,
    String password, {
    bool remember = true,
  }) async {
    int? persistenceTicket;
    if (persistence != null) {
      final prepared = await persistence!.prepareSignIn(remember);
      if (prepared case Failure<int>(:final failure)) return Failure(failure);
      persistenceTicket = (prepared as Success<int>).value;
    } else if (!remember) {
      return Failure(AppFailure(FailureCode.configuration));
    }
    final result = await serviceResult(() async {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user == null ||
          client.auth.currentSession?.user.id != response.user!.id) {
        throw const ServiceFailure(FailureCode.unauthenticated);
      }
      callbacks.finishRecovery();
      final verified = await _verifyCurrent();
      if (persistenceTicket != null) {
        final session = client.auth.currentSession;
        if (session == null) {
          throw const ServiceFailure(FailureCode.unauthenticated);
        }
        final confirmed = await persistence!.confirmSignIn(
          persistenceTicket,
          jsonEncode(session.toJson()),
        );
        if (confirmed case Failure<Unit>(:final failure)) {
          throw ServiceFailure(failure.code);
        }
      }
      return verified;
    });
    if (result is Failure<SessionDto>) {
      try {
        await client.auth.signOut(scope: SignOutScope.local);
      } catch (_) {}
    }
    return result;
  }

  Future<SessionDto> _verifyCurrent() async {
    if (callbacks.recoveryActive) return const SessionDto();
    final session = client.auth.currentSession;
    if (session == null) return const SessionDto();
    final expired = _expiredSession();
    if (expired != null) return expired;
    final verified = await client.auth.getUser();
    if (verified.user == null || verified.user!.id != session.user.id) {
      throw const ServiceFailure(FailureCode.unauthenticated);
    }
    final data = await client.rpc('access_context');
    if (client.auth.currentSession?.accessToken != session.accessToken) {
      throw const ServiceFailure(FailureCode.unauthenticated);
    }
    if (data is! Map ||
        data['user_id'] != verified.user!.id ||
        data['is_session_current'] != true) {
      return const SessionDto();
    }
    final staffRole = switch (data['staff_role']) {
      'administrator' => 'administrator',
      'employee' => 'employee',
      _ => null,
    };
    return SessionDto(
      userId: verified.user!.id,
      isStaffActive: data['is_staff_active'] == true,
      staffRole: data['is_staff_active'] == true ? staffRole : null,
      canManageTeam:
          data['is_staff_active'] == true &&
          staffRole == 'administrator' &&
          data['can_manage_team'] == true,
    );
  }

  @override
  Future<Result<SessionDto>> currentAccess() => serviceResult(_verifyCurrent);
  @override
  Stream<Result<SessionDto>> watchAccess() => events
      .transform(
        StreamTransformer<AuthState, Result<AuthState>>.fromHandlers(
          handleData: (event, sink) => sink.add(Success(event)),
          handleError: (Object error, StackTrace stack, sink) => sink.add(
            Failure(
              AppFailure(
                error is AuthException
                    ? FailureCode.unauthenticated
                    : FailureCode.unknown,
              ),
            ),
          ),
        ),
      )
      .asyncMap((event) async {
        if (event case Failure<AuthState>(:final failure)) {
          final expired = _expiredSession();
          if (expired != null && failure.code != FailureCode.unauthenticated) {
            return Success(expired);
          }
          return Failure<SessionDto>(failure);
        }
        final state = (event as Success<AuthState>).value;
        if (state.event == AuthChangeEvent.signedOut) {
          return const Success(SessionDto());
        }
        return currentAccess();
      });
  @override
  Future<Result<Unit>> requestPasswordReset(String email) =>
      serviceResult(() async {
        try {
          await client.auth.resetPasswordForEmail(
            email,
            redirectTo: 'br.org.abrigodosanjos.app://auth/recovery',
          );
        } on AuthException catch (error) {
          // Identical result for unknown accounts and provider throttling. No
          // account-existence signal or provider message crosses the boundary.
          if (error.statusCode != '429' &&
              error.code != 'user_not_found' &&
              error.code != 'over_email_send_rate_limit') {
            rethrow;
          }
        }
        return Unit.value;
      });
  @override
  Future<Result<bool>> canResetPassword() => serviceResult(() async {
    if (!callbacks.isVerifiedRecovery(client)) return false;
    final session = client.auth.currentSession;
    final user = await client.auth.getUser();
    return callbacks.isVerifiedRecovery(client) &&
        user.user?.id == session?.user.id;
  });
  @override
  Future<Result<Unit>> updateRecoveredPassword(
    String password,
  ) => serviceResult(() async {
    if (password.length < 12) {
      throw const ServiceFailure(FailureCode.validation);
    }
    final ready = await canResetPassword();
    if (ready is! Success<bool> || !ready.value) {
      throw const ServiceFailure(FailureCode.unauthenticated);
    }
    await client.auth.updateUser(UserAttributes(password: password));
    // Recovery never grants management access, including after a successful save.
    await client.auth.signOut(scope: SignOutScope.global);
    callbacks.finishRecovery();
    return Unit.value;
  });
  @override
  Future<Result<Unit>> signOut() => serviceResult(() async {
    // This SDK removes its local session before attempting remote revocation.
    await client.auth.signOut(scope: SignOutScope.global);
    return Unit.value;
  });
}
