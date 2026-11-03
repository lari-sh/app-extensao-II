import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:integration_test/integration_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:abrigo_dos_anjos/app/bootstrap.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'Android administrator invites employee, real email opens accept, password activates only employee access',
    (tester) async {
      expect(
        Uri.parse(const String.fromEnvironment('SUPABASE_URL')).host,
        anyOf('10.0.2.2', '127.0.0.1'),
      );
      final fixtureHost = Uri.parse(
        const String.fromEnvironment('SUPABASE_URL'),
      ).host;
      final control = Uri.parse('http://$fixtureHost:58764');
      final credentials =
          jsonDecode((await http.get(control.resolve('/credentials'))).body)
              as Map;
      final email = credentials['email'] as String,
          password = credentials['password'] as String,
          recipient = credentials['recipient'] as String;
      await tester.pumpWidget(await bootstrapApplication());
      await tester.pumpAndSettle();
      await Supabase.instance.client.auth.signOut(scope: SignOutScope.local);
      await tester.pumpAndSettle();
      Future<void> visible(String text) async {
        final target = find.text(text);
        for (var i = 0; i < 100 && target.evaluate().isEmpty; i++) {
          await tester.pump(const Duration(milliseconds: 100));
          await Future<void>.delayed(const Duration(milliseconds: 100));
        }
        expect(
          target,
          findsOneWidget,
          reason: 'Expected confirmed screen action: $text',
        );
        await tester.ensureVisible(target);
        await tester.pumpAndSettle();
      }

      await visible('Acesso Voluntário / Funcionário');
      await tester.tap(find.text('Acesso Voluntário / Funcionário'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const ValueKey('loginEmail')), email);
      await tester.enterText(
        find.byKey(const ValueKey('loginPassword')),
        password,
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Animais do abrigo'));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Administração'), findsOneWidget);
      await tester.tap(find.byTooltip('Administração'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Equipe e acessos'));
      await tester.pumpAndSettle();
      // Wait for the actual team response, not only for the route animation.
      for (
        var i = 0;
        i < 100 && find.text('Admin Android').evaluate().isEmpty;
        i++
      ) {
        await tester.pump(const Duration(milliseconds: 100));
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
      expect(find.text('Admin Android'), findsOneWidget);
      await tester.tap(find.text('Convidar pessoa'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, 'Nome completo'),
        'Pessoa Android',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'E-mail'),
        recipient,
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await visible('Enviar convite');
      await tester.tap(find.text('Enviar convite'));
      await tester.pumpAndSettle();
      await visible('Voltar para equipe');
      expect(find.text('Voltar para equipe'), findsOneWidget);
      // Controller only reads local Mailpit and dispatches the genuine Android VIEW
      // intent. No Auth credential or full callback is returned to this test.
      final opened = await http.post(control.resolve('/open-invitation'));
      expect(opened.statusCode, 200);
      for (
        var i = 0;
        i < 50 && find.text('Você foi convidado!').evaluate().isEmpty;
        i++
      ) {
        await tester.pump(const Duration(milliseconds: 200));
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
      await tester.pumpAndSettle();
      expect(find.text('Você foi convidado!'), findsOneWidget);
      expect(find.text(recipient), findsOneWidget);
      await tester.enterText(
        find.widgetWithText(TextField, 'Nova senha'),
        password,
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Confirmar nova senha'),
        password,
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await visible('Definir senha e aceitar');
      await tester.tap(find.text('Definir senha e aceitar'));
      await tester.pumpAndSettle();
      await visible('Ir para o login');
      await tester.tap(find.text('Ir para o login'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('loginEmail')),
        recipient,
      );
      await tester.enterText(
        find.byKey(const ValueKey('loginPassword')),
        password,
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(find.text('Acesso autorizado'), findsOneWidget);
      await tester.tap(find.text('Animais do abrigo'));
      await tester.pumpAndSettle();
      expect(find.text('Kanban'), findsOneWidget);
      await tester.tap(find.byTooltip('Administração'));
      await tester.pumpAndSettle();
      expect(find.text('Equipe e acessos'), findsNothing);
      Navigator.of(tester.element(find.text('Sair da conta'))).pop();
      await tester.pumpAndSettle();
      Navigator.of(
        tester.element(find.byType(Scaffold).last),
      ).pushNamed('/team');
      await tester.pumpAndSettle();
      expect(
        find.text('Somente administradores podem gerenciar a equipe.'),
        findsOneWidget,
      );
      expect(find.text('Convidar pessoa'), findsNothing);
      await Supabase.instance.client.auth.signOut(scope: SignOutScope.local);
      await tester.pumpAndSettle();
    },
  );
}
