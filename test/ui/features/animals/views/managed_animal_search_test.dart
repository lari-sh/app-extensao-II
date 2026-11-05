import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/ui/features/animals/views/dashboard_screen.dart';
import 'package:abrigo_dos_anjos/ui/features/animals/view_models/dashboard_view_model.dart';
import 'package:abrigo_dos_anjos/ui/features/animals/view_models/managed_animal_search_view_model.dart';
import 'package:abrigo_dos_anjos/ui/features/medications/view_models/medication_calendar_view_model.dart';
import 'package:abrigo_dos_anjos/ui/features/medications/views/medication_calendar_panel.dart';
import 'package:abrigo_dos_anjos/domain/models/animal.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import 'package:abrigo_dos_anjos/utils/app_failure.dart';
import '../../../../support/fakes/fake_animals_repository.dart';
import '../../../../support/fakes/fake_photo_repository.dart';
import '../../../../support/fakes/fake_medication_completion_scenario.dart';
import '../../../../support/public_fixtures.dart';

void main() {
  testWidgets(
    'typing keeps keyboard focus and current cards until keyboard search',
    (tester) async {
      var checks = 0;
      final repo = FakeAnimalsRepository()
        ..handler = (_, _) async => Success(
          ManagedAnimalPage(
            items: [
              ManagedAnimal(
                animal: fixtureAnimal(1).copyWith(animalCode: 'A0001'),
              ),
            ],
            total: 1,
          ),
        );
      final search = ManagedAnimalSearchViewModel(
        repo,
        FakePhotoRepository(),
        isAuthorized: () => true,
        authorize: () async {
          checks++;
          return true;
        },
      );
      final dashboard = DashboardViewModel(repo, isAuthorized: () => true);
      addTearDown(search.dispose);
      addTearDown(dashboard.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: DashboardScreen(viewModel: dashboard, searchViewModel: search),
        ),
      );
      final field = find.byKey(const ValueKey('management-search'));
      await tester.enterText(field, 'Luna');
      await tester.pump(const Duration(seconds: 2));
      expect(repo.calls, isEmpty);
      expect(checks, 0);
      expect(tester.widget<TextField>(field).enabled, isTrue);
      expect(tester.testTextInput.isVisible, isTrue);
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();
      expect(find.text('#A0001'), findsOneWidget);
      expect(repo.calls, hasLength(1));
      await tester.enterText(field, 'Bento');
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('#A0001'), findsOneWidget);
      expect(search.state.filter.query, 'Luna');
      expect(repo.calls, hasLength(1));
      expect(checks, 1);
      expect(tester.testTextInput.isVisible, isTrue);
      expect(tester.widget<TextField>(field).controller!.text, 'Bento');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();
      expect(repo.calls, hasLength(2));
      expect(search.state.filter.query, 'Bento');
    },
  );
  for (final width in [320.0, 390.0]) {
    testWidgets(
      'search retains Kanban columns, List and daily Calendar at $width',
      (tester) async {
        tester.view.physicalSize = Size(width, 1000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final repo = FakeAnimalsRepository()
          ..handler = (m, a) async => Success(
            ManagedAnimalPage(
              items: [
                ManagedAnimal(
                  animal: fixtureAnimal(1).copyWith(animalCode: 'A0001'),
                ),
                ManagedAnimal(
                  animal: fixtureAnimal(2).copyWith(
                    animalCode: 'A0002',
                    status: AnimalStatus.treatment,
                  ),
                ),
              ],
              total: 2,
            ),
          );
        final scenario = FakeMedicationCompletionScenario();
        final calendar = MedicationCalendarViewModel(
          scenario.repository,
          now: () => DateTime.utc(2026, 11, 1),
        );
        final search = ManagedAnimalSearchViewModel(
          repo,
          FakePhotoRepository(),
          isAuthorized: () => true,
          onFilterApplied: calendar.setAnimalFilter,
        );
        final dashboard = DashboardViewModel(
          repo,
          isAuthorized: () => true,
          onCalendarSelected: calendar.initialize,
        );
        addTearDown(search.dispose);
        addTearDown(dashboard.dispose);
        addTearDown(calendar.dispose);
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(textScaler: TextScaler.linear(1.4)),
              child: DashboardScreen(
                viewModel: dashboard,
                searchViewModel: search,
                calendarViewModel: calendar,
              ),
            ),
          ),
        );
        final field = find.byKey(const ValueKey('management-search'));
        final point = tester.getTopLeft(field);
        await tester.enterText(field, 'Luna');
        expect(tester.getTopLeft(field), point);
        await tester.testTextInput.receiveAction(TextInputAction.search);
        for (var i = 0; i < 20 && search.state.loading; i++) {
          await tester.pump(const Duration(milliseconds: 20));
        }
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        expect(search.state.filter.query, 'Luna');
        expect(search.state.items.length, 2);
        expect(dashboard.isSearching, true);
        expect(dashboard.itemsForStatus(AnimalStatus.available).length, 1);
        expect(find.text('#A0001'), findsOneWidget);
        expect(find.text('#A0002'), findsOneWidget);
        expect(find.text('Disponíveis'), findsNWidgets(2));
        expect(find.text('Resultados da busca'), findsNothing);
        await tester.tap(find.text('Lista'));
        await tester.pumpAndSettle();
        expect(find.text('#A0001'), findsOneWidget);
        await tester.tap(find.text('Calendário'));
        await tester.pumpAndSettle();
        expect(find.byType(MedicationCalendarPanel), findsOneWidget);
        final calendarPoint = tester.getTopLeft(field);
        expect(find.text('#A0001'), findsNothing);
        expect(find.text('Medicações do dia para a busca'), findsOneWidget);
        await calendar.selectDay('2026-11-03');
        await tester.pumpAndSettle();
        await search.submitQuery('A0001');
        await tester.pumpAndSettle();
        expect(calendar.state.selectedDay, '2026-11-03');
        expect(
          scenario.repository.calls.last.arguments.last,
          search.state.filter,
        );
        search.clearAll();
        await tester.pumpAndSettle();
        expect(calendar.state.selectedDay, '2026-11-03');
        expect(calendar.isAnimalFiltered, false);
        expect(tester.getTopLeft(field), calendarPoint);
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets(
    'filters cancel/apply/reset and errors stay inside current mode',
    (tester) async {
      final repo = FakeAnimalsRepository()
        ..handler = (m, a) async =>
            const Success(ManagedAnimalPage(items: [], total: 0));
      final search = ManagedAnimalSearchViewModel(
        repo,
        FakePhotoRepository(),
        isAuthorized: () => true,
      );
      final dashboard = DashboardViewModel(repo, isAuthorized: () => true);
      addTearDown(search.dispose);
      addTearDown(dashboard.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: DashboardScreen(viewModel: dashboard, searchViewModel: search),
        ),
      );
      await tester.tap(find.text('Filtros'));
      await tester.pumpAndSettle();
      Future<void> choose(String label, String value) async {
        final f = find
            .ancestor(
              of: find.text(label),
              matching: find.byWidgetPredicate(
                (w) => w is DropdownButtonFormField,
              ),
            )
            .first;
        await tester.ensureVisible(f);
        await tester.tap(f);
        await tester.pumpAndSettle();
        await tester.tap(find.text(value).last);
        await tester.pumpAndSettle();
      }

      await choose('Espécie', 'Gato');
      await choose('Sexo', 'Macho');
      await choose('Porte', 'Grande');
      await choose('Situação', 'Adotado');
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Cor'),
        'preto',
      );
      await tester.ensureVisible(find.text('Aplicar filtros'));
      await tester.tap(find.text('Aplicar filtros'));
      await tester.pumpAndSettle();
      expect(search.chips.length, 5);
      expect(find.text('Sem animais'), findsWidgets);
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
      repo.handler = (m, a) async =>
          Failure<ManagedAnimalPage>(AppFailure(FailureCode.network));
      await search.search();
      await tester.pumpAndSettle();
      expect(find.text('Tentar novamente'), findsOneWidget);
      repo.handler = (m, a) async =>
          const Success(ManagedAnimalPage(items: [], total: 0));
      await tester.tap(find.text('Tentar novamente'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Filtros'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Limpar filtros'));
      await tester.tap(find.text('Limpar filtros'));
      await tester.pumpAndSettle();
      expect(search.showGlobalResults, false);
      expect(tester.takeException(), isNull);
    },
  );
}
