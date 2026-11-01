import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:abrigo_dos_anjos/app/bootstrap.dart';
import 'package:abrigo_dos_anjos/ui/features/adoption/views/adoption_contact_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'visitor opens approved contact, returns to animal and launches official Instagram',
    (tester) async {
      expect(
        Uri.parse(const String.fromEnvironment('SUPABASE_URL')).host,
        '10.0.2.2',
      );
      await tester.pumpWidget(await bootstrapApplication());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Quero Adotar (Visitante)'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('catalogSearch')),
        'Animal de teste 01',
      );
      await tester.pumpAndSettle();
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(Card),
          matching: find.text('Animal de teste 01'),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Entrar em contato para adoção'));
      await tester.pumpAndSettle();
      expect(find.text('Fale com o abrigo'), findsOneWidget);
      expect(find.text('Animal de teste 01'), findsOneWidget);
      expect(find.textContaining('Prévia da mensagem'), findsNothing);
      await tester.tap(find.byTooltip('Voltar à ficha do animal'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('publicAnimalSheet')), findsOneWidget);
      await tester.tap(find.text('Entrar em contato para adoção'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Voltar à ficha do animal'),
        160,
      );
      await tester.tap(find.text('Voltar à ficha do animal'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('publicAnimalSheet')), findsOneWidget);
      await tester.tap(find.text('Entrar em contato para adoção'));
      await tester.pumpAndSettle();
      final screen = tester.widget<AdoptionContactScreen>(
        find.byType(AdoptionContactScreen),
      );
      await screen.viewModel.openInstagram();
      expect(screen.viewModel.state.message, isNull);
      expect(screen.viewModel.state.opening, isFalse);
      expect(tester.takeException(), isNull);
    },
  );
}
