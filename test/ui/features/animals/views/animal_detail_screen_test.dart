import 'package:flutter_test/flutter_test.dart';
import '../../../../support/public_app_harness.dart';

void main() {
  testWidgets('detail copies interest without sending adoption request', (
    tester,
  ) async {
    final harness = PublicAppHarness();
    await tester.pumpWidget(harness.app());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Quero adotar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Luna 1'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tenho interesse'));
    await tester.pumpAndSettle();
    expect(
      find.text('Mensagem copiada. Nenhum pedido foi enviado.'),
      findsOneWidget,
    );
    expect(harness.adoption.calls.length, 1);
    expect(tester.takeException(), isNull);
  });
}
