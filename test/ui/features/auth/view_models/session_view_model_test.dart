import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/ui/features/auth/view_models/session_view_model.dart';
import 'package:abrigo_dos_anjos/domain/models/session_access.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import 'package:abrigo_dos_anjos/utils/app_failure.dart';
import '../../../../support/fakes/fake_auth_repository.dart';

const staff = SessionAccess(level: AccessLevel.authorized, userId: 'staff');
Future<void> settleEvents() async {
  await Future<void>.delayed(Duration.zero);
}

void main() {
  test('restore is fail closed until remote verification completes', () async {
    final delayed = Completer<Object?>();
    final repo = FakeAuthRepository()..handler = (_, args) => delayed.future;
    addTearDown(repo.dispose);
    final vm = SessionViewModel(repo);
    addTearDown(vm.dispose);
    final loading = vm.start();
    expect(vm.state.canAccessPrivate, isFalse);
    expect(vm.state.phase, SessionPhase.checking);
    delayed.complete(const Success(staff));
    await loading;
    expect(vm.state.canAccessPrivate, isTrue);
  });
  test(
    'expired draft stays masked and resumes only for same verified staff',
    () async {
      final repo = FakeAuthRepository()
        ..handler = (_, args) async => const Success(staff);
      addTearDown(repo.dispose);
      final vm = SessionViewModel(repo);
      addTearDown(vm.dispose);
      await vm.start();
      final generation = vm.state.privateGeneration;
      final epoch = vm.state.accessEpoch;
      repo.events.add(
        const Success(
          SessionAccess(
            userId: 'staff',
            interruption: AccessInterruption.recoverableExpiration,
          ),
        ),
      );
      await settleEvents();
      expect(vm.state.canAccessPrivate, isFalse);
      expect(vm.state.retainPrivate, isTrue);
      expect(vm.state.requiresReauthentication, isTrue);
      expect(vm.canUsePrivate(epoch), isFalse);
      final ticket = vm.beginSignIn()!;
      expect(vm.completeSignIn(ticket, staff), isTrue);
      expect(vm.state.privateGeneration, generation);
      expect(vm.state.hidePrivate, isFalse);
      repo.events.add(
        const Success(
          SessionAccess(
            userId: 'staff',
            interruption: AccessInterruption.recoverableExpiration,
          ),
        ),
      );
      await settleEvents();
      final next = vm.beginSignIn()!;
      vm.completeSignIn(
        next,
        const SessionAccess(level: AccessLevel.authorized, userId: 'different'),
      );
      expect(vm.state.privateGeneration, greaterThan(generation));
      expect(vm.state.userId, 'different');
    },
  );
  test(
    'nonstaff, revoked, unknown failure and reauth cancel discard private state',
    () async {
      for (final result in [
        const Success(
          SessionAccess(
            level: AccessLevel.authenticatedWithoutStaff,
            userId: 'staff',
          ),
        ),
        const Success(SessionAccess()),
        Failure<SessionAccess>(AppFailure(FailureCode.network)),
      ]) {
        final repo = FakeAuthRepository()
          ..handler = (_, args) async => const Success(staff);
        final vm = SessionViewModel(repo);
        await vm.start();
        final generation = vm.state.privateGeneration;
        repo.events.add(result);
        await settleEvents();
        expect(vm.state.canAccessPrivate, isFalse);
        expect(vm.state.retainPrivate, isFalse);
        expect(vm.state.privateGeneration, greaterThan(generation));
        vm.dispose();
        await repo.dispose();
      }
      final repo = FakeAuthRepository()
        ..handler = (method, args) async => method == 'signOut'
            ? const Success(Unit.value)
            : const Success(staff);
      final vm = SessionViewModel(repo);
      await vm.start();
      repo.events.add(
        const Success(
          SessionAccess(
            userId: 'staff',
            interruption: AccessInterruption.recoverableExpiration,
          ),
        ),
      );
      await settleEvents();
      vm.cancelReauthentication();
      expect(vm.state.retainPrivate, isFalse);
      vm.dispose();
      await repo.dispose();
    },
  );
  test(
    'logout immediately blocks private state and late restore/login even on remote failure',
    () async {
      final repo = FakeAuthRepository()
        ..handler = (_, args) async => const Success(staff);
      addTearDown(repo.dispose);
      final vm = SessionViewModel(repo);
      addTearDown(vm.dispose);
      await vm.start();
      final ticket = vm.beginSignIn()!;
      final logout = Completer<Object?>();
      repo.handler = (_, args) => logout.future;
      final leaving = vm.signOut();
      expect(vm.state.canAccessPrivate, isFalse);
      expect(vm.completeSignIn(ticket, staff), isFalse);
      logout.complete(Failure<Unit>(AppFailure(FailureCode.network)));
      await leaving;
      expect(vm.state.phase, SessionPhase.visitor);
      expect(vm.state.message, contains('neste dispositivo'));
      repo.events.add(const Success(staff));
      await settleEvents();
      expect(vm.state.canAccessPrivate, isFalse);
    },
  );
  test(
    'cancelled login ticket cannot restore private scope from a late response',
    () async {
      final repo = FakeAuthRepository()
        ..handler = (method, _) async => method == 'signOut'
            ? const Success(Unit.value)
            : const Success(SessionAccess());
      addTearDown(repo.dispose);
      final vm = SessionViewModel(repo);
      addTearDown(vm.dispose);
      await vm.start();
      final ticket = vm.beginSignIn()!;
      vm.cancelSignIn(ticket);
      await settleEvents();
      expect(vm.completeSignIn(ticket, staff), false);
      expect(vm.state.canAccessPrivate, false);
      expect(vm.state.retainPrivate, false);
    },
  );
}
