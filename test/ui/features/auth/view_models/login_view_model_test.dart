import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/ui/features/auth/view_models/login_view_model.dart';
import 'package:abrigo_dos_anjos/domain/models/session_access.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import 'package:abrigo_dos_anjos/utils/app_failure.dart';
import '../../../../support/fakes/fake_auth_repository.dart';

void main() {
  test('validation remains in VM and sends no invalid request', () async {
    final repo = FakeAuthRepository();
    addTearDown(repo.dispose);
    final vm = LoginViewModel(repo);
    addTearDown(vm.dispose);
    await vm.submit('invalid', '');
    expect(vm.state.fieldErrors.keys, containsAll(['email', 'password']));
    expect(repo.calls, isEmpty);
  });
  test(
    'login blocks duplicates and exposes authorized success without credentials in state',
    () async {
      final delayed = Completer<Object?>();
      final repo = FakeAuthRepository()..handler = (_, args) => delayed.future;
      addTearDown(repo.dispose);
      final vm = LoginViewModel(repo);
      addTearDown(vm.dispose);
      final login = vm.submit(' staff@example.test ', 'secret');
      await vm.submit('staff@example.test', 'secret');
      expect(repo.calls.length, 1);
      expect(vm.state.busy, isTrue);
      delayed.complete(
        const Success(
          SessionAccess(level: AccessLevel.authorized, userId: 'u'),
        ),
      );
      await login;
      expect(vm.state.signedIn, isTrue);
      expect(vm.state.busy, isFalse);
      expect(repo.calls.single.arguments.first, 'staff@example.test');
    },
  );
  test(
    'invalid credentials are generic and nonstaff cannot navigate privately',
    () async {
      final repo = FakeAuthRepository()
        ..handler = (_, args) async =>
            Failure<SessionAccess>(AppFailure(FailureCode.unauthenticated));
      addTearDown(repo.dispose);
      final vm = LoginViewModel(repo);
      addTearDown(vm.dispose);
      await vm.submit('staff@example.test', 'wrong');
      expect(
        vm.state.message,
        'Não foi possível entrar. Confira suas credenciais e tente novamente.',
      );
      repo.handler = (_, args) async => const Success(
        SessionAccess(
          level: AccessLevel.authenticatedWithoutStaff,
          userId: 'u',
        ),
      );
      await vm.submit('staff@example.test', 'pass');
      expect(vm.state.signedIn, isFalse);
      expect(vm.state.message, contains('autorização'));
    },
  );
  test(
    'disposed or invalidated login never confirms a late response',
    () async {
      final delayed = Completer<Object?>();
      var current = true;
      var confirmed = 0;
      final repo = FakeAuthRepository()..handler = (_, args) => delayed.future;
      addTearDown(repo.dispose);
      final vm = LoginViewModel(
        repo,
        beginAttempt: () => 1,
        isAttemptCurrent: (_) => current,
        onAccess: (_, access) {
          confirmed++;
          return true;
        },
      );
      final login = vm.submit('staff@example.test', 'pass');
      current = false;
      delayed.complete(
        const Success(
          SessionAccess(level: AccessLevel.authorized, userId: 'u'),
        ),
      );
      await login;
      expect(confirmed, 0);
      expect(vm.state.signedIn, isFalse);
      vm.dispose();
    },
  );
}
