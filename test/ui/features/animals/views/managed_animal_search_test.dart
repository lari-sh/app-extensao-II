import 'package:abrigo_dos_anjos/ui/features/animals/views/managed_animal_search_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/ui/features/animals/views/dashboard_screen.dart';
import 'package:abrigo_dos_anjos/ui/features/animals/view_models/dashboard_view_model.dart';
import 'package:abrigo_dos_anjos/ui/features/animals/view_models/managed_animal_search_view_model.dart';
import 'package:abrigo_dos_anjos/domain/models/animal.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import 'package:abrigo_dos_anjos/utils/app_failure.dart';
import '../../../../support/fakes/fake_animals_repository.dart';
import '../../../../support/fakes/fake_photo_repository.dart';
import '../../../../support/public_fixtures.dart';

void main() {
  for (final width in [320.0, 390.0]) {
    testWidgets('fixed global search and three preserved modes at $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final r = FakeAnimalsRepository()
        ..handler = (m, a) async => Success(
          ManagedAnimalPage(
            items: [
              ManagedAnimal(
                animal: fixtureAnimal(1).copyWith(animalCode: 'A0001'),
              ),
              ManagedAnimal(
                animal: fixtureAnimal(2).copyWith(animalCode: 'A0002'),
              ),
            ],
            total: 2,
          ),
        );
      final search = ManagedAnimalSearchViewModel(
        r,
        FakePhotoRepository(),
        isAuthorized: () => true,
      );
      final dashboard = DashboardViewModel(r, isAuthorized: () => true);
      addTearDown(search.dispose);
      addTearDown(dashboard.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(1.4)),
            child: DashboardScreen(
              viewModel: dashboard,
              searchViewModel: search,
            ),
          ),
        ),
      );
      final field = find.byKey(const ValueKey('management-search'));
      final before = tester.getTopLeft(field);
      await tester.enterText(field, 'Luna');
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('#A0001'),
        100,
        scrollable: find.descendant(
          of: find.byType(ManagedAnimalSearchPanel),
          matching: find.byType(Scrollable),
        ),
      );
      expect(find.text('#A0001'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('#A0002'),
        100,
        scrollable: find.descendant(
          of: find.byType(ManagedAnimalSearchPanel),
          matching: find.byType(Scrollable),
        ),
      );
      expect(find.text('#A0002'), findsOneWidget);
      for (final mode in ['Lista', 'Calendário', 'Kanban']) {
        await tester.tap(find.text(mode));
        await tester.pumpAndSettle();
        expect(find.byType(ManagedAnimalSearchPanel), findsOneWidget);
        expect(tester.getTopLeft(field), before);
      }
      search.clearAll();
      await tester.pumpAndSettle();
      expect(search.showGlobalResults, false);
      expect(find.text('Resultados da busca'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets(
    'filters apply or cancel, chips remove and empty/error retry are usable',
    (tester) async {
      final r = FakeAnimalsRepository()
        ..handler = (m, a) async =>
            const Success(ManagedAnimalPage(items: [], total: 0));
      final search = ManagedAnimalSearchViewModel(
        r,
        FakePhotoRepository(),
        isAuthorized: () => true,
      );
      final dashboard = DashboardViewModel(r, isAuthorized: () => true);
      addTearDown(search.dispose);
      addTearDown(dashboard.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: DashboardScreen(viewModel: dashboard, searchViewModel: search),
        ),
      );
      await tester.tap(find.text('Filtros'));
      await tester.pumpAndSettle();
      expect(find.text('Filtrar animais'), findsOneWidget);
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Cor'),
        'preto',
      );
      await tester.ensureVisible(find.text('Aplicar filtros'));
      await tester.tap(find.text('Aplicar filtros'));
      await tester.pumpAndSettle();
      expect(search.state.filter.color, 'preto');
      expect(find.text('Nenhum animal encontrado'), findsOneWidget);
      await tester.tap(find.text('Filtros'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Cor'),
        'branco',
      );
      await tester.ensureVisible(find.text('Cancelar'));
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(search.state.filter.color, 'preto');
      r.handler = (m, a) async =>
          Failure<ManagedAnimalPage>(AppFailure(FailureCode.network));
      await search.search();
      await tester.pumpAndSettle();
      expect(find.text('Tentar novamente'), findsOneWidget);
      r.handler = (m, a) async =>
          const Success(ManagedAnimalPage(items: [], total: 0));
      await tester.tap(find.text('Tentar novamente'));
      await tester.pumpAndSettle();
      expect(search.state.message, isNull);
      await tester.tap(find.byTooltip('Delete'));
      await tester.pumpAndSettle();
      expect(search.showGlobalResults, false);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'all enum filters, toolbar submit/clear and filter reset follow approved commands',
    (tester) async {
      final r = FakeAnimalsRepository()
        ..handler = (m, a) async =>
            const Success(ManagedAnimalPage(items: [], total: 0));
      final search = ManagedAnimalSearchViewModel(
        r,
        FakePhotoRepository(),
        isAuthorized: () => true,
      );
      final dashboard = DashboardViewModel(r, isAuthorized: () => true);
      addTearDown(search.dispose);
      addTearDown(dashboard.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: DashboardScreen(viewModel: dashboard, searchViewModel: search),
        ),
      );
      await tester.tap(find.text('Filtros'));
      await tester.pumpAndSettle();
      Future<void> option(String label, String value) async {
        final field = find
            .ancestor(
              of: find.text(label),
              matching: find.byWidgetPredicate(
                (w) => w is DropdownButtonFormField,
              ),
            )
            .first;
        await tester.ensureVisible(field);
        await tester.tap(field);
        await tester.pumpAndSettle();
        await tester.tap(find.text(value).last);
        await tester.pumpAndSettle();
      }

      await option('Espécie', 'Gato');
      await option('Sexo', 'Macho');
      await option('Porte', 'Grande');
      await option('Situação', 'Adotado');
      await tester.ensureVisible(find.text('Aplicar filtros'));
      await tester.tap(find.text('Aplicar filtros'));
      await tester.pumpAndSettle();
      expect(search.chips.length, 4);
      final field = find.byKey(const ValueKey('management-search'));
      await tester.enterText(field, 'Luna');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();
      expect(search.state.filter.query, 'Luna');
      await tester.tap(find.byTooltip('Limpar texto'));
      await tester.pumpAndSettle();
      expect(search.state.filter.query, isEmpty);
      expect(search.showGlobalResults, true);
      await tester.tap(find.text('Filtros'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Limpar filtros'));
      await tester.tap(find.text('Limpar filtros'));
      await tester.pumpAndSettle();
      expect(search.showGlobalResults, false);
      await tester.tap(find.text('Filtros'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Cancelar filtros'));
      await tester.pumpAndSettle();
      expect(search.chips, isEmpty);
      expect(tester.takeException(), isNull);
    },
  );
}
