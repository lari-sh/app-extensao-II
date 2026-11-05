import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/domain/models/animal_query.dart';
import 'package:abrigo_dos_anjos/domain/models/animal.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import '../../../../support/public_app_harness.dart';

void main() {
  testWidgets(
    'bottom search confirms terms, size and sex filters apply, home returns',
    (tester) async {
      final h = PublicAppHarness();
      await tester.pumpWidget(h.app());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Quero Adotar (Visitante)'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('catalogSearch')),
        'gata femea',
      );
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Buscar'));
      await tester.pumpAndSettle();
      expect(
        (h.animals.calls.last.arguments.first as AnimalQuery).species,
        AnimalSpecies.cat,
      );
      await tester.tap(find.byKey(const ValueKey('sizeFilter')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pequeno').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('sexFilter')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Macho').last);
      await tester.pumpAndSettle();
      final query = h.animals.calls.last.arguments.first as AnimalQuery;
      expect(query.size, AnimalSize.small);
      expect(query.sex, AnimalSex.male);
      expect(query.species, AnimalSpecies.cat);
      await tester.tap(find.text('Início'));
      await tester.pumpAndSettle();
      expect(find.text('Quero Adotar (Visitante)'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'visitor confirms combined terms and sees corresponding filters without losing name',
    (tester) async {
      final h = PublicAppHarness();
      h.animals.handler = (_, _) async =>
          const Success(AnimalPage(items: [], total: 0));
      await tester.pumpWidget(h.app());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Quero Adotar (Visitante)'));
      await tester.pumpAndSettle();
      final count = h.animals.calls.length;
      final field = find.byKey(const ValueKey('catalogSearch'));
      await tester.enterText(field, 'Luna gata femea');
      await tester.pump(const Duration(seconds: 2));
      expect(h.animals.calls, hasLength(count));
      expect(tester.testTextInput.isVisible, isTrue);
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();
      final q = h.animals.calls.last.arguments.first as AnimalQuery;
      expect(q.name, 'Luna');
      expect(q.species, AnimalSpecies.cat);
      expect(q.sex, AnimalSex.female);
      expect(tester.widget<TextField>(field).controller!.text, 'Luna');
      expect(
        tester
            .widget<DropdownButton<String>>(
              find.byKey(const ValueKey('speciesFilter')),
            )
            .value,
        'cat',
      );
      expect(
        tester
            .widget<DropdownButton<String>>(
              find.byKey(const ValueKey('sexFilter')),
            )
            .value,
        'female',
      );
      for (final term in ['gato macho', 'gata femea', 'gato femea']) {
        await tester.tap(field);
        await tester.enterText(field, term);
        await tester.pump(const Duration(seconds: 1));
        await tester.testTextInput.receiveAction(TextInputAction.search);
        await tester.pumpAndSettle();
        expect(
          (h.animals.calls.last.arguments.first as AnimalQuery).sex,
          term.contains('macho') ? AnimalSex.male : AnimalSex.female,
        );
      }
      await tester.tap(find.text('Limpar filtros'));
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(field).controller!.text, isEmpty);
      expect(h.animals.calls.last.arguments.first, const AnimalQuery());
    },
  );
  testWidgets('catalog combines text and species filter then opens detail', (
    tester,
  ) async {
    final harness = PublicAppHarness();
    await tester.pumpWidget(harness.app());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Quero Adotar (Visitante)'));
    await tester.pumpAndSettle();
    expect(find.text('VITRINE'), findsNothing);
    expect(
      tester.getCenter(find.byTooltip('Voltar')).dx,
      lessThan(tester.getTopLeft(find.text('Conheça nossos anjos')).dx),
    );
    expect(find.text('Conheça nossos anjos'), findsOneWidget);
    expect(find.byType(GridView), findsOneWidget);
    expect(find.text('Início'), findsOneWidget);
    await tester.enterText(find.byKey(const ValueKey('catalogSearch')), 'Luna');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('speciesFilter')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cachorro').last);
    await tester.pumpAndSettle();
    expect(find.text('Luna 1'), findsOneWidget);
    await tester.tap(find.text('Luna 1'));
    await tester.pumpAndSettle();
    expect(find.text('Entrar em contato para adoção'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'compact catalog wraps count beside clear filters without overflow',
    (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final harness = PublicAppHarness();
      await tester.pumpWidget(harness.app());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Quero Adotar (Visitante)'));
      await tester.pumpAndSettle();
      expect(find.text('1 animais encontrados'), findsOneWidget);
      expect(find.text('Limpar filtros'), findsOneWidget);
      expect(
        tester.getCenter(find.byTooltip('Voltar')).dx,
        lessThan(tester.getTopLeft(find.text('Conheça nossos anjos')).dx),
      );
      await tester.tap(find.byTooltip('Voltar'));
      await tester.pumpAndSettle();
      expect(find.text('Quero Adotar (Visitante)'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
