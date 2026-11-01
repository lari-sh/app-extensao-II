import 'package:abrigo_dos_anjos/ui/features/medications/view_models/medication_calendar_view_model.dart';
import 'package:abrigo_dos_anjos/ui/features/medications/views/medication_calendar_panel.dart';
import 'package:abrigo_dos_anjos/domain/models/medication_agenda.dart';
import '../../../../support/fakes/fake_medications_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/ui/features/animals/views/dashboard_screen.dart';
import 'package:abrigo_dos_anjos/ui/features/animals/view_models/dashboard_view_model.dart';
import 'package:abrigo_dos_anjos/domain/models/animal.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import '../../../../support/fakes/fake_animals_repository.dart';
import '../../../../support/public_fixtures.dart';

void main() {
  testWidgets(
    'prototype dashboard switches list, updates status by menu and publishes confirmed animal',
    (tester) async {
      var animal = fixtureAnimal(1).copyWith(isPublished: false);
      final repo = FakeAnimalsRepository()
        ..handler = (method, args) async {
          if (method == 'getStatusCounts') {
            return Success<Map<AnimalStatus, int>>({
              for (final s in AnimalStatus.values)
                s: s == animal.status ? 1 : 0,
            });
          }
          if (method == 'listManagement') {
            return Success(
              ManagedAnimalPage(
                items: args.first == animal.status
                    ? [ManagedAnimal(animal: animal)]
                    : [],
                total: args.first == animal.status ? 1 : 0,
              ),
            );
          }
          if (method == 'setStatus') {
            animal = animal.copyWith(status: args[1] as AnimalStatus);
          }
          if (method == 'setPublication') {
            animal = animal.copyWith(isPublished: args[1] as bool);
          }
          return Success(animal);
        };
      final vm = DashboardViewModel(repo, isAuthorized: () => true);
      addTearDown(vm.dispose);
      await vm.load();
      await tester.pumpWidget(
        MaterialApp(home: DashboardScreen(viewModel: vm)),
      );
      expect(find.text('Kanban'), findsOneWidget);
      expect(find.text('Olá, equipe'), findsOneWidget);
      await tester.tap(find.text('Lista'));
      await tester.pumpAndSettle();
      expect(vm.state.listMode, true);
      await tester.tap(find.byTooltip('Ações de Luna 1'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mover para Em tratamento'));
      await tester.pumpAndSettle();
      expect(animal.status, AnimalStatus.treatment);
      expect(vm.state.counts[AnimalStatus.treatment], 1);
      await tester.tap(find.byTooltip('Ações de Luna 1'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Publicar no catálogo'));
      await tester.pumpAndSettle();
      expect(animal.isPublished, true);
      expect(find.text('Publicado'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'calendar tab preserves dashboard header and Kanban/List regressions at 320 px',
    (tester) async {
      tester.view.physicalSize = const Size(320, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final animals = FakeAnimalsRepository()
        ..handler = (method, args) async => method == 'getStatusCounts'
            ? const Success<Map<AnimalStatus, int>>({AnimalStatus.available: 2})
            : const Success(ManagedAnimalPage(items: [], total: 0));
      final meds = FakeMedicationsRepository()
        ..handler = (method, args) async => method == 'loadMonth'
            ? Success(
                MedicationMonth(
                  month: args.first as String,
                  serverNow: DateTime.utc(2026, 11, 1),
                  shelterToday: '2026-11-01',
                ),
              )
            : Success(
                MedicationDayPage(
                  day: args.first as String,
                  serverNow: DateTime.utc(2026, 11, 1),
                  agendaVersion: 1,
                ),
              );
      final calendar = MedicationCalendarViewModel(meds);
      addTearDown(calendar.dispose);
      final vm = DashboardViewModel(
        animals,
        isAuthorized: () => true,
        onCalendarSelected: calendar.initialize,
      );
      addTearDown(vm.dispose);
      await vm.load();
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(320, 844),
              textScaler: TextScaler.linear(1.4),
            ),
            child: DashboardScreen(viewModel: vm, calendarViewModel: calendar),
          ),
        ),
      );
      await tester.tap(find.text('Calendário'));
      await tester.pumpAndSettle();
      expect(find.byType(MedicationCalendarPanel), findsOneWidget);
      expect(find.text('Novembro 2026'), findsOneWidget);
      expect(find.text('Olá, equipe'), findsOneWidget);
      expect(find.byKey(const ValueKey('count-available')), findsOneWidget);
      await tester.tap(find.text('Lista'));
      await tester.pumpAndSettle();
      expect(vm.state.mode, DashboardMode.list);
      expect(find.byType(MedicationCalendarPanel), findsNothing);
      await tester.tap(find.text('Kanban'));
      await tester.pumpAndSettle();
      expect(vm.state.mode, DashboardMode.kanban);
      expect(tester.takeException(), isNull);
    },
  );
}
