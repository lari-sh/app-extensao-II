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
  Future<Result<SessionAccess>> signIn(String email, String password) =>
      invoke<SessionAccess>('signIn', [email, password]);
  @override
  Stream<Result<SessionAccess>> watchAccess() => events.stream;
  @override
  Future<Result<Unit>> signOut() => invoke<Unit>('signOut', []);
}
