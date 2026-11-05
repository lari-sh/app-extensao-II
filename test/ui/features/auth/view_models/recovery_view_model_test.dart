import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/ui/features/auth/view_models/recovery_view_model.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import 'package:abrigo_dos_anjos/utils/app_failure.dart';
import '../../../../support/fakes/fake_auth_repository.dart';

void main() {
  test(
    'request validates, trims, prevents duplicate requests and ignores disposed completion',
    () async {
      final repo = FakeAuthRepository();
      addTearDown(repo.dispose);
      final pending = Completer<Result<Unit>>();
      repo.handler = (m, a) => pending.future;
      final vm = RecoveryViewModel(repo);
      await vm.submit('invalid');
      expect(vm.state.errors['email'], isNotNull);
      expect(repo.calls, isEmpty);
      final operation = vm.submit(' person@example.test ');
      await vm.submit('other@example.test');
      expect(repo.calls.length, 1);
      expect(repo.calls.single.arguments.single, 'person@example.test');
      var notifications = 0;
      vm.addListener(() => notifications++);
      vm.dispose();
      pending.complete(const Success(Unit.value));
      await operation;
      expect(notifications, 0);
    },
  );
  test('request has neutral success and sanitized failure', () async {
    final repo = FakeAuthRepository();
    addTearDown(repo.dispose);
    repo.handler = (m, a) async =>
        Failure<Unit>(AppFailure(FailureCode.network));
    final vm = RecoveryViewModel(repo);
    addTearDown(vm.dispose);
    await vm.submit('p@example.test');
    expect(vm.state.completed, isFalse);
    expect(vm.state.message, contains('conexão'));
    repo.handler = (m, a) async => const Success(Unit.value);
    await vm.submit('p@example.test');
    expect(vm.state.completed, isTrue);
    await vm.submit('p@example.test');
    expect(repo.calls.length, 2);
  });
  test(
    'reset verifies link, validates length and matching, never keeps password in state',
    () async {
      final repo = FakeAuthRepository();
      addTearDown(repo.dispose);
      repo.handler = (m, a) async => m == 'canResetPassword'
          ? const Success(true)
          : const Success(Unit.value);
      final vm = ResetPasswordViewModel(repo);
      addTearDown(vm.dispose);
      await vm.submit('long-new-password', 'long-new-password');
      expect(repo.calls, isEmpty);
      await vm.load();
      expect(vm.state.available, isTrue);
      await vm.submit('short', 'other');
      expect(vm.state.errors.length, 2);
      await vm.submit('long-new-password', 'long-new-password');
      expect(vm.state.completed, isTrue);
      expect(vm.state.toString(), isNot(contains('long-new-password')));
      await vm.submit('long-new-password', 'long-new-password');
      expect(repo.calls.length, 2);
    },
  );
  test(
    'reset unavailable, provider failures and busy/dispose preserve safe state',
    () async {
      final repo = FakeAuthRepository();
      addTearDown(repo.dispose);
      repo.handler = (m, a) async => const Success(false);
      final vm = ResetPasswordViewModel(repo);
      await vm.load();
      expect(vm.state.available, isFalse);
      expect(vm.state.message, contains('expirou'));
      repo.handler = (m, a) async => m == 'canResetPassword'
          ? const Success(true)
          : Failure<Unit>(AppFailure(FailureCode.network));
      await vm.load();
      await vm.submit('long-new-password', 'long-new-password');
      expect(vm.state.message, contains('Não foi possível'));
      final pending = Completer<Result<Unit>>();
      repo.handler = (m, a) => pending.future;
      final operation = vm.submit('long-new-password', 'long-new-password');
      final count = repo.calls.length;
      await vm.submit('long-new-password', 'long-new-password');
      expect(repo.calls.length, count);
      vm.dispose();
      pending.complete(const Success(Unit.value));
      await operation;
    },
  );
}
