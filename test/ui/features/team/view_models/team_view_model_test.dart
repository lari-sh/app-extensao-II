import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/domain/models/team_access.dart';
import 'package:abrigo_dos_anjos/domain/models/session_access.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import 'package:abrigo_dos_anjos/utils/app_failure.dart';
import 'package:abrigo_dos_anjos/ui/features/team/view_models/team_view_model.dart';
import '../../../../support/fakes/fake_team_repository.dart';
import '../../../../support/team_fixtures.dart' show member, invitation;

void main() {
  late FakeTeamRepository repo;
  late TeamViewModel vm;
  bool allowed = true;
  String context = 'admin:1';
  setUp(() {
    allowed = true;
    context = 'admin:1';
    repo = FakeTeamRepository();
    repo.handler = (method, args) async =>
        method == 'members' || method == 'invitations'
        ? const Success(TeamPage())
        : const Success(TeamReceipt(state: 'confirmed'));
    vm = TeamViewModel(
      repo,
      canManage: () => allowed,
      authorize: () async => allowed,
      contextKey: () => context,
      currentUserId: () => 'admin',
    );
  });
  tearDown(() => vm.dispose());
  test(
    'pagination appends records and selecting inactive reloads without old cursor',
    () async {
      repo.handler = (_, args) async => args[1] == null
          ? const Success(TeamPage(members: [member], nextCursor: 'next'))
          : Success(TeamPage(members: [member.copyWith(id: 'second')]));
      await vm.load();
      await vm.load(more: true);
      expect(vm.state.members.map((m) => m.id), ['other', 'second']);
      expect(repo.calls.last.arguments, [true, 'next']);
      await vm.select(TeamTab.inactive);
      expect(repo.calls.last.arguments, [false, null]);
      expect(vm.state.members.length, 1);
    },
  );
  test('invitations use their own endpoint and cursor', () async {
    repo.handler = (_, args) async => Success(
      TeamPage(
        invitations: [invitation()],
        nextCursor: args.first == null ? 'next' : null,
      ),
    );
    await vm.select(TeamTab.invitations);
    await vm.load(more: true);
    expect(repo.calls.map((c) => c.method), ['invitations', 'invitations']);
    expect(repo.calls.last.arguments, ['next']);
    expect(vm.state.invitations.length, 2);
  });
  test('loading error is friendly and loading flag clears', () async {
    repo.handler = (_, _) async =>
        Failure<TeamPage>(AppFailure(FailureCode.network));
    await vm.load();
    expect(vm.state.message, isNotEmpty);
    expect(vm.state.loading, isFalse);
  });
  test('revocation or changed context rejects a late list response', () async {
    final pending = Completer<Result<TeamPage>>();
    repo.handler = (_, _) => pending.future;
    final loading = vm.load();
    await Future<void>.delayed(Duration.zero);
    context = 'different:2';
    allowed = false;
    pending.complete(const Success(TeamPage(members: [member])));
    await loading;
    expect(vm.state.members, isEmpty);
    expect(vm.state.loading, isFalse);
  });
  test(
    'confirmed changes carry intended role and active flag, then refresh',
    () async {
      await vm.change(member, StaffRole.administrator, false);
      expect(repo.calls.first.method, 'change');
      expect(repo.calls.first.arguments.take(3), [
        member,
        StaffRole.administrator,
        false,
      ]);
      expect(repo.calls.last.method, 'members');
      expect(vm.state.busy, isFalse);
      expect(vm.state.message, 'Alteração confirmada.');
    },
  );
  test(
    'cancel and resend preserve versioned invitation and reject unavailable actions',
    () async {
      await vm.resend(invitation());
      expect(repo.calls.first.arguments.first, invitation());
      await vm.cancel(invitation());
      expect(repo.calls.any((c) => c.method == 'cancel'), isTrue);
      final count = repo.calls.length;
      await vm.resend(invitation().copyWith(retryAfter: 60));
      await vm.cancel(invitation().copyWith(status: 'accepted'));
      expect(repo.calls.length, count);
    },
  );
  test(
    'conflict clears busy, refreshes list and permits a new operation',
    () async {
      repo.handler = (method, args) async => method == 'members'
          ? const Success(TeamPage(members: [member]))
          : Failure<TeamReceipt>(AppFailure(FailureCode.conflict));
      await vm.change(member, StaffRole.employee, false);
      final first = repo.calls.first.arguments.last;
      expect(vm.state.uncertain, isFalse);
      expect(vm.state.message, isNotEmpty);
      expect(vm.state.members, [member]);
      await vm.change(member, StaffRole.employee, false);
      expect(
        repo.calls.where((c) => c.method == 'change').last.arguments.last,
        isNot(first),
      );
    },
  );
  for (final code in [
    FailureCode.network,
    FailureCode.timeout,
    FailureCode.unknown,
  ]) {
    test(
      '$code locks commands until receipt reconciliation with original key',
      () async {
        repo.handler = (method, args) async => method == 'cancel'
            ? Failure<TeamReceipt>(AppFailure(code))
            : const Success(TeamReceipt(state: 'confirmed'));
        await vm.cancel(invitation());
        final key = repo.calls.single.arguments.last;
        expect(vm.state.uncertain, isTrue);
        await vm.select(TeamTab.inactive);
        await vm.resend(invitation());
        expect(repo.calls.length, 1);
        repo.handler = (method, args) async => method == 'members'
            ? const Success(TeamPage())
            : const Success(TeamReceipt(state: 'confirmed'));
        await vm.reconcile();
        expect(repo.calls[1].arguments, [key]);
        expect(vm.state.uncertain, isFalse);
      },
    );
  }
  test(
    'pending receipt remains locked and duplicate command is ignored during busy',
    () async {
      final pending = Completer<Result<TeamReceipt>>();
      repo.handler = (_, _) => pending.future;
      final action = vm.cancel(invitation());
      await Future<void>.delayed(Duration.zero);
      await vm.cancel(invitation());
      await vm.select(TeamTab.inactive);
      expect(repo.calls.length, 1);
      pending.complete(const Success(TeamReceipt(state: 'pending')));
      await action;
      expect(vm.state.uncertain, isTrue);
      expect(vm.state.tab, TeamTab.active);
    },
  );
  test(
    'no command is sent when authorization is lost during verification',
    () async {
      allowed = false;
      await vm.reconcile();
      expect(repo.calls, isEmpty);
      expect(vm.state.busy, isFalse);
    },
  );
  test('disposed view model ignores outstanding command result', () async {
    final pending = Completer<Result<TeamReceipt>>();
    repo.handler = (_, _) => pending.future;
    final disposable = TeamViewModel(
      repo,
      canManage: () => true,
      authorize: () async => true,
      contextKey: () => 'admin',
      currentUserId: () => 'admin',
    );
    var notifications = 0;
    disposable.addListener(() => notifications++);
    final action = disposable.cancel(invitation());
    await Future<void>.delayed(Duration.zero);
    disposable.dispose();
    final before = notifications;
    pending.complete(const Success(TeamReceipt(state: 'confirmed')));
    await action;
    expect(notifications, before);
    expect(repo.calls.length, 1);
  });
  for (final code in [
    'delivery_uncertain',
    'send_failed',
    'existing_account',
    'invitation_unavailable',
  ]) {
    test('receipt $code exposes controlled Portuguese feedback', () {
      expect(
        receiptMessage(TeamReceipt(state: 'failed', code: code)),
        isNotEmpty,
      );
    });
  }
}
