import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:abrigo_dos_anjos/ui/features/auth/view_models/session_view_model.dart';
import 'package:abrigo_dos_anjos/domain/repositories/auth_repository.dart';
import '../support/auth_app_harness.dart';
import '../support/public_fixtures.dart';
import 'package:abrigo_dos_anjos/domain/models/animal.dart';
import 'package:abrigo_dos_anjos/domain/models/session_access.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';

void main() {
  testWidgets(
    'mounting private list and editor never notifies root Provider during build',
    (tester) async {
      final harness = AuthAppHarness()
        ..access = const SessionAccess(
          level: AccessLevel.authorized,
          userId: 'u',
        );
      addTearDown(harness.auth.dispose);
      harness.animals.handler = (method, args) async =>
          method == 'getStatusCounts'
          ? const Success<Map<AnimalStatus, int>>({AnimalStatus.available: 1})
          : method == 'listManagement'
          ? Success(
              ManagedAnimalPage(
                items: args.first == AnimalStatus.available
                    ? [ManagedAnimal(animal: fixtureAnimal(1))]
                    : [],
                total: 1,
              ),
            )
          : Success(ManagedAnimal(animal: fixtureAnimal(1)));
      await tester.pumpWidget(harness.app());
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Acesso Voluntário / Funcionário'));
      await tester.tap(find.text('Acesso Voluntário / Funcionário'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Animais do abrigo'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Luna 1'), findsOneWidget);
      await tester.tap(find.text('Luna 1'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Editar animal'), findsOneWidget);
      await harness.session.signOut();
      await tester.pumpAndSettle();
      expect(find.text('Quero Adotar (Visitante)'), findsOneWidget);
      expect(find.text('Editar animal'), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    },
  );
  testWidgets(
    'Provider owns one session across routes and logout removes private stack',
    (tester) async {
      final harness = AuthAppHarness();
      addTearDown(harness.auth.dispose);
      await tester.pumpWidget(harness.app());
      await tester.pumpAndSettle();
      final context = tester.element(find.text('Quero Adotar (Visitante)'));
      expect(context.read<AuthRepository>(), same(harness.auth));
      expect(context.read<SessionViewModel>(), same(harness.session));
      await tester.ensureVisible(find.text('Acesso Voluntário / Funcionário'));
      await tester.tap(find.text('Acesso Voluntário / Funcionário'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('loginEmail')),
        'staff@example.test',
      );
      await tester.enterText(
        find.byKey(const ValueKey('loginPassword')),
        'secret',
      );
      await tester.tap(find.text('Entrar no painel'));
      await tester.pumpAndSettle();
      expect(find.text('Acesso autorizado'), findsOneWidget);
      await tester.tap(find.text('Sair da conta'));
      await tester.pumpAndSettle();
      expect(find.text('Quero Adotar (Visitante)'), findsOneWidget);
      expect(find.text('Acesso autorizado'), findsNothing);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Acesso autorizado'), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    },
  );
}
