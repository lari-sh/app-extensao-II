import 'dart:async';
import 'fake_behavior.dart';
import 'package:abrigo_dos_anjos/data/services/auth_service.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import 'package:abrigo_dos_anjos/data/models/session_dto.dart';

class FakeAuthService extends FakeBehavior implements AuthService {
  final events = StreamController<Result<SessionDto>>.broadcast();
  Future<void> dispose() => events.close();
  @override
  Future<Result<SessionDto>> signIn(
    String email,
    String password, {
    bool remember = true,
  }) => invoke<SessionDto>('signIn', [email, password, remember]);
  @override
  Future<Result<SessionDto>> currentAccess() =>
      invoke<SessionDto>('currentAccess', []);
  @override
  Stream<Result<SessionDto>> watchAccess() => events.stream;
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
