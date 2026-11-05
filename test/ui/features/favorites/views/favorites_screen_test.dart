import 'package:flutter_test/flutter_test.dart';
import '../../../../support/public_app_harness.dart';

void main() {
  testWidgets('favorite removal updates visible list', (tester) async {
    final harness = PublicAppHarness();
    await tester.pumpWidget(harness.app());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Quero Adotar (Visitante)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Favoritos'));
    await tester.pumpAndSettle();
    expect(find.text('Luna 1'), findsOneWidget);
    await tester.tap(find.byTooltip('Remover Luna 1 dos favoritos'));
    await tester.pumpAndSettle();
    expect(find.text('Luna 1'), findsNothing);
    expect(
      find.text('Você ainda não tem favoritos disponíveis.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
