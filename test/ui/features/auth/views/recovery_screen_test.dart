import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/ui/features/auth/view_models/recovery_view_model.dart';
import 'package:abrigo_dos_anjos/ui/features/auth/views/recovery_screen.dart';
import 'package:abrigo_dos_anjos/ui/features/auth/views/reset_password_screen.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import '../../../../support/fakes/fake_auth_repository.dart';

void main() {
  testWidgets(
    'approved recovery form sends and shows neutral confirmation at 320px',
    (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repo = FakeAuthRepository()
        ..handler = (m, a) async => const Success(Unit.value);
      addTearDown(repo.dispose);
      final vm = RecoveryViewModel(repo);
      addTearDown(vm.dispose);
      await tester.pumpWidget(MaterialApp(home: RecoveryScreen(viewModel: vm)));
      await tester.scrollUntilVisible(find.byType(TextField), 120);
      expect(
        tester.widget<TextField>(find.byType(TextField)).decoration!.labelText,
        isNull,
      );
      expect(find.text('nome@exemplo.com'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'p@example.test');
      await tester.tap(find.text('Enviar orientações'));
      await tester.pumpAndSettle();
      expect(find.text('Confira seu e-mail'), findsOneWidget);
      expect(find.textContaining('Se houver uma conta'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'approved reset form updates password, clears inputs and offers login',
    (tester) async {
      final repo = FakeAuthRepository()
        ..handler = (m, a) async => m == 'canResetPassword'
            ? const Success(true)
            : const Success(Unit.value);
      addTearDown(repo.dispose);
      final vm = ResetPasswordViewModel(repo);
      addTearDown(vm.dispose);
      await vm.load();
      await tester.pumpWidget(
        MaterialApp(
          home: ResetPasswordScreen(viewModel: vm),
          routes: {'/login': (_) => const Scaffold(body: Text('Login normal'))},
        ),
      );
      await tester.enterText(find.byType(TextField).first, 'long-new-password');
      await tester.enterText(find.byType(TextField).last, 'long-new-password');
      await tester.tap(find.text('Salvar nova senha'));
      await tester.pumpAndSettle();
      expect(find.text('Senha atualizada'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
      await tester.tap(find.text('Ir para o login'));
      await tester.pumpAndSettle();
      expect(find.text('Login normal'), findsOneWidget);
    },
  );
  testWidgets(
    'invalid callback never renders password fields and offers a new link',
    (tester) async {
      final repo = FakeAuthRepository()
        ..handler = (m, a) async => const Success(false);
      addTearDown(repo.dispose);
      final vm = ResetPasswordViewModel(repo);
      addTearDown(vm.dispose);
      await vm.load();
      await tester.pumpWidget(
        MaterialApp(home: ResetPasswordScreen(viewModel: vm)),
      );
      expect(find.byType(TextField), findsNothing);
      expect(find.textContaining('expirou'), findsOneWidget);
      expect(find.text('Solicitar novo link'), findsOneWidget);
    },
  );
}
