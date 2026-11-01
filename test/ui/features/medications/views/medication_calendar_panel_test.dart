import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/domain/models/medication_agenda.dart';
import 'package:abrigo_dos_anjos/domain/models/medication_application.dart';
import 'package:abrigo_dos_anjos/ui/features/medications/view_models/medication_calendar_view_model.dart';
import 'package:abrigo_dos_anjos/ui/features/medications/views/medication_calendar_panel.dart';
import 'package:abrigo_dos_anjos/ui/core/theme/app_theme.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import 'package:abrigo_dos_anjos/utils/app_failure.dart';
import '../../../../support/fakes/fake_medications_repository.dart';

FakeMedicationsRepository repository() =>
    FakeMedicationsRepository()
      ..handler = (method, args) async {
        if (method == 'loadMonth') {
          return Success(
            MedicationMonth(
              month: args.first as String,
              serverNow: DateTime.utc(2026, 11, 1, 12),
              shelterToday: '2026-11-01',
              days: const [MedicationDaySummary(day: '2026-11-01', pending: 1)],
            ),
          );
        }
        return Success(
          MedicationDayPage(
            day: args.first as String,
            serverNow: DateTime.utc(2026, 11, 1, 12),
            agendaVersion: 1,
            items: args.first == '2026-11-01'
                ? [
                    MedicationApplication(
                      id: 'application',
                      treatmentId: 't',
                      animalId: 'a',
                      animalName: 'Atena',
                      medicationName: 'Amoxicilina',
                      revision: 1,
                      version: 1,
                      scheduledAt: DateTime.utc(2026, 11, 1, 11),
                      scheduledLocalDate: '2026-11-01',
                      scheduledLocalTime: '08:00',
                    ),
                  ]
                : [],
          ),
        );
      };
void main() {
  testWidgets('approved month/day view navigates and shows real day state', (
    tester,
  ) async {
    final vm = MedicationCalendarViewModel(repository());
    addTearDown(vm.dispose);
    await vm.initialize();
    await tester.pumpWidget(
      MaterialApp(
        theme: buildTheme(),
        home: Scaffold(body: MedicationCalendarPanel(viewModel: vm)),
      ),
    );
    expect(find.text('Novembro 2026'), findsOneWidget);
    expect(find.text('Atena'), findsOneWidget);
    expect(find.text('08:00'), findsOneWidget);
    expect(find.text('Atrasada'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('medicationDay-2026-11-02')));
    await tester.pumpAndSettle();
    expect(find.text('Dia livre de aplicações'), findsOneWidget);
    await tester.tap(find.byTooltip('Próximo mês'));
    await tester.pumpAndSettle();
    expect(find.text('Dezembro 2026'), findsOneWidget);
    await tester.tap(find.byTooltip('Mês anterior'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hoje'));
    await tester.pumpAndSettle();
    expect(vm.state.selectedDay, '2026-11-01');
    expect(find.text('Atena'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('calendar preserves controls at 320 px and enlarged text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final vm = MedicationCalendarViewModel(repository());
    addTearDown(vm.dispose);
    await vm.initialize();
    await tester.pumpWidget(
      MaterialApp(
        theme: buildTheme(),
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(320, 844),
            textScaler: TextScaler.linear(1.4),
          ),
          child: Scaffold(body: MedicationCalendarPanel(viewModel: vm)),
        ),
      ),
    );
    await tester.tap(find.byTooltip('Próximo mês'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hoje'));
    await tester.pumpAndSettle();
    expect(find.text('Atena'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('calendar renders recoverable month/day failures and retry', (
    tester,
  ) async {
    final repo = repository();
    final vm = MedicationCalendarViewModel(repo);
    addTearDown(vm.dispose);
    await vm.initialize();
    repo.handler = (_, _) async =>
        Failure<MedicationMonth>(AppFailure(FailureCode.network));
    await vm.refresh();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: MedicationCalendarPanel(viewModel: vm)),
      ),
    );
    expect(find.text('Tentar carregar calendário'), findsOneWidget);
    repo.handler = repository().handler;
    await tester.tap(find.text('Tentar carregar calendário'));
    await tester.pumpAndSettle();
    expect(find.text('Atena'), findsOneWidget);
    repo.handler = (method, args) async => method == 'loadMonth'
        ? repository().handler!(method, args)
        : Failure<MedicationDayPage>(AppFailure(FailureCode.network));
    await tester.tap(find.byKey(const ValueKey('medicationDay-2026-11-02')));
    await tester.pumpAndSettle();
    expect(find.text('Tentar carregar agenda'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
