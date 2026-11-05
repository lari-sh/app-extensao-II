import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'support/public_app_harness.dart';

void main() {
  testWidgets(
    'current app opens approved entry and public catalog without demo routes',
    (tester) async {
      final harness = PublicAppHarness();
      await tester.pumpWidget(harness.app());
      await tester.pumpAndSettle();
      expect(find.text('Escolha como entrar:'), findsOneWidget);
      await tester.tap(find.text('Quero Adotar (Visitante)'));
      await tester.pumpAndSettle();
      expect(find.text('Conheça nossos anjos'), findsOneWidget);
      expect(find.byType(GridView), findsOneWidget);
      expect(find.text('Luna 1'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
