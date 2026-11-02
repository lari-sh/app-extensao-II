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
    'Android recovery email and PKCE callback change password, require normal login and reject replay',
    (tester) async {
      expect(
        Uri.parse(const String.fromEnvironment('SUPABASE_URL')).host,
        '10.0.2.2',
      );
      final control = Uri.parse('http://10.0.2.2:58765');
      final credentials =
          jsonDecode((await http.get(control.resolve('/credentials'))).body)
              as Map;
      final email = credentials['email'] as String,
          password = credentials['new_password'] as String;
      await tester.pumpWidget(await bootstrapApplication());
      await tester.pumpAndSettle();
      await Supabase.instance.client.auth.signOut(scope: SignOutScope.local);
      await tester.pumpAndSettle();
      Future<void> visible(String text) async {
        await tester.scrollUntilVisible(
          find.text(text),
          130,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
      }

      await visible('Acesso Voluntário / Funcionário');
      await tester.tap(find.text('Acesso Voluntário / Funcionário'));
      await tester.pumpAndSettle();
      await visible('Esqueci a senha');
      await tester.tap(find.text('Esqueci a senha'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byType(TextField),
        130,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.enterText(find.byType(TextField), email);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Enviar orientações'));
      await tester.pumpAndSettle();
      expect(find.text('Confira seu e-mail'), findsOneWidget);
      final opened = await http.post(control.resolve('/open-recovery'));
      expect(opened.statusCode, 200);
      for (
        var i = 0;
        i < 60 && find.text('Salvar nova senha').evaluate().isEmpty;
        i++
      ) {
        await tester.pump(const Duration(milliseconds: 200));
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
      await tester.pumpAndSettle();
      expect(find.text('Salvar nova senha'), findsOneWidget);
      expect(find.text('Kanban'), findsNothing);
      await tester.enterText(
        find.widgetWithText(TextField, 'Nova senha'),
        password,
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Confirmar nova senha'),
        password,
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Salvar nova senha'));
      await tester.pumpAndSettle();
      expect(find.text('Senha atualizada'), findsOneWidget);
      expect(Supabase.instance.client.auth.currentSession, isNull);
      await tester.tap(find.text('Ir para o login'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const ValueKey('loginEmail')), email);
      await tester.enterText(
        find.byKey(const ValueKey('loginPassword')),
        password,
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(find.text('Acesso autorizado'), findsOneWidget);
      final replayed = await http.post(control.resolve('/replay-recovery'));
      expect(replayed.statusCode, 200);
      for (
        var i = 0;
        i < 60 && find.text('Solicitar novo link').evaluate().isEmpty;
        i++
      ) {
        await tester.pump(const Duration(milliseconds: 200));
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
      await tester.pumpAndSettle();
      expect(find.text('Solicitar novo link'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
      expect(find.text('Kanban'), findsNothing);
      await Supabase.instance.client.auth.signOut(scope: SignOutScope.local);
      await tester.pumpAndSettle();
    },
  );
}
