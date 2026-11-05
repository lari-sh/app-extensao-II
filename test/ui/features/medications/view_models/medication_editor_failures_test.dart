import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/ui/features/medications/view_models/medication_editor_view_model.dart';
import 'package:abrigo_dos_anjos/domain/models/medication_treatment.dart';
import 'package:abrigo_dos_anjos/domain/models/medication_schedule.dart';
import 'package:abrigo_dos_anjos/domain/models/medication_agenda.dart';
import 'package:abrigo_dos_anjos/domain/models/medication_application.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import 'package:abrigo_dos_anjos/utils/app_failure.dart';
import '../../../../support/fakes/fake_medications_repository.dart';
import '../../../../support/medication_fixtures.dart';

const treatment = MedicationTreatment(
  id: medicationTreatmentId,
  animalId: medicationAnimalId,
  revision: 1,
  version: 1,
  medicationName: 'Teste',
  schedule: MedicationSchedule(startsOn: '2026-11-01', endsOn: '2026-11-02'),
);
void main() {
  late FakeMedicationsRepository repo;
  late MedicationEditorViewModel vm;
  setUp(() {
    repo = FakeMedicationsRepository()
      ..handler = (_, _) async => const Success(MedicationTreatmentPage());
    vm = MedicationEditorViewModel(repo);
  });
  tearDown(() => vm.dispose());
  Future<void> draft() async {
    await vm.bindAnimal(medicationAnimalId, 'Luna');
    vm.startCreate();
    vm.setName('Teste');
    vm.setStartDate('01/11/2026');
    vm.setEndDate('02/11/2026');
  }

  test(
    'fixed schedule editor adds, updates and removes times while keeping instructions',
    () async {
      await draft();
      vm.setInstructions('Com alimento');
      vm.addTime();
      vm.setPickedTime(2, true, 12, 30);
      expect(vm.state.draft.schedule.fixedTimes.last, '12:30');
      vm.removeTime(2);
      vm.removeTime(-1);
      vm.setTime(100, '09:00');
      expect(vm.state.draft.schedule.fixedTimes, ['08:00', '20:00']);
      expect(vm.state.draft.instructions, 'Com alimento');
      vm.setPickedDate(false, DateTime(2026, 11, 3));
      vm.setPickedTime(null, false, 21, 15);
      expect(vm.pickerDate(false), DateTime(2026, 11, 3));
      expect(vm.firstPickerDate, DateTime(2000));
      expect(vm.lastPickerDate, DateTime(2100, 12, 31));
      expect(vm.state.draft.schedule.endsTime, '21:15');
    },
  );
  for (final mode in ['time', 'period', 'duplicate', 'interval']) {
    test(
      'invalid $mode schedule blocks persistence with field-specific feedback',
      () async {
        await draft();
        switch (mode) {
          case 'time':
            vm.setStartTime('25:70');
          case 'period':
            vm.setEndDate('31/10/2026');
          case 'duplicate':
            vm.setTime(1, '08:00');
          case 'interval':
            vm.setMode(MedicationScheduleMode.interval);
            vm.setInterval('0', hours: false);
        }
        expect(await vm.save(), isFalse);
        expect(vm.state.errors, isNotEmpty);
        expect(repo.calls.where((c) => c.method == 'saveTreatment'), isEmpty);
      },
    );
  }
  test(
    'opening paginated treatment searches next page and hydrates interval units',
    () async {
      repo.handler = (_, args) async => args[1] == null
          ? const Success(MedicationTreatmentPage(cursor: 'next'))
          : Success(
              MedicationTreatmentPage(
                items: [
                  treatment.copyWith(
                    schedule: treatment.schedule.copyWith(
                      mode: MedicationScheduleMode.interval,
                      fixedTimes: [],
                      intervalMinutes: 120,
                    ),
                  ),
                ],
              ),
            );
      await vm.bindAnimal(medicationAnimalId, 'Luna');
      await vm.openTreatment(medicationTreatmentId);
      expect(repo.calls.last.arguments.last, 'next');
      expect(vm.state.hasDraft, isTrue);
      expect(vm.state.intervalInput, '2');
      expect(vm.scheduleLabel(vm.state.treatments.single), contains('2 h'));
    },
  );
  test(
    'unknown treatment stops searching if cursor does not advance',
    () async {
      repo.handler = (_, _) async =>
          const Success(MedicationTreatmentPage(cursor: 'same'));
      await vm.bindAnimal(medicationAnimalId, 'Luna');
      await vm.openTreatment(medicationTreatmentId);
      expect(repo.calls.length, 2);
      expect(vm.state.message, contains('não encontrado'));
    },
  );
  test(
    'list failure marks failed load and permits a later successful refresh',
    () async {
      repo.handler = (_, _) async =>
          Failure<MedicationTreatmentPage>(AppFailure(FailureCode.network));
      await vm.bindAnimal(medicationAnimalId, 'Luna');
      expect(vm.state.loadFailed, isTrue);
      repo.handler = (_, _) async =>
          const Success(MedicationTreatmentPage(items: [treatment]));
      await vm.load();
      expect(vm.state.loadFailed, isFalse);
      expect(vm.state.treatments, [treatment]);
    },
  );
  test(
    'mismatched confirmation cannot report success or replace the draft',
    () async {
      await draft();
      repo.handler = (_, args) async => Success(
        MedicationCommandResult(
          operationKey: 'wrong-key',
          serverNow: DateTime.utc(2026),
          treatment: treatment,
        ),
      );
      expect(await vm.save(), isFalse);
      expect(vm.state.uncertain, isTrue);
      expect(vm.state.hasDraft, isTrue);
      expect(vm.state.confirmedTreatmentId, isNull);
    },
  );
  for (final throwsException in [false, true]) {
    test(
      'reconciliation ${throwsException ? 'exception' : 'failure'} keeps original uncertain command',
      () async {
        await draft();
        repo.handler = (_, _) async =>
            Failure<MedicationCommandResult>(AppFailure(FailureCode.timeout));
        await vm.save();
        expect(vm.canReconcile, isTrue);
        repo.handler = (_, _) async {
          if (throwsException) throw StateError('private');
          return Failure<MedicationCommandResult?>(
            AppFailure(FailureCode.network),
          );
        };
        expect(await vm.reconcile(), isFalse);
        expect(vm.state.uncertain, isTrue);
        expect(vm.state.saving, isFalse);
        expect(vm.state.message, isNot(contains('private')));
      },
    );
  }
  test(
    'save rechecks authorization and preserves the draft after denial',
    () async {
      var allowed = true, checks = 0;
      final model = MedicationEditorViewModel(
        repo,
        authorize: () async {
          checks++;
          return allowed;
        },
      );
      addTearDown(model.dispose);
      await model.bindAnimal(medicationAnimalId, 'Luna');
      model.startCreate();
      model.setName('Teste');
      model.setStartDate('01/11/2026');
      model.setEndDate('02/11/2026');
      allowed = false;
      expect(await model.save(), isFalse);
      expect(model.state.hasDraft, isTrue);
      expect(repo.calls.where((c) => c.method == 'saveTreatment'), isEmpty);
      expect(checks, greaterThan(2));
    },
  );
}
