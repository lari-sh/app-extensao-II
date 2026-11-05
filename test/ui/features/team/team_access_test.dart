import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/data/repositories/team_repository_impl.dart';
import 'package:abrigo_dos_anjos/domain/models/team_access.dart';
import 'package:abrigo_dos_anjos/domain/models/session_access.dart';
import 'package:abrigo_dos_anjos/ui/features/team/view_models/team_view_model.dart';
import 'package:abrigo_dos_anjos/ui/features/team/view_models/accept_invitation_view_model.dart';
import 'package:abrigo_dos_anjos/ui/features/team/views/team_screen.dart';
import 'package:abrigo_dos_anjos/ui/features/team/views/invite_member_screen.dart';
import 'package:abrigo_dos_anjos/ui/features/team/views/accept_invitation_screen.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import 'package:abrigo_dos_anjos/utils/app_failure.dart';
import '../../../support/team_fixtures.dart';
import '../../../support/fakes/fake_auth_repository.dart';

class DelayedTeamService extends TeamFakeService {
  final pending = Completer<Result<Map<String, Object?>>>();
  int sends = 0;
  @override
  Future<Result<Map<String, Object?>>> send(Map<String, Object?> body) {
    sends++;
    return pending.future;
  }
}

class PasswordResponseLostService extends TeamFakeService {
  int passwordWrites = 0;
  @override
  Future<Result<Unit>> definePassword(String password) async {
    passwordWrites++;
    response = {...invitationJson(), 'password_ready': true};
    return Failure(AppFailure(FailureCode.timeout));
  }

  @override
  Future<Result<Map<String, Object?>?>> request(
    String name,
    Map<String, Object?> values,
  ) async {
    if (name == 'accept_team_invitation') {
      return const Success({'state': 'confirmed'});
    }
    return super.request(name, values);
  }
}

void main() {
  late TeamFakeService service;
  late TeamRepositoryImpl repository;
  bool allowed = true;
  setUp(() {
    service = TeamFakeService();
    repository = TeamRepositoryImpl(service);
    allowed = true;
  });
  InviteMemberViewModel invite() => InviteMemberViewModel(
    repository,
    canManage: () => allowed,
    authorize: () async => allowed,
    contextKey: () => 'admin:1',
  );
  TeamViewModel team() => TeamViewModel(
    repository,
    canManage: () => allowed,
    authorize: () async => allowed,
    contextKey: () => 'admin:1',
    currentUserId: () => 'self',
  );
  test('invitation validates identity and defaults to employee', () async {
    final vm = invite();
    addTearDown(vm.dispose);
    expect(vm.state.role, StaffRole.employee);
    await vm.submit('', 'invalid');
    expect(vm.state.errors.length, 2);
    expect(service.parameters, isEmpty);
    allowed = false;
    await vm.submit('Nome', 'p@example.test');
    expect(service.parameters, isEmpty);
  });
  test(
    'busy blocks duplicate email and disposal ignores late result',
    () async {
      final delayed = DelayedTeamService();
      final repo = TeamRepositoryImpl(delayed);
      final vm = InviteMemberViewModel(
        repo,
        canManage: () => true,
        authorize: () async => true,
        contextKey: () => 'a',
      );
      final first = vm.submit('Nome', 'p@example.test');
      await Future<void>.delayed(Duration.zero);
      await vm.submit('Nome', 'p@example.test');
      expect(delayed.sends, 1);
      vm.dispose();
      delayed.pending.complete(const Success({'state': 'confirmed'}));
      await first;
    },
  );
  test(
    'uncertain send locks form and reconciliation reuses operation key',
    () async {
      final vm = invite();
      addTearDown(vm.dispose);
      service.response = {'state': 'pending'};
      await vm.submit('Nome', 'p@example.test');
      final key = service.parameters['operation_key'];
      expect(vm.canEdit, isFalse);
      vm.selectRole(StaffRole.administrator);
      expect(vm.state.role, StaffRole.employee);
      service.response = {'state': 'confirmed'};
      await vm.reconcile();
      expect(service.parameters['operation_key'], key);
      expect(vm.state.sent, isTrue);
    },
  );
  test(
    'own member cannot be edited; revoked permission prevents commands',
    () async {
      final vm = team();
      addTearDown(vm.dispose);
      const member = TeamMember(
        id: 'self',
        name: 'Admin',
        email: 'a@example.test',
        role: StaffRole.administrator,
        active: true,
        version: 1,
      );
      expect(vm.canEdit(member), isFalse);
      await vm.change(member, StaffRole.employee, false);
      expect(service.parameters, isEmpty);
      allowed = false;
      await vm.load();
      expect(service.parameters, isEmpty);
    },
  );
  test(
    'password validation prevents acceptance and password never enters receipt payload',
    () async {
      final auth = FakeAuthRepository();
      addTearDown(auth.dispose);
      final vm = AcceptInvitationViewModel(repository, auth);
      addTearDown(vm.dispose);
      service.response = invitationJson();
      await vm.load();
      await vm.submit('weak', 'different');
      expect(vm.state.errors.length, 2);
      expect(service.method, 'get_my_invitation');
    },
  );
  for (final width in [320.0, 390.0]) {
    testWidgets('team happy path and invite at ${width}px', (tester) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      service.response = {
        'items': [memberJson()],
      };
      final listing = team();
      addTearDown(listing.dispose);
      await listing.load();
      await tester.pumpWidget(
        MaterialApp(home: TeamScreen(viewModel: listing)),
      );
      await tester.pumpAndSettle();
      expect(find.text('Pessoa'), findsOneWidget);
      expect(tester.takeException(), isNull);
      final vm = invite();
      addTearDown(vm.dispose);
      await tester.pumpWidget(
        MaterialApp(home: InviteMemberScreen(viewModel: vm)),
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, 'Nome completo'),
        'Pessoa',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'E-mail'),
        'p@example.test',
      );
      service.response = {'state': 'confirmed'};
      tester.testTextInput.hide();
      await tester.pump();
      await tester.scrollUntilVisible(
        find.text('Enviar convite'),
        150,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Enviar convite'));
      await tester.pumpAndSettle();
      expect(vm.state.sent, isTrue);
      await tester.scrollUntilVisible(
        find.text('Voltar para equipe'),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Voltar para equipe'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets(
    'acceptance happy path after password definition returns to login',
    (tester) async {
      final auth = FakeAuthRepository()
        ..handler = (_, _) async => const Success(Unit.value);
      addTearDown(auth.dispose);
      final vm = AcceptInvitationViewModel(repository, auth);
      addTearDown(vm.dispose);
      service.response = invitationJson();
      await vm.load();
      await tester.pumpWidget(
        MaterialApp(home: AcceptInvitationScreen(viewModel: vm)),
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, 'Nova senha'),
        'long-password-123',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Confirmar nova senha'),
        'long-password-123',
      );
      service.response = {'state': 'confirmed'};
      tester.testTextInput.hide();
      await tester.pump();
      await tester.scrollUntilVisible(
        find.text('Definir senha e aceitar'),
        150,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Definir senha e aceitar'));
      await tester.pumpAndSettle();
      expect(find.text('Ir para o login'), findsOneWidget);
      expect(service.parameters.keys, contains('p_expected_generation'));
    },
  );
  testWidgets('expired invitation has no password fields', (tester) async {
    final auth = FakeAuthRepository();
    addTearDown(auth.dispose);
    final vm = AcceptInvitationViewModel(repository, auth);
    addTearDown(vm.dispose);
    service.response = {...invitationJson(), 'status': 'expired'};
    await vm.load();
    await tester.pumpWidget(
      MaterialApp(home: AcceptInvitationScreen(viewModel: vm)),
    );
    expect(find.byType(TextField), findsNothing);
    expect(find.textContaining('expirou'), findsOneWidget);
  });
  test(
    'lost password response is reconciled against server proof without a repeated write',
    () async {
      final service = PasswordResponseLostService()
        ..response = invitationJson();
      final auth = FakeAuthRepository()
        ..handler = (_, _) async => const Success(Unit.value);
      addTearDown(auth.dispose);
      final vm = AcceptInvitationViewModel(TeamRepositoryImpl(service), auth);
      addTearDown(vm.dispose);
      await vm.load();
      await vm.submit('long-password-123', 'long-password-123');
      expect(service.passwordWrites, 1);
      expect(vm.state.accepted, isTrue);
    },
  );
  testWidgets('approved team screens support 320px and enlarged text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    Widget app(Widget home) => MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(1.8)),
        child: child!,
      ),
      home: home,
    );
    final listing = team();
    addTearDown(listing.dispose);
    service.response = {
      'items': [memberJson()],
    };
    await listing.load();
    await tester.pumpWidget(app(TeamScreen(viewModel: listing)));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    final form = invite();
    addTearDown(form.dispose);
    await tester.pumpWidget(app(InviteMemberScreen(viewModel: form)));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    final auth = FakeAuthRepository();
    addTearDown(auth.dispose);
    final accepting = AcceptInvitationViewModel(repository, auth);
    addTearDown(accepting.dispose);
    service.response = invitationJson();
    await accepting.load();
    await tester.pumpWidget(app(AcceptInvitationScreen(viewModel: accepting)));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
