import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/app/app_router.dart';
import 'package:abrigo_dos_anjos/domain/models/session_access.dart';
import 'package:abrigo_dos_anjos/domain/models/team_access.dart';
import 'package:abrigo_dos_anjos/ui/features/auth/view_models/session_view_model.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import '../support/public_app_harness.dart';
import '../support/fakes/fake_auth_repository.dart';
import '../support/fakes/fake_team_repository.dart';

void main() {
  Future<void> open(
    WidgetTester tester,
    String path, {
    Object? args,
    StaffRole? role,
    bool configureAuth = false,
    FakeTeamRepository? team,
  }) async {
    final data = PublicAppHarness();
    final auth = FakeAuthRepository()
      ..handler = (method, _) async => method == 'canResetPassword'
          ? const Success(false)
          : Success(
              SessionAccess(
                level: AccessLevel.authorized,
                userId: 'admin',
                role: role,
              ),
            );
    addTearDown(auth.dispose);
    final session = SessionViewModel(auth);
    addTearDown(session.dispose);
    if (configureAuth) await session.start();
    final router = AppRouter(
      animals: data.animals,
      favorites: data.favorites,
      photos: data.photos,
      adoption: data.adoption,
      auth: configureAuth ? auth : null,
      session: configureAuth ? session : null,
      team: team,
    );
    await tester.pumpWidget(
      MaterialApp(
        onGenerateRoute: router.onGenerateRoute,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () =>
                  Navigator.pushNamed(context, path, arguments: args),
              child: const Text('Open route'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open route'));
    await tester.pumpAndSettle();
  }

  for (final path in [
    '/team',
    '/animal-management',
    '/medication-editor',
    '/recovery',
    '/reset-password',
  ]) {
    testWidgets('$path without auth configuration fails closed', (
      tester,
    ) async {
      await open(tester, path);
      expect(find.text('Serviço de acesso indisponível.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
  for (final path in ['/recovery', '/reset-password']) {
    testWidgets(
      'public auth route $path opens approved screen without private content',
      (tester) async {
        await open(tester, path, configureAuth: true);
        expect(
          find.text(
            path == '/recovery' ? 'Recuperar acesso' : 'Definir nova senha',
          ),
          findsOneWidget,
        );
        expect(find.text('Kanban'), findsNothing);
        if (path == '/reset-password') {
          expect(find.text('Solicitar novo link'), findsOneWidget);
          expect(find.byType(TextField), findsNothing);
        }
        expect(tester.takeException(), isNull);
      },
    );
  }
  for (final path in ['/team', '/team-invite']) {
    testWidgets('employee direct $path cannot query team data', (tester) async {
      final team = FakeTeamRepository();
      await open(
        tester,
        path,
        role: StaffRole.employee,
        configureAuth: true,
        team: team,
      );
      expect(
        find.text('Somente administradores podem gerenciar a equipe.'),
        findsOneWidget,
      );
      expect(team.calls, isEmpty);
    });
    testWidgets(
      'verified administrator opens $path through actual composition',
      (tester) async {
        final team = FakeTeamRepository()
          ..handler = (_, _) async => const Success(TeamPage());
        await open(
          tester,
          path,
          role: StaffRole.administrator,
          configureAuth: true,
          team: team,
        );
        expect(
          find.text(path == '/team' ? 'Convidar pessoa' : 'Enviar convite'),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
  for (final entry in {
    '/medication-editor': 'Programação indisponível para este animal.',
    '/medication-application': 'Aplicação indisponível.',
    '/team': 'Equipe indisponível.',
  }.entries) {
    testWidgets(
      'authorized ${entry.key} with missing service does not open an editor',
      (tester) async {
        await open(
          tester,
          entry.key,
          role: StaffRole.administrator,
          configureAuth: true,
          args: {'animalId': 'invalid'},
        );
        expect(find.text(entry.value), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
  for (final entry in {
    '/accept-invitation': 'Convite indisponível.',
    '/adoption-contact': 'Serviço de contato não configurado.',
    '/unrecognized': 'Página não encontrada.',
  }.entries) {
    testWidgets('${entry.key} reports unavailable route explicitly', (
      tester,
    ) async {
      await open(tester, entry.key);
      expect(find.text(entry.value), findsOneWidget);
    });
  }
}
