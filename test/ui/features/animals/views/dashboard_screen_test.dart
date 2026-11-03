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
  for (final width in [320.0, 390.0]) {
    testWidgets('Kanban uses available width in three columns at $width px', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final statuses = [
        AnimalStatus.available,
        AnimalStatus.treatment,
        AnimalStatus.quarantine,
      ];
      final animals = [
        for (var i = 0; i < statuses.length; i++)
          fixtureAnimal(i + 1).copyWith(
            status: statuses[i],
            name: i == 2
                ? 'Um nome muito longo para testar a quebra de texto no cartão'
                : 'Luna ${i + 1}',
          ),
      ];
      final repo = FakeAnimalsRepository()
        ..handler = (method, args) async => method == 'getStatusCounts'
            ? Success<Map<AnimalStatus, int>>({for (final s in statuses) s: 1})
            : Success(
                ManagedAnimalPage(
                  items: [
                    for (final a in animals)
                      if (a.status == args.first)
                        ManagedAnimal(
                          animal: a,
                          clinicalNotes: a.status == AnimalStatus.available
                              ? ''
                              : a.status == AnimalStatus.treatment
                              ? 'Observação curta'
                              : List.filled(
                                  25,
                                  'Observação completa de teste.',
                                ).join(' '),
                        ),
                  ],
                  total: 1,
                ),
              );
      final vm = DashboardViewModel(repo, isAuthorized: () => true);
      addTearDown(vm.dispose);
      await vm.load();
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(
              size: Size(width, 844),
              textScaler: const TextScaler.linear(1.4),
            ),
            child: DashboardScreen(viewModel: vm),
          ),
        ),
      );
      final board = find.byKey(const ValueKey('animal-kanban'));
      final cards = find.descendant(of: board, matching: find.byType(Card));
      expect(cards, findsNWidgets(3));
      double previousRight = 0;
      final firstRect = tester.getRect(cards.first);
      for (final card in cards.evaluate()) {
        final rect = tester.getRect(find.byWidget(card.widget));
        // Reclaim the side gutters while preserving all three columns.
        expect(rect.width, greaterThanOrEqualTo(width / 3 - 3));
        expect(rect.height, closeTo(firstRect.height, 0.01));
        expect(rect.top, closeTo(firstRect.top, 0.01));
        expect(rect.left, greaterThanOrEqualTo(previousRight));
        expect(rect.right, lessThanOrEqualTo(width));
        previousRight = rect.right;
      }
      final scrollables = tester.widgetList<Scrollable>(
        find.descendant(of: board, matching: find.byType(Scrollable)),
      );
      expect(
        scrollables.every((s) => s.axisDirection == AxisDirection.down),
        isTrue,
      );
      await tester.tap(find.byTooltip('Ações de ${animals.first.name}'));
      await tester.pumpAndSettle();
      expect(find.text('Editar cadastro'), findsOneWidget);
      expect(find.text('Mover para Em tratamento'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'Kanban shows private clinical summary in prototype pill at 320 px',
    (tester) async {
      tester.view.physicalSize = const Size(320, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final animal = fixtureAnimal(1).copyWith(status: AnimalStatus.treatment);
      final repo = FakeAnimalsRepository()
        ..handler = (method, args) async => method == 'getStatusCounts'
            ? const Success<Map<AnimalStatus, int>>({AnimalStatus.treatment: 1})
            : Success(
                ManagedAnimalPage(
                  items: args.first == AnimalStatus.treatment
                      ? [
                          ManagedAnimal(
                            animal: animal,
                            clinicalNotes:
                                'Dermatite — acompanhamento e cuidado diário da pele',
                          ),
                        ]
                      : [],
                  total: args.first == AnimalStatus.treatment ? 1 : 0,
                ),
              );
      final vm = DashboardViewModel(repo, isAuthorized: () => true);
      addTearDown(vm.dispose);
      await vm.load();
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(1.4)),
            child: DashboardScreen(viewModel: vm),
          ),
        ),
      );
      expect(
        find.text('Dermatite — acompanhamento e cuidado diário da pele'),
        findsOneWidget,
      );
      expect(
        find.byKey(ValueKey('clinicalSummary-${animal.id}')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

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
