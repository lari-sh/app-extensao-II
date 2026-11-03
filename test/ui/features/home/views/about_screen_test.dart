import 'package:flutter/material.dart';
import 'package:abrigo_dos_anjos/ui/features/home/views/about_screen.dart';
import 'package:abrigo_dos_anjos/ui/features/home/view_models/about_view_model.dart';
import '../view_models/about_contacts_test.dart' show AboutRepository;
import 'package:flutter_test/flutter_test.dart';
import '../../../../support/public_app_harness.dart';

void main() {
  testWidgets(
    'donation key is selectable and copy confirms, contacts open through VM',
    (tester) async {
      final repo = AboutRepository();
      final vm = AboutViewModel(repo);
      await tester.pumpWidget(MaterialApp(home: AboutScreen(viewModel: vm)));
      expect(find.text('23.785.379/0001-98'), findsOneWidget);
      await tester.ensureVisible(find.text('Copiar chave Pix'));
      await tester.tap(find.text('Copiar chave Pix'));
      await tester.pumpAndSettle();
      expect(repo.copies, 1);
      expect(find.text('Chave Pix copiada!'), findsOneWidget);
      for (final label in ['WhatsApp', 'Instagram', 'Facebook']) {
        await tester.ensureVisible(find.text(label));
        await tester.tap(find.text(label));
        await tester.pumpAndSettle();
      }
      expect(repo.opened, isNotNull);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      vm.dispose();
    },
  );

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
    await tester.scrollUntilVisible(
      find.text('Voltar ao início'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Voltar ao início'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Voltar ao início'));
    await tester.pumpAndSettle();
    expect(find.text('Quero Adotar (Visitante)'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
