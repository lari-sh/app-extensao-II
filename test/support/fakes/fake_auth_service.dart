import 'dart:async';
import 'fake_behavior.dart';
import 'package:abrigo_dos_anjos/data/services/auth_service.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import 'package:abrigo_dos_anjos/data/models/session_dto.dart';

class FakeAuthService extends FakeBehavior implements AuthService {
  final events = StreamController<Result<SessionDto>>.broadcast();
  Future<void> dispose() => events.close();
  @override
  Future<Result<SessionDto>> signIn(String email, String password) =>
      invoke<SessionDto>('signIn', [email, password]);
  @override
  Future<Result<SessionDto>> currentAccess() =>
      invoke<SessionDto>('currentAccess', []);
  @override
  Stream<Result<SessionDto>> watchAccess() => events.stream;
  @override
  Future<Result<Unit>> signOut() => invoke<Unit>('signOut', []);
}
