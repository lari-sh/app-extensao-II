import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/ui/features/auth/views/login_screen.dart';
import 'package:abrigo_dos_anjos/ui/features/auth/views/recovery_screen.dart';
import 'package:abrigo_dos_anjos/ui/features/auth/views/reset_password_screen.dart';
import 'package:abrigo_dos_anjos/ui/features/auth/view_models/login_view_model.dart';
import 'package:abrigo_dos_anjos/ui/features/auth/view_models/recovery_view_model.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import 'package:abrigo_dos_anjos/utils/app_failure.dart';
import '../../../../support/fakes/fake_auth_repository.dart';

Future<void> reveal(WidgetTester tester, Finder target, double delta) async {
  await tester.scrollUntilVisible(
    target,
    delta,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'keyboard login failure is sanitized and recovery retries then returns to login',
    (tester) async {
      final repo = FakeAuthRepository()
        ..handler = (_, _) async =>
            throw StateError('private implementation details');
      addTearDown(repo.dispose);
      var failedTicket = 0;
      final vm = LoginViewModel(
        repo,
        beginAttempt: () => 7,
        onFailure: (ticket) => failedTicket = ticket,
      );
      addTearDown(vm.dispose);
      final recovery = RecoveryViewModel(repo);
      addTearDown(recovery.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(viewModel: vm),
          routes: {'/recovery': (_) => RecoveryScreen(viewModel: recovery)},
        ),
      );
      final email = find.byKey(const ValueKey('loginEmail')),
          password = find.byKey(const ValueKey('loginPassword'));
      await reveal(tester, email, 150);
      await tester.enterText(email, 'staff@example.test');
      await reveal(tester, password, 150);
      await tester.enterText(password, 'test-only-password');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(failedTicket, 7);
      expect(vm.state.busy, isFalse);
      expect(vm.state.signedIn, isFalse);
      expect(vm.state.message, isNot(contains('private')));
      await reveal(tester, find.text(vm.state.message!), 150);
      expect(find.text(vm.state.message!), findsOneWidget);
      await reveal(tester, find.text('Esqueci a senha'), -150);
      await tester.tap(find.text('Esqueci a senha'));
      await tester.pumpAndSettle();
      repo.handler = (_, _) async =>
          Failure<Unit>(AppFailure(FailureCode.network));
      await reveal(tester, find.byType(TextField), 150);
      await tester.enterText(find.byType(TextField), 'staff@example.test');
      await tester.tap(find.text('Enviar orientações'));
      await tester.pumpAndSettle();
      await reveal(tester, find.textContaining('Não foi possível enviar'), 150);
      expect(recovery.state.completed, isFalse);
      repo.handler = (_, _) async => const Success(Unit.value);
      await tester.tap(find.text('Enviar orientações'));
      await tester.pumpAndSettle();
      expect(recovery.state.completed, isTrue);
      await tester.tap(find.text('Voltar ao login'));
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'expired password link replaces screen with recovery request route',
    (tester) async {
      final repo = FakeAuthRepository()
        ..handler = (_, _) async => const Success(false);
      addTearDown(repo.dispose);
      final vm = ResetPasswordViewModel(repo);
      addTearDown(vm.dispose);
      await vm.load();
      await tester.pumpWidget(
        MaterialApp(
          home: ResetPasswordScreen(viewModel: vm),
          routes: {
            '/recovery': (_) =>
                const Scaffold(body: Text('Formulário de recuperação')),
          },
        ),
      );
      await tester.tap(find.text('Solicitar novo link'));
      await tester.pumpAndSettle();
      expect(find.byType(ResetPasswordScreen), findsNothing);
      expect(find.text('Formulário de recuperação'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
