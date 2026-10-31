import 'package:flutter_test/flutter_test.dart';
import '../../../../support/public_app_harness.dart';

void main() {
  testWidgets('home navigation reaches catalog', (tester) async {
    final harness = PublicAppHarness();
    await tester.pumpWidget(harness.app());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Quero adotar'));
    await tester.pumpAndSettle();
    expect(find.text('Luna 1'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
