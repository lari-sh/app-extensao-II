import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/domain/models/session_access.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import 'package:abrigo_dos_anjos/ui/features/auth/view_models/session_view_model.dart';
import '../../../../support/fakes/fake_auth_repository.dart';

class BrokenAccessStream extends FakeAuthRepository {
  @override
  Stream<Result<SessionAccess>> watchAccess() =>
      throw StateError('private stream');
}

void main() {
  const access = SessionAccess(
    level: AccessLevel.authorized,
    userId: 'staff',
    role: StaffRole.administrator,
  );
  test(
    'restore exception fails closed without leaking transport details',
    () async {
      final repo = FakeAuthRepository()
        ..handler = (_, _) async => throw StateError('private');
      addTearDown(repo.dispose);
      final vm = SessionViewModel(repo);
      addTearDown(vm.dispose);
      await vm.start();
      expect(vm.state.phase, SessionPhase.unavailable);
      expect(vm.state.canAccessPrivate, isFalse);
      expect(vm.state.canManageTeam, isFalse);
      expect(vm.state.message, isNot(contains('private')));
    },
  );
  test('access stream error removes previously authorized context', () async {
    final repo = FakeAuthRepository()
      ..handler = (_, _) async => const Success(access);
    addTearDown(repo.dispose);
    final vm = SessionViewModel(repo);
    addTearDown(vm.dispose);
    await vm.start();
    final generation = vm.state.privateGeneration;
    repo.events.addError(StateError('private stream'));
    await Future<void>.delayed(Duration.zero);
    expect(vm.state.phase, SessionPhase.unavailable);
    expect(vm.state.canManageTeam, isFalse);
    expect(vm.state.privateGeneration, greaterThan(generation));
  });
  test(
    'subscription creation failure is caught and remains unavailable after failed restore',
    () async {
      final repo = BrokenAccessStream()
        ..handler = (_, _) async => throw StateError('private');
      addTearDown(repo.dispose);
      final vm = SessionViewModel(repo);
      addTearDown(vm.dispose);
      await vm.start();
      expect(vm.state.canAccessPrivate, isFalse);
      expect(vm.state.phase, SessionPhase.unavailable);
    },
  );
  test(
    'revalidation exception drops private capability and invalidates old epoch',
    () async {
      final repo = FakeAuthRepository()
        ..handler = (_, _) async => const Success(access);
      addTearDown(repo.dispose);
      final vm = SessionViewModel(repo);
      addTearDown(vm.dispose);
      await vm.start();
      final epoch = vm.state.accessEpoch;
      repo.handler = (_, _) async => throw StateError('private');
      await vm.revalidate();
      expect(vm.canUsePrivate(epoch), isFalse);
      expect(vm.state.hidePrivate, isTrue);
      expect(vm.state.retainPrivate, isFalse);
    },
  );
  test(
    'failed sign-in only accepts the current ticket and returns to visitor',
    () async {
      final repo = FakeAuthRepository()
        ..handler = (_, _) async => const Success(SessionAccess());
      addTearDown(repo.dispose);
      final vm = SessionViewModel(repo);
      addTearDown(vm.dispose);
      await vm.start();
      final ticket = vm.beginSignIn()!;
      vm.failSignIn(ticket + 1);
      expect(vm.isAttemptCurrent(ticket), isTrue);
      vm.failSignIn(ticket);
      expect(vm.isAttemptCurrent(ticket), isFalse);
      expect(vm.state.phase, SessionPhase.visitor);
      expect(vm.state.canManageTeam, isFalse);
    },
  );
  test(
    'logout transport exception still clears private identity and spinner',
    () async {
      final repo = FakeAuthRepository()
        ..handler = (_, _) async => const Success(access);
      addTearDown(repo.dispose);
      final vm = SessionViewModel(repo);
      addTearDown(vm.dispose);
      await vm.start();
      repo.handler = (_, _) async => throw StateError('private');
      await vm.signOut();
      expect(vm.state.userId, isNull);
      expect(vm.state.canAccessPrivate, isFalse);
      expect(vm.state.canManageTeam, isFalse);
      expect(vm.state.signingOut, isFalse);
      expect(vm.state.message, contains('neste dispositivo'));
      expect(vm.state.message, isNot(contains('private')));
    },
  );
}
