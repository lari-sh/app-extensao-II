import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/domain/models/team_access.dart';
import 'package:abrigo_dos_anjos/domain/models/session_access.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import 'package:abrigo_dos_anjos/utils/app_failure.dart';
import 'package:abrigo_dos_anjos/ui/features/team/view_models/team_view_model.dart';
import 'package:abrigo_dos_anjos/ui/features/team/view_models/accept_invitation_view_model.dart';
import '../../../../support/fakes/fake_team_repository.dart';
import '../../../../support/fakes/fake_auth_repository.dart';
import '../../../../support/team_fixtures.dart' show invitation;

void main() {
  test(
    'invitation changes profile, reports known failure and starts a fresh submission',
    () async {
      final repo = FakeTeamRepository()
        ..handler = (_, _) async =>
            Failure<TeamReceipt>(AppFailure(FailureCode.conflict));
      final vm = InviteMemberViewModel(
        repo,
        canManage: () => true,
        authorize: () async => true,
        contextKey: () => 'a',
      );
      addTearDown(vm.dispose);
      vm.selectRole(StaffRole.administrator);
      await vm.submit('Pessoa', 'p@example.test');
      expect(repo.calls.single.arguments[2], StaffRole.administrator);
      final key = repo.calls.single.arguments.last;
      expect(vm.state.uncertain, isFalse);
      expect(vm.state.message, isNotEmpty);
      await vm.reconcile();
      expect(repo.calls.length, 1);
      repo.handler = (_, _) async =>
          const Success(TeamReceipt(state: 'failed', code: 'send_failed'));
      await vm.submit('Pessoa', 'p@example.test');
      expect(repo.calls.last.arguments.last, isNot(key));
      expect(vm.state.sent, isFalse);
      expect(vm.canEdit, isTrue);
    },
  );
  test(
    'invitation timeout locks editing and preserves key through pending then confirmed receipt',
    () async {
      final repo = FakeTeamRepository()
        ..handler = (_, _) async =>
            Failure<TeamReceipt>(AppFailure(FailureCode.timeout));
      final vm = InviteMemberViewModel(
        repo,
        canManage: () => true,
        authorize: () async => true,
        contextKey: () => 'a',
      );
      addTearDown(vm.dispose);
      await vm.submit('Pessoa', 'p@example.test');
      final key = repo.calls.single.arguments.last;
      expect(vm.canEdit, isFalse);
      repo.handler = (_, _) async =>
          const Success(TeamReceipt(state: 'pending'));
      await vm.reconcile();
      expect(vm.state.uncertain, isTrue);
      repo.handler = (_, _) async => const Success(
        TeamReceipt(state: 'confirmed', code: 'delivery_uncertain'),
      );
      await vm.reconcile();
      expect(repo.calls.last.arguments, [key]);
      expect(vm.state.sent, isTrue);
      expect(vm.state.message, contains('entrega'));
    },
  );
  test('invitation result from old identity is discarded', () async {
    var identity = 'a';
    final pending = Completer<Result<TeamReceipt>>();
    final repo = FakeTeamRepository()..handler = (_, _) => pending.future;
    final vm = InviteMemberViewModel(
      repo,
      canManage: () => true,
      authorize: () async => true,
      contextKey: () => identity,
    );
    addTearDown(vm.dispose);
    final action = vm.submit('Pessoa', 'p@example.test');
    await Future<void>.delayed(Duration.zero);
    identity = 'b';
    pending.complete(const Success(TeamReceipt(state: 'confirmed')));
    await action;
    expect(vm.state.sent, isFalse);
    expect(vm.state.busy, isFalse);
  });
  group('acceptance failures and recovery', () {
    late FakeTeamRepository repo;
    late FakeAuthRepository auth;
    late AcceptInvitationViewModel vm;
    setUp(() {
      repo = FakeTeamRepository();
      auth = FakeAuthRepository()
        ..handler = (_, _) async => const Success(Unit.value);
      repo.handler = (method, args) async => switch (method) {
        'ownInvitation' => Success(invitation()),
        'definePassword' => const Success(Unit.value),
        _ => const Success(TeamReceipt(state: 'confirmed')),
      };
      vm = AcceptInvitationViewModel(repo, auth);
    });
    tearDown(() async {
      vm.dispose();
      await auth.dispose();
    });
    test(
      'unavailable identity or load failure never enables password submission',
      () async {
        repo.handler = (_, _) async => const Success<TeamInvitation?>(null);
        await vm.load();
        expect(vm.canSubmit, isFalse);
        repo.handler = (_, _) async =>
            Failure<TeamInvitation?>(AppFailure(FailureCode.forbidden));
        await vm.load();
        expect(vm.state.message, isNotEmpty);
        expect(vm.state.loading, isFalse);
      },
    );
    test(
      'failed password write without server proof cannot activate membership',
      () async {
        await vm.load();
        repo.handler = (method, args) async => method == 'definePassword'
            ? Failure<Unit>(AppFailure(FailureCode.timeout))
            : Success(invitation().copyWith(passwordReady: false));
        await vm.submit('long-password-123', 'long-password-123');
        expect(repo.calls.where((c) => c.method == 'accept'), isEmpty);
        expect(vm.state.passwordSaved, isFalse);
        expect(vm.state.busy, isFalse);
      },
    );
    test(
      'password proof of another invitation cannot activate this one',
      () async {
        await vm.load();
        repo.handler = (method, args) async => method == 'definePassword'
            ? Failure<Unit>(AppFailure(FailureCode.timeout))
            : Success(invitation().copyWith(id: 'other', passwordReady: true));
        await vm.submit('long-password-123', 'long-password-123');
        expect(repo.calls.where((c) => c.method == 'accept'), isEmpty);
        expect(vm.state.accepted, isFalse);
      },
    );
    test(
      'failed acceptance retries same receipt and never writes saved password twice',
      () async {
        await vm.load();
        repo.handler = (method, args) async => method == 'definePassword'
            ? const Success(Unit.value)
            : Failure<TeamReceipt>(AppFailure(FailureCode.timeout));
        await vm.submit('long-password-123', 'long-password-123');
        final key = repo.calls.last.arguments.last;
        expect(vm.state.passwordSaved, isTrue);
        expect(vm.state.accepted, isFalse);
        repo.handler = (_, _) async =>
            const Success(TeamReceipt(state: 'confirmed'));
        await vm.submit('', '');
        expect(repo.calls.where((c) => c.method == 'definePassword').length, 1);
        expect(repo.calls.last.arguments.last, key);
        expect(vm.state.accepted, isTrue);
      },
    );
    test(
      'pending acceptance and failed logout never report completed access',
      () async {
        await vm.load();
        repo.handler = (method, args) async => method == 'definePassword'
            ? const Success(Unit.value)
            : const Success(TeamReceipt(state: 'pending'));
        await vm.submit('long-password-123', 'long-password-123');
        expect(vm.state.accepted, isFalse);
        expect(auth.calls, isEmpty);
        repo.handler = (_, _) async =>
            const Success(TeamReceipt(state: 'confirmed'));
        auth.handler = (_, _) async =>
            Failure<Unit>(AppFailure(FailureCode.network));
        await vm.submit('', '');
        expect(vm.state.accepted, isFalse);
        expect(vm.state.message, isNotEmpty);
      },
    );
    test(
      'recipient with confirmed saved password skips password submission',
      () async {
        repo.handler = (method, args) async => method == 'ownInvitation'
            ? Success(invitation().copyWith(passwordReady: true))
            : const Success(TeamReceipt(state: 'confirmed'));
        await vm.load();
        await vm.submit('', '');
        expect(vm.state.accepted, isTrue);
        expect(repo.calls.where((c) => c.method == 'definePassword'), isEmpty);
      },
    );
  });
  test('disposed recipient ignores slow lookup and blocks new loads', () async {
    final pending = Completer<Result<TeamInvitation?>>();
    final repo = FakeTeamRepository()..handler = (_, _) => pending.future;
    final auth = FakeAuthRepository();
    addTearDown(auth.dispose);
    final vm = AcceptInvitationViewModel(repo, auth);
    final load = vm.load();
    vm.dispose();
    pending.complete(Success(invitation()));
    await load;
    await vm.load();
    expect(repo.calls.length, 1);
  });
}
