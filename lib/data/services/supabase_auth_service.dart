import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../utils/app_failure.dart';
import '../../utils/result.dart';
import '../models/session_dto.dart';
import 'auth_service.dart';
import 'service_result.dart';

class SupabaseAuthService implements AuthService {
  SupabaseAuthService(this.client, {Stream<AuthState>? events})
    : events = events ?? client.auth.onAuthStateChange;
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
  Future<Result<SessionDto>> signIn(String email, String password) async {
    return serviceResult(() async {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user == null ||
          client.auth.currentSession?.user.id != response.user!.id) {
        throw const ServiceFailure(FailureCode.unauthenticated);
      }
      return _verifyCurrent();
    });
  }

  Future<SessionDto> _verifyCurrent() async {
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
  Future<Result<Unit>> signOut() => serviceResult(() async {
    // This SDK removes its local session before attempting remote revocation.
    await client.auth.signOut(scope: SignOutScope.global);
    return Unit.value;
  });
}
