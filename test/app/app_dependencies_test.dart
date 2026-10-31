import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:abrigo_dos_anjos/ui/features/auth/view_models/session_view_model.dart';
import 'package:abrigo_dos_anjos/domain/repositories/auth_repository.dart';
import '../support/auth_app_harness.dart';

void main() {
  testWidgets(
    'Provider owns one session across routes and logout removes private stack',
    (tester) async {
      final harness = AuthAppHarness();
      addTearDown(harness.auth.dispose);
      await tester.pumpWidget(harness.app());
      await tester.pumpAndSettle();
      final context = tester.element(find.text('Quero adotar'));
      expect(context.read<AuthRepository>(), same(harness.auth));
      expect(context.read<SessionViewModel>(), same(harness.session));
      await tester.ensureVisible(find.text('Área do voluntário'));
      await tester.tap(find.text('Área do voluntário'));
      await tester.pumpAndSettle();
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
      expect(find.text('Acesso autorizado'), findsOneWidget);
      await tester.tap(find.text('Sair da conta'));
      await tester.pumpAndSettle();
      expect(find.text('Quero adotar'), findsOneWidget);
      expect(find.text('Acesso autorizado'), findsNothing);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Acesso autorizado'), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    },
  );
}
