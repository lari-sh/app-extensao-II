import '../../utils/result.dart';
import '../models/session_access.dart';

abstract interface class AuthRepository {
  Future<Result<SessionAccess>> restoreAccess();
  Future<Result<SessionAccess>> currentAccess();
  Future<Result<SessionAccess>> signIn(
    String email,
    String password, {
    bool remember = true,
  });
  Stream<Result<SessionAccess>> watchAccess();
  Future<Result<Unit>> requestPasswordReset(String email);
  Future<Result<bool>> canResetPassword();
  Future<Result<Unit>> updateRecoveredPassword(String password);
  Future<Result<Unit>> signOut();
}
