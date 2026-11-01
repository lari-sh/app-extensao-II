import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/ui/core/widgets/app_back_button.dart';

void main() {
  testWidgets(
    'visible return pops only the current route and preserves previous screen',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => Scaffold(
                      appBar: AppBar(leading: const AppBackButton()),
                      body: const Text('Tela interna'),
                    ),
                  ),
                ),
                child: const Text('Origem'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Origem'));
      await tester.pumpAndSettle();
      expect(find.text('Tela interna'), findsOneWidget);
      await tester.tap(find.byTooltip('Voltar'));
      await tester.pumpAndSettle();
      expect(find.text('Origem'), findsOneWidget);
      expect(find.text('Tela interna'), findsNothing);
    },
  );
  testWidgets(
    'visible return respects a blocked route instead of bypassing its guard',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => PopScope(
                      canPop: false,
                      child: Scaffold(
                        appBar: AppBar(leading: const AppBackButton()),
                        body: const Text('Acesso em verificação'),
                      ),
                    ),
                  ),
                ),
                child: const Text('Origem'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Origem'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Voltar'));
      await tester.pumpAndSettle();
      expect(find.text('Acesso em verificação'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
