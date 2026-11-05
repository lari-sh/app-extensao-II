import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:abrigo_dos_anjos/app/bootstrap.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'visitor opens prototype sheet with real public photo, opens contact and closes',
    (tester) async {
      final previousHitTestPolicy =
          WidgetController.hitTestWarningShouldBeFatal;
      WidgetController.hitTestWarningShouldBeFatal = true;
      addTearDown(() {
        WidgetController.hitTestWarningShouldBeFatal = previousHitTestPolicy;
      });
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
      await tester.testTextInput.receiveAction(TextInputAction.search);
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
      final sheet = find.byKey(const ValueKey('publicAnimalSheet'));
      expect(sheet, findsOneWidget);
      expect(
        find.descendant(
          of: sheet,
          matching: find.byWidgetPredicate(
            (widget) => widget is Image && widget.image is MemoryImage,
          ),
        ),
        findsOneWidget,
      );
      expect(find.text('Vacinas'), findsOneWidget);
      expect(find.text('Castrado'), findsOneWidget);
      expect(find.text('Não informado'), findsNWidgets(5));
      expect(find.text('Notas internas'), findsNothing);
      final add = find.byTooltip('Favoritar Animal de teste 01');
      if (add.evaluate().isNotEmpty) {
        await tester.tap(add);
        await tester.pumpAndSettle();
      }
      expect(
        find.byTooltip('Remover Animal de teste 01 dos favoritos'),
        findsOneWidget,
      );
      await tester.tap(find.text('Entrar em contato para adoção'));
      await tester.pumpAndSettle();
      expect(find.text('Fale com o abrigo'), findsOneWidget);
      final returnButton = find.widgetWithText(
        OutlinedButton,
        'Voltar à ficha do animal',
      );
      await tester.scrollUntilVisible(returnButton, 160);
      await tester.pumpAndSettle();
      expect(returnButton.hitTestable(), findsOneWidget);
      await tester.tap(returnButton.hitTestable());
      await tester.pumpAndSettle();
      expect(sheet, findsOneWidget);
      expect(find.text('Fale com o abrigo'), findsNothing);
      await tester.tap(find.byTooltip('Fechar detalhes'));
      await tester.pumpAndSettle();
      expect(sheet, findsNothing);
      expect(find.text('Conheça nossos anjos'), findsOneWidget);
      await tester.tap(find.text('Favoritos'));
      await tester.pumpAndSettle();
      expect(find.text('Animal de teste 01'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
