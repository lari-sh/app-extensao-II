import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/ui/features/auth/views/login_screen.dart';
import 'package:abrigo_dos_anjos/ui/features/auth/view_models/login_view_model.dart';
import 'package:abrigo_dos_anjos/domain/models/session_access.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import '../../../../support/fakes/fake_auth_repository.dart';

void main() {
  testWidgets(
    'authorized login navigates to protected destination without public signup',
    (tester) async {
      final repo = FakeAuthRepository()
        ..handler = (_, args) async => const Success(
          SessionAccess(level: AccessLevel.authorized, userId: 'u'),
        );
      addTearDown(repo.dispose);
      final vm = LoginViewModel(repo);
      addTearDown(vm.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(viewModel: vm),
          routes: {
            '/volunteer': (_) =>
                const Scaffold(body: Text('Destino protegido')),
          },
        ),
      );
      await tester.enterText(
        find.byKey(const ValueKey('loginEmail')),
        'staff@example.test',
      );
      await tester.enterText(
        find.byKey(const ValueKey('loginPassword')),
        'secret',
      );
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();
      expect(find.text('Destino protegido'), findsOneWidget);
      expect(find.text('Criar conta'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
