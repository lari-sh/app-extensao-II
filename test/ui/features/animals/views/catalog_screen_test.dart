import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../../support/public_app_harness.dart';

void main() {
  testWidgets('catalog combines text and species filter then opens detail', (
    tester,
  ) async {
    final harness = PublicAppHarness();
    await tester.pumpWidget(harness.app());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Quero adotar'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('catalogSearch')), 'Luna');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('speciesFilter')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cachorro').last);
    await tester.pumpAndSettle();
    expect(find.text('Luna 1'), findsOneWidget);
    await tester.tap(find.text('Luna 1'));
    await tester.pumpAndSettle();
    expect(find.text('Tenho interesse'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
