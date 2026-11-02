import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/domain/models/medication_agenda.dart';
import 'package:abrigo_dos_anjos/domain/models/medication_application.dart';
import 'package:abrigo_dos_anjos/domain/models/medication_treatment.dart';
import 'package:abrigo_dos_anjos/domain/models/medication_schedule.dart';
import 'package:abrigo_dos_anjos/ui/features/medications/view_models/medication_application_view_model.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import 'package:abrigo_dos_anjos/utils/app_failure.dart';
import '../../../../support/fakes/fake_medication_completion_scenario.dart';
import '../../../../support/medication_fixtures.dart';
import '../../../../support/medication_completion_fixtures.dart';

void main() {
  for (final mode in ['fixed', 'hours', 'minutes', 'revision']) {
    test(
      'application details derive $mode schedule from matching treatment',
      () async {
        final scenario = FakeMedicationCompletionScenario();
        final normal = scenario.repository.handler!;
        scenario.repository.handler = (method, args) async =>
            method == 'listTreatments'
            ? Success(
                MedicationTreatmentPage(
                  items: [
                    MedicationTreatment(
                      id: medicationTreatmentId,
                      animalId: medicationAnimalId,
                      revision: mode == 'revision' ? 2 : 1,
                      version: 1,
                      medicationName: 'Teste',
                      schedule: MedicationSchedule(
                        mode: mode == 'fixed'
                            ? MedicationScheduleMode.fixedTimes
                            : MedicationScheduleMode.interval,
                        fixedTimes: mode == 'fixed' ? ['08:00'] : [],
                        intervalMinutes: mode == 'minutes' ? 30 : 120,
                      ),
                    ),
                  ],
                ),
              )
            : await normal(method, args);
        final vm = MedicationApplicationViewModel(scenario.repository);
        addTearDown(vm.dispose);
        await vm.open(medicationApplicationId);
        expect(
          vm.state.scheduleLabel,
          contains(switch (mode) {
            'fixed' => '08:00',
            'hours' => '2 horas',
            'minutes' => '30 minutos',
            _ => 'Revisão 1',
          }),
        );
      },
    );
  }
  for (final target in ['loadDay', 'listTreatments']) {
    test('$target failure blocks incomplete clinical details', () async {
      final scenario = FakeMedicationCompletionScenario();
      final normal = scenario.repository.handler!;
      scenario.repository.handler = (method, args) async {
        if (method == target) {
          return target == 'loadDay'
              ? Failure<MedicationDayPage>(AppFailure(FailureCode.network))
              : Failure<MedicationTreatmentPage>(
                  AppFailure(FailureCode.network),
                );
        }
        return await normal(method, args);
      };
      final vm = MedicationApplicationViewModel(scenario.repository);
      addTearDown(vm.dispose);
      await vm.open(medicationApplicationId);
      expect(vm.state.loadFailed, isTrue);
      expect(vm.canComplete, isFalse);
    });
  }
  test('cyclic treatment cursor is rejected instead of looping', () async {
    final scenario = FakeMedicationCompletionScenario();
    final normal = scenario.repository.handler!;
    scenario.repository.handler = (method, args) async =>
        method == 'listTreatments'
        ? const Success(MedicationTreatmentPage(cursor: 'same'))
        : await normal(method, args);
    final vm = MedicationApplicationViewModel(scenario.repository);
    addTearDown(vm.dispose);
    await vm.open(medicationApplicationId);
    expect(vm.state.loadFailed, isTrue);
    expect(
      scenario.repository.calls
          .where((c) => c.method == 'listTreatments')
          .length,
      2,
    );
  });
  test('unexpected history error is sanitized', () async {
    final scenario = FakeMedicationCompletionScenario();
    scenario.repository.handler = (_, _) async => throw StateError('private');
    final vm = MedicationApplicationViewModel(scenario.repository);
    addTearDown(vm.dispose);
    await vm.open(medicationApplicationId);
    expect(vm.state.loadFailed, isTrue);
    expect(vm.state.message, isNot(contains('private')));
  });
  test(
    'forged completion receipt cannot display completed application',
    () async {
      final scenario = FakeMedicationCompletionScenario();
      final normal = scenario.repository.handler!;
      scenario.repository.handler = (method, args) async =>
          method == 'completeApplication'
          ? Success(completedMedication('wrong-operation'))
          : await normal(method, args);
      final vm = MedicationApplicationViewModel(scenario.repository);
      addTearDown(vm.dispose);
      await vm.open(medicationApplicationId);
      expect(await vm.complete(), isFalse);
      expect(vm.state.uncertain, isTrue);
      expect(vm.state.application!.state, MedicationApplicationState.pending);
    },
  );
  for (final throwsException in [true, false]) {
    test(
      'failed receipt reconciliation ($throwsException) preserves uncertain completion',
      () async {
        final scenario = FakeMedicationCompletionScenario(
          failure: FailureCode.timeout,
        );
        final normal = scenario.repository.handler!;
        final vm = MedicationApplicationViewModel(scenario.repository);
        addTearDown(vm.dispose);
        await vm.open(medicationApplicationId);
        await vm.complete();
        scenario.repository.handler = (method, args) async {
          if (method == 'getOperation') {
            if (throwsException) throw StateError('private');
            return Failure<MedicationCommandResult?>(
              AppFailure(FailureCode.network),
            );
          }
          return await normal(method, args);
        };
        expect(await vm.reconcile(), isFalse);
        expect(vm.state.uncertain, isTrue);
        expect(vm.state.busy, isFalse);
        expect(vm.state.message, isNot(contains('private')));
      },
    );
  }
}
