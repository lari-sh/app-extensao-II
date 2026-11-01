import 'package:abrigo_dos_anjos/ui/features/auth/views/login_screen.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:integration_test/integration_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:abrigo_dos_anjos/app/bootstrap.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('real Android login, restore, nonstaff, revocation and logout', (
    tester,
  ) async {
    expect(
      Uri.parse(const String.fromEnvironment('SUPABASE_URL')).host,
      '10.0.2.2',
    );
    final control = Uri.parse('http://10.0.2.2:58763');
    final credentials = await http.get(control.resolve('/fixture-password'));
    expect(credentials.statusCode, 200);
    final password =
        (jsonDecode(credentials.body) as Map)['password'] as String;
    await tester.pumpWidget(await bootstrapApplication());
    await tester.pumpAndSettle();

    await Supabase.instance.client.auth.signOut(scope: SignOutScope.local);
    await tester.pumpAndSettle();

    Future<void> openLogin() async {
      final button = find.text('Acesso Voluntário / Funcionário').last;
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pumpAndSettle();
    }

    Future<void> login(String email, String secret) async {
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('loginEmail')),
        -160,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.enterText(find.byKey(const ValueKey('loginEmail')), email);
      await tester.enterText(
        find.byKey(const ValueKey('loginPassword')),
        secret,
      );
      // Submit through the actual keyboard action once. Android IME/viewport
      // transitions can otherwise navigate before a later tap on the old route.
      await tester.testTextInput.receiveAction(TextInputAction.done);
      for (var attempt = 0; attempt < 100; attempt++) {
        await tester.pumpAndSettle(const Duration(milliseconds: 100));
        if (find.text('Acesso autorizado').evaluate().isNotEmpty) return;
        final login = find.byType(LoginScreen);
        if (login.evaluate().length == 1) {
          final state = tester.widget<LoginScreen>(login).viewModel.state;
          if (!state.busy &&
              !state.signedIn &&
              (state.message != null || state.fieldErrors.isNotEmpty)) {
            return;
          }
        }
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
      fail('Login did not reach a confirmed success or failure state');
    }

    await openLogin();
    await login('fixture-staff@example.test', 'invalid-test-password');
    expect(find.text('Acesso autorizado'), findsNothing);
    await login('fixture-nonstaff@example.test', password);
    expect(find.text('Acesso autorizado'), findsNothing);
    expect(find.textContaining('não possui autorização'), findsWidgets);
    await login('fixture-staff@example.test', password);
    expect(find.text('Acesso autorizado'), findsOneWidget);

    // Dispose the SDK, then recover its session from native storage and revalidate remotely.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await Supabase.instance.dispose();
    await tester.pumpWidget(await bootstrapApplication());
    await tester.pumpAndSettle();
    await openLogin();
    expect(find.text('Acesso autorizado'), findsOneWidget);
    await tester.tap(find.text('Sair da conta'));
    await tester.pumpAndSettle();
    expect(
      Navigator.of(
        tester.element(find.text('Quero Adotar (Visitante)')),
      ).canPop(),
      isFalse,
    );
    expect(find.text('Acesso autorizado'), findsNothing);
    await openLogin();
    await login('fixture-revocable@example.test', password);
    expect(find.text('Acesso autorizado'), findsOneWidget);
    try {
      expect(
        (await http.post(control.resolve('/revoke-membership'))).statusCode,
        204,
      );
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle(const Duration(milliseconds: 300));
      expect(find.text('Acesso autorizado'), findsNothing);
      expect(find.textContaining('não possui autorização'), findsWidgets);
    } finally {
      await http.post(control.resolve('/restore-membership'));
      await Supabase.instance.client.auth.signOut();
      await tester.pumpAndSettle();
    }
  });
}
