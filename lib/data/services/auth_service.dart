import '../../utils/result.dart';
import '../models/session_dto.dart';

abstract interface class AuthService {
  Future<Result<SessionDto>> signIn(
    String email,
    String password, {
    bool remember = true,
  });
  Future<Result<SessionDto>> currentAccess();
  Stream<Result<SessionDto>> watchAccess();
  Future<Result<Unit>> signOut();
}
