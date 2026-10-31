import 'package:flutter_test/flutter_test.dart';
import '../../../../support/public_app_harness.dart';

void main() {
  testWidgets('about describes shelter and returns home', (tester) async {
    final harness = PublicAppHarness();
    await tester.pumpWidget(harness.app());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Quero Adotar (Visitante)'));
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sobre'));
    await tester.pumpAndSettle();
    expect(find.textContaining('lares responsáveis'), findsOneWidget);
    await tester.tap(find.text('Voltar ao início'));
    await tester.pumpAndSettle();
    expect(find.text('Quero Adotar (Visitante)'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
