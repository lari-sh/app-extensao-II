import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../../support/public_app_harness.dart';

void main() {
  testWidgets('home navigation reaches catalog', (tester) async {
    final harness = PublicAppHarness();
    await tester.pumpWidget(harness.app());
    await tester.pumpAndSettle();
    expect(find.byType(AppBar), findsNothing);
    expect(find.text('Escolha como entrar:'), findsOneWidget);
    expect(find.text('Acesso Voluntário / Funcionário'), findsOneWidget);
    await tester.tap(find.text('Quero Adotar (Visitante)'));
    await tester.pumpAndSettle();
    expect(find.text('Luna 1'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
