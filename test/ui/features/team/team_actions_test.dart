import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/domain/models/team_access.dart';
import 'package:abrigo_dos_anjos/domain/models/session_access.dart';
import 'package:abrigo_dos_anjos/ui/features/team/view_models/team_view_model.dart';
import 'package:abrigo_dos_anjos/ui/features/team/views/team_screen.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import '../../../support/fakes/fake_team_repository.dart';
import '../../../support/team_fixtures.dart' show invitation, member;
import '../../../support/team_navigation.dart';

void main() {
  late FakeTeamRepository repo;
  late TeamViewModel vm;
  setUp(() {
    repo = FakeTeamRepository()
      ..handler = (method, args) async => method == 'members'
          ? const Success(TeamPage(members: [member]))
          : method == 'invitations'
          ? Success(TeamPage(invitations: [invitation()]))
          : const Success(TeamReceipt(state: 'confirmed'));
    vm = TeamViewModel(
      repo,
      canManage: () => true,
      authorize: () async => true,
      contextKey: () => 'admin',
      currentUserId: () => 'admin',
    );
  });
  tearDown(() => vm.dispose());
  Future<void> open(WidgetTester tester) async {
    await vm.load();
    await tester.pumpWidget(MaterialApp(home: TeamScreen(viewModel: vm)));
    await tester.pumpAndSettle();
  }

  testWidgets('team journey finds a member below the initial viewport', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    repo.handler = (_, _) async => Success(
      TeamPage(
        members: [
          for (var i = 0; i < 12; i++)
            member.copyWith(id: 'person-$i', name: 'Pessoa $i'),
          member.copyWith(id: 'admin', name: 'Admin Android'),
        ],
      ),
    );
    await open(tester);
    expect(find.text('Admin Android'), findsNothing);
    await revealTeamMember(tester, 'Admin Android');
    expect(find.text('Convidar pessoa').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final action in ['Alterar perfil', 'Desativar acesso']) {
    testWidgets(
      '$action requires confirmation and sends intended access change',
      (tester) async {
        await open(tester);
        await tester.tap(find.byTooltip('Gerenciar Pessoa'));
        await tester.pumpAndSettle();
        await tester.tap(find.text(action));
        await tester.pumpAndSettle();
        expect(repo.calls.where((c) => c.method == 'change'), isEmpty);
        await tester.tap(find.text('Confirmar'));
        await tester.pumpAndSettle();
        final command = repo.calls.firstWhere((c) => c.method == 'change');
        expect(
          command.arguments[1],
          action == 'Alterar perfil'
              ? StaffRole.administrator
              : StaffRole.employee,
        );
        expect(command.arguments[2], action == 'Alterar perfil');
        expect(find.text('Alteração confirmada.'), findsOneWidget);
      },
    );
  }
  testWidgets('dismissed access confirmation does not change member', (
    tester,
  ) async {
    await open(tester);
    await tester.tap(find.byTooltip('Gerenciar Pessoa'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Desativar acesso'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Voltar'));
    await tester.pumpAndSettle();
    expect(repo.calls.where((c) => c.method == 'change'), isEmpty);
  });
  testWidgets(
    'pending invitation exposes resend and cancellable confirmation',
    (tester) async {
      await vm.select(TeamTab.invitations);
      await tester.pumpWidget(MaterialApp(home: TeamScreen(viewModel: vm)));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reenviar convite'));
      await tester.pumpAndSettle();
      expect(repo.calls.where((c) => c.method == 'resend').length, 1);
      await tester.tap(find.text('Cancelar convite'));
      await tester.pumpAndSettle();
      expect(repo.calls.where((c) => c.method == 'cancel'), isEmpty);
      await tester.tap(find.text('Confirmar'));
      await tester.pumpAndSettle();
      expect(repo.calls.where((c) => c.method == 'cancel').length, 1);
    },
  );
  testWidgets(
    'uncertain send exposes reconciliation instead of a duplicate command',
    (tester) async {
      repo.handler = (method, args) async => method == 'members'
          ? const Success(TeamPage(members: [member]))
          : const Success(TeamReceipt(state: 'pending'));
      await vm.cancel(invitation());
      await tester.pumpWidget(MaterialApp(home: TeamScreen(viewModel: vm)));
      await tester.pumpAndSettle();
      expect(find.text('Consultar resultado'), findsOneWidget);
      repo.handler = (method, args) async => method == 'members'
          ? const Success(TeamPage(members: [member]))
          : const Success(TeamReceipt(state: 'confirmed'));
      await tester.tap(find.text('Consultar resultado'));
      await tester.pumpAndSettle();
      expect(repo.calls.where((c) => c.method == 'reconcile').length, 1);
      expect(find.text('Consultar resultado'), findsNothing);
    },
  );
  testWidgets('invite route returns to a refreshed team list', (tester) async {
    await vm.load();
    await tester.pumpWidget(
      MaterialApp(
        home: TeamScreen(viewModel: vm),
        routes: {
          '/team-invite': (_) => Scaffold(
            body: TextButton(
              onPressed: () {},
              child: const Text('Invite route'),
            ),
          ),
        },
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Convidar pessoa'));
    await tester.pumpAndSettle();
    expect(find.text('Invite route'), findsOneWidget);
    Navigator.of(tester.element(find.text('Invite route'))).pop();
    await tester.pumpAndSettle();
    expect(repo.calls.where((c) => c.method == 'members').length, 2);
  });
  testWidgets(
    'inactive member offers restoration and pagination can be requested',
    (tester) async {
      repo.handler = (method, args) async => method == 'members'
          ? Success(
              TeamPage(
                members: [member.copyWith(active: false)],
                nextCursor: args[1] == null ? 'next' : null,
              ),
            )
          : const Success(TeamReceipt(state: 'confirmed'));
      await vm.select(TeamTab.inactive);
      await tester.pumpWidget(MaterialApp(home: TeamScreen(viewModel: vm)));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Gerenciar Pessoa'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Restaurar acesso'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirmar'));
      await tester.pumpAndSettle();
      expect(
        repo.calls.firstWhere((c) => c.method == 'change').arguments[2],
        isTrue,
      );
      await tester.tap(find.text('Carregar mais'));
      await tester.pumpAndSettle();
      expect(repo.calls.last.arguments, [false, 'next']);
    },
  );
}
