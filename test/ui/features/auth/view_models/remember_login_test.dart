import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/data/repositories/auth_repository_impl.dart';
import 'package:abrigo_dos_anjos/data/models/session_dto.dart';
import 'package:abrigo_dos_anjos/domain/models/session_access.dart';
import 'package:abrigo_dos_anjos/ui/features/auth/view_models/login_view_model.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import '../../../../support/fakes/fake_auth_repository.dart';
import '../../../../support/fakes/fake_auth_service.dart';

void main() {
  test('repository forwards unchecked persistence to Service', () async {
    final service = FakeAuthService()
      ..handler = (_, _) async =>
          const Success(SessionDto(userId: 'user', isStaffActive: true));
    addTearDown(service.dispose);
    await AuthRepositoryImpl(
      service,
    ).signIn('p@example.test', 'test', remember: false);
    expect(service.calls.single.arguments.last, isFalse);
  });
  test(
    'VM preserves unchecked choice on invalid input and blocks preference changes during login',
    () async {
      final gate = Completer<Result<SessionAccess>>();
      final repo = FakeAuthRepository()..handler = (_, _) => gate.future;
      addTearDown(repo.dispose);
      final vm = LoginViewModel(repo);
      addTearDown(vm.dispose);
      vm.setRemember(false);
      await vm.submit('bad', '');
      expect(vm.state.remember, isFalse);
      final work = vm.submit('p@example.test', 'test');
      vm.setRemember(true);
      expect(vm.state.remember, isFalse);
      expect(repo.calls.single.arguments.last, isFalse);
      gate.complete(
        const Success(
          SessionAccess(level: AccessLevel.authorized, userId: 'user'),
        ),
      );
      await work;
      expect(vm.state.signedIn, isTrue);
      expect(vm.state.toString(), isNot(contains('password')));
    },
  );
}
