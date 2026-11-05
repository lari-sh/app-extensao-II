import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/ui/features/medications/views/medication_editor_panel.dart';
import 'package:abrigo_dos_anjos/ui/features/medications/view_models/medication_editor_view_model.dart';
import 'package:abrigo_dos_anjos/domain/models/medication_agenda.dart';
import 'package:abrigo_dos_anjos/domain/models/medication_application.dart';
import 'package:abrigo_dos_anjos/domain/models/medication_treatment.dart';
import 'package:abrigo_dos_anjos/domain/models/medication_schedule.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import 'package:abrigo_dos_anjos/utils/app_failure.dart';
import '../../../../support/fakes/fake_medications_repository.dart';
import '../../../../support/medication_fixtures.dart';

void main() {
  late FakeMedicationsRepository repo;
  late MedicationEditorViewModel vm;
  setUp(() {
    repo = FakeMedicationsRepository()
      ..handler = (_, _) async => const Success(MedicationTreatmentPage());
    vm = MedicationEditorViewModel(repo);
  });
  tearDown(() => vm.dispose());
  Future<void> open(WidgetTester tester) async {
    await vm.bindAnimal(medicationAnimalId, 'Luna');
    vm.startCreate();
    vm.setName('Teste');
    vm.setStartDate('01/11/2026');
    vm.setEndDate('04/11/2026');
    await tester.pumpWidget(
      MaterialApp(home: MedicationProgrammingScreen(viewModel: vm)),
    );
    await tester.pumpAndSettle();
  }

  Finder scroll() => find
      .descendant(
        of: find.byKey(const ValueKey('medicationFormScroll')),
        matching: find.byType(Scrollable),
      )
      .first;
  Future<void> visible(WidgetTester tester, Finder target) async {
    await tester.scrollUntilVisible(target, 150, scrollable: scroll());
    await tester.pumpAndSettle();
  }

  testWidgets('date pickers update both boundaries of the clinical period', (
    tester,
  ) async {
    await open(tester);
    for (final start in [true, false]) {
      final button = find.byTooltip(
        start ? 'Escolher data de início' : 'Escolher data de término',
      );
      await visible(tester, button);
      await tester.tap(button);
      await tester.pumpAndSettle();
      await tester.tap(find.text(start ? '2' : '5').last);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
    }
    expect(vm.state.draft.schedule.startsOn, '2026-11-02');
    expect(vm.state.draft.schedule.endsOn, '2026-11-05');
  });
  testWidgets('time pickers preserve selected start and end times', (
    tester,
  ) async {
    await open(tester);
    for (final start in [true, false]) {
      final button = find.byTooltip(
        start ? 'Escolher horário de início' : 'Escolher horário de término',
      );
      await visible(tester, button);
      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(find.byType(TimePickerDialog), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
    }
    expect(vm.state.draft.schedule.startsTime, '08:00');
    expect(vm.state.draft.schedule.endsTime, '20:00');
  });
  testWidgets(
    'fixed time entries can be added, changed and removed through the form',
    (tester) async {
      await open(tester);
      await visible(tester, find.text('+ Horário'));
      await tester.tap(find.text('+ Horário'));
      await tester.pumpAndSettle();
      final field = find.byKey(
        ValueKey('medicationTime${vm.state.formVersion}-2'),
      );
      await visible(tester, field);
      await tester.enterText(field, '12:30');
      await tester.pump();
      expect(vm.state.draft.schedule.fixedTimes.last, '12:30');
      await tester.tap(find.byTooltip('Remover horário 3'));
      await tester.pumpAndSettle();
      expect(vm.state.draft.schedule.fixedTimes.length, 2);
    },
  );
  testWidgets(
    'interval units and amount are submitted from the displayed controls',
    (tester) async {
      await open(tester);
      await visible(tester, find.text('Por intervalo'));
      await tester.tap(find.text('Por intervalo'));
      await tester.pumpAndSettle();
      final dropdown = find.byType(DropdownButtonFormField<bool>);
      await visible(tester, dropdown);
      await tester.tap(dropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Minutos').last);
      await tester.pumpAndSettle();
      final input = find.descendant(
        of: find.byKey(const ValueKey('medicationInterval')),
        matching: find.byType(TextFormField),
      );
      await tester.enterText(input, '30');
      await tester.pump();
      expect(vm.state.draft.schedule.intervalMinutes, 30);
      expect(vm.state.intervalInHours, isFalse);
    },
  );
  testWidgets(
    'uncertain save can be confirmed from the footer without resubmitting',
    (tester) async {
      await open(tester);
      String? key;
      repo.handler = (method, args) async {
        if (method == 'saveTreatment') {
          key = args.last as String;
          return Failure<MedicationCommandResult>(
            AppFailure(FailureCode.timeout),
          );
        }
        return Success<MedicationCommandResult?>(
          MedicationCommandResult(
            operationKey: key!,
            serverNow: DateTime.utc(2026),
            treatment: const MedicationTreatment(
              id: medicationTreatmentId,
              animalId: medicationAnimalId,
              revision: 1,
              version: 1,
              medicationName: 'Teste',
              schedule: MedicationSchedule(
                startsOn: '2026-11-01',
                endsOn: '2026-11-04',
              ),
            ),
          ),
        );
      };
      await tester.tap(find.text('Salvar programação'));
      await tester.pumpAndSettle();
      expect(vm.state.uncertain, isTrue);
      await tester.tap(find.text('Verificar resultado'));
      await tester.pumpAndSettle();
      expect(repo.calls.where((c) => c.method == 'saveTreatment').length, 1);
      expect(vm.state.uncertain, isFalse);
    },
  );
  testWidgets('failed list offers reload rather than an empty success', (
    tester,
  ) async {
    repo.handler = (_, _) async =>
        Failure<MedicationTreatmentPage>(AppFailure(FailureCode.network));
    await vm.bindAnimal(medicationAnimalId, 'Luna');
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: MedicationEditorPanel(viewModel: vm),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Tentar carregar medicações'), findsOneWidget);
    repo.handler = (_, _) async => const Success(MedicationTreatmentPage());
    await tester.tap(find.text('Tentar carregar medicações'));
    await tester.pumpAndSettle();
    expect(vm.state.loadFailed, isFalse);
  });
}
