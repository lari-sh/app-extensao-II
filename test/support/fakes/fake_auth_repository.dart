import 'dart:async';
import 'fake_behavior.dart';
import 'package:abrigo_dos_anjos/domain/repositories/auth_repository.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import 'package:abrigo_dos_anjos/domain/models/session_access.dart';

class FakeAuthRepository extends FakeBehavior implements AuthRepository {
  final events = StreamController<Result<SessionAccess>>.broadcast();
  Future<void> dispose() => events.close();
  @override
  Future<Result<SessionAccess>> restoreAccess() =>
      invoke<SessionAccess>('restoreAccess', []);
  @override
  Future<Result<SessionAccess>> currentAccess() =>
      invoke<SessionAccess>('currentAccess', []);
  @override
  Future<Result<SessionAccess>> signIn(
    String email,
    String password, {
    bool remember = true,
  }) => invoke<SessionAccess>('signIn', [email, password, remember]);
  @override
  Stream<Result<SessionAccess>> watchAccess() => events.stream;
  @override
  Future<Result<Unit>> requestPasswordReset(String email) =>
      invoke<Unit>('requestPasswordReset', [email]);
  @override
  Future<Result<bool>> canResetPassword() =>
      invoke<bool>('canResetPassword', []);
  @override
  Future<Result<Unit>> updateRecoveredPassword(String password) =>
      invoke<Unit>('updateRecoveredPassword', [password]);
  @override
  Future<Result<Unit>> signOut() => invoke<Unit>('signOut', []);
}
