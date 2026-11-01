import 'dart:async';
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

void fill(MedicationEditorViewModel vm) {
  vm.startCreate();
  vm.setName('Medicação de teste');
  vm.setStartDate('01/11/2026');
  vm.setEndDate('02/11/2026');
}

void main() {
  const treatment = MedicationTreatment(
    id: medicationTreatmentId,
    animalId: medicationAnimalId,
    revision: 1,
    version: 1,
    medicationName: 'Medicação de teste',
    schedule: MedicationSchedule(startsOn: '2026-11-01', endsOn: '2026-11-02'),
  );
  test(
    'persisted interval units and civil picker values remain consistent',
    () async {
      final repository = FakeMedicationsRepository()
        ..handler = (_, _) async => const Success(MedicationTreatmentPage());
      final vm = MedicationEditorViewModel(repository);
      addTearDown(vm.dispose);
      await vm.bindAnimal(medicationAnimalId, 'Atena');
      vm.beginEdit(
        treatment.copyWith(
          schedule: treatment.schedule.copyWith(
            mode: MedicationScheduleMode.interval,
            fixedTimes: [],
            intervalMinutes: 30,
          ),
        ),
      );
      expect(vm.state.intervalInHours, false);
      expect(vm.state.intervalInput, '30');
      vm.setMode(MedicationScheduleMode.interval);
      expect(vm.state.draft.schedule.intervalMinutes, 30);
      vm.setMode(MedicationScheduleMode.fixedTimes);
      vm.setMode(MedicationScheduleMode.interval);
      expect(vm.state.intervalInput, '8');
      expect(vm.state.intervalInHours, true);
      vm.setIntervalUnit(false);
      expect(vm.state.draft.schedule.intervalMinutes, 8);
      vm.setPickedDate(true, DateTime(2026, 11, 1));
      vm.setPickedTime(null, true, 9, 30);
      expect(vm.startDateText, '01/11/2026');
      expect(vm.state.draft.schedule.startsTime, '09:30');
      expect(vm.pickerTime('invalid'), (hour: 8, minute: 0));
      expect(vm.pickerTime('09:30'), (hour: 9, minute: 30));
    },
  );
  test(
    'same-user epoch change keeps uncertain submission for explicit reconciliation',
    () async {
      var epoch = 0;
      String? key;
      final pending = Completer<Result<MedicationCommandResult>>();
      final repository = FakeMedicationsRepository()
        ..handler = (method, args) async {
          if (method == 'listTreatments') {
            return const Success(MedicationTreatmentPage());
          }
          if (method == 'saveTreatment') {
            key = args.last as String;
            return pending.future;
          }
          return Success<MedicationCommandResult?>(
            MedicationCommandResult(
              operationKey: key!,
              serverNow: DateTime.utc(2026, 11, 1),
              treatment: treatment,
            ),
          );
        };
      final vm = MedicationEditorViewModel(
        repository,
        accessEpoch: () => epoch,
      );
      addTearDown(vm.dispose);
      await vm.bindAnimal(medicationAnimalId, 'Luna');
      fill(vm);
      final save = vm.save();
      await Future<void>.delayed(Duration.zero);
      epoch++;
      pending.complete(
        Success(
          MedicationCommandResult(
            operationKey: key!,
            serverNow: DateTime.utc(2026, 11, 1),
            treatment: treatment,
          ),
        ),
      );
      expect(await save, false);
      expect(vm.state.uncertain, true);
      expect(vm.state.confirmedTreatmentId, isNull);
      expect(await vm.reconcile(), true);
      expect(vm.state.confirmedTreatmentId, medicationTreatmentId);
    },
  );
  test(
    'loading can be retried after authorization failure without exposing raw errors',
    () async {
      var allowed = false;
      final repository = FakeMedicationsRepository()
        ..handler = (_, _) async => const Success(MedicationTreatmentPage());
      final vm = MedicationEditorViewModel(
        repository,
        authorize: () async => allowed,
      );
      addTearDown(vm.dispose);
      await vm.bindAnimal(medicationAnimalId, 'Luna');
      expect(vm.state.loadFailed, true);
      expect(repository.calls, isEmpty);
      allowed = true;
      await vm.load();
      expect(vm.state.loadFailed, false);
      fill(vm);
      repository.handler = (_, _) async => throw StateError('private stack');
      expect(await vm.save(), false);
      expect(vm.state.uncertain, true);
      expect(vm.state.message, isNot(contains('private')));
    },
  );
  test(
    'pagination merges stable IDs and reports repeated cursor without losing rows',
    () async {
      final repository = FakeMedicationsRepository()
        ..handler = (_, _) async => const Success(
          MedicationTreatmentPage(items: [treatment], cursor: 'next'),
        );
      final vm = MedicationEditorViewModel(repository);
      addTearDown(vm.dispose);
      await vm.bindAnimal(medicationAnimalId, 'Luna');
      expect(vm.canLoadMore, true);
      await vm.load(more: true);
      expect(vm.state.treatments, hasLength(1));
      expect(vm.state.message, isNotNull);
      expect(vm.state.loading, false);
      repository.handler = (_, _) async => Success(
        MedicationTreatmentPage(
          items: [
            treatment.copyWith(
              id: '87000000-0000-4000-8000-000000000002',
              medicationName: 'Outro',
            ),
          ],
          cursor: null,
        ),
      );
      await vm.load(more: true);
      expect(vm.state.treatments, hasLength(2));
      expect(vm.canLoadMore, false);
    },
  );
  test(
    'edit respects animal/status and confirmed stop preserves server treatment identity',
    () async {
      final repository = FakeMedicationsRepository()
        ..handler = (method, args) async => method == 'listTreatments'
            ? const Success(MedicationTreatmentPage(items: [treatment]))
            : Success(
                MedicationCommandResult(
                  operationKey: args.last as String,
                  serverNow: DateTime.utc(2026, 11, 1),
                  treatment: treatment.copyWith(
                    status: MedicationTreatmentStatus.stopped,
                    version: 2,
                  ),
                ),
              );
      final vm = MedicationEditorViewModel(repository);
      addTearDown(vm.dispose);
      await vm.bindAnimal(medicationAnimalId, 'Luna');
      vm.beginEdit(
        treatment.copyWith(animalId: '77000000-0000-4000-8000-000000000002'),
      );
      expect(vm.state.hasDraft, false);
      vm.beginEdit(
        treatment.copyWith(status: MedicationTreatmentStatus.stopped),
      );
      expect(vm.state.hasDraft, false);
      vm.beginEdit(treatment);
      expect(vm.state.draft.expectedVersion, 1);
      vm.cancelDraft();
      expect(vm.state.hasDraft, false);
      expect(await vm.stop(treatment), true);
      expect(
        vm.state.treatments.single.status,
        MedicationTreatmentStatus.stopped,
      );
    },
  );
  test(
    'unsaved animal cannot create treatment; invalid draft never writes',
    () async {
      final repository = FakeMedicationsRepository()
        ..handler = (_, _) async => const Success(MedicationTreatmentPage());
      final vm = MedicationEditorViewModel(repository);
      addTearDown(vm.dispose);
      vm.startCreate();
      expect(vm.state.hasDraft, false);
      await vm.bindAnimal(medicationAnimalId, 'Luna');
      vm.startCreate();
      await vm.save();
      expect(
        vm.state.errors.keys,
        containsAll(['medicationName', 'startsOn', 'endsOn']),
      );
      expect(
        repository.calls.every((call) => call.method == 'listTreatments'),
        true,
      );
      vm.setStartDate('31/02/2026');
      expect(vm.startDateText, '31/02/2026');
    },
  );
  test(
    'save confirms treatment and binding the same animal preserves a draft',
    () async {
      final repository = FakeMedicationsRepository()
        ..handler = (method, args) async => method == 'listTreatments'
            ? const Success(MedicationTreatmentPage())
            : Success(
                MedicationCommandResult(
                  operationKey: args.last as String,
                  serverNow: DateTime.utc(2026, 11, 1),
                  treatment: treatment,
                ),
              );
      final vm = MedicationEditorViewModel(repository);
      addTearDown(vm.dispose);
      await vm.bindAnimal(medicationAnimalId, 'Luna');
      fill(vm);
      await vm.bindAnimal(medicationAnimalId, 'Luna atualizada');
      expect(vm.state.draft.medicationName, 'Medicação de teste');
      expect(vm.state.animalName, 'Luna atualizada');
      expect(await vm.save(), true);
      expect(vm.state.treatments.single.id, medicationTreatmentId);
      expect(vm.state.confirmedTreatmentId, medicationTreatmentId);
    },
  );
  test(
    'timeout reconciles the same key and payload, never generates a second submission',
    () async {
      String? key;
      var saves = 0;
      final repository = FakeMedicationsRepository()
        ..handler = (method, args) async {
          if (method == 'listTreatments') {
            return const Success(MedicationTreatmentPage());
          }
          if (method == 'saveTreatment') {
            saves++;
            key = args.last as String;
            return Failure<MedicationCommandResult>(
              AppFailure(FailureCode.timeout),
            );
          }
          return Success<MedicationCommandResult?>(
            MedicationCommandResult(
              operationKey: args.first as String,
              serverNow: DateTime.utc(2026, 11, 1),
              treatment: treatment,
            ),
          );
        };
      final vm = MedicationEditorViewModel(repository);
      addTearDown(vm.dispose);
      await vm.bindAnimal(medicationAnimalId, 'Luna');
      fill(vm);
      expect(await vm.save(), false);
      expect(vm.state.uncertain, true);
      vm.setName('Não deve mudar');
      expect(vm.state.draft.medicationName, 'Medicação de teste');
      expect(await vm.reconcile(), true);
      expect(saves, 1);
      expect(repository.calls.last.arguments, [key]);
    },
  );
  test(
    'missing receipt allows only a same-key retry and denied access preserves the draft',
    () async {
      var allowed = true;
      var saves = 0;
      final keys = <String>[];
      final repository = FakeMedicationsRepository()
        ..handler = (method, args) async {
          if (method == 'listTreatments') {
            return const Success(MedicationTreatmentPage());
          }
          if (method == 'getOperation') {
            return const Success<MedicationCommandResult?>(null);
          }
          keys.add(args.last as String);
          if (saves++ == 0) {
            return Failure<MedicationCommandResult>(
              AppFailure(FailureCode.network),
            );
          }
          return Success(
            MedicationCommandResult(
              operationKey: args.last as String,
              serverNow: DateTime.utc(2026, 11, 1),
              treatment: treatment,
            ),
          );
        };
      final vm = MedicationEditorViewModel(
        repository,
        isAuthorized: () => allowed,
      );
      addTearDown(vm.dispose);
      await vm.bindAnimal(medicationAnimalId, 'Luna');
      fill(vm);
      await vm.save();
      await vm.reconcile();
      expect(vm.state.canRetryPending, true);
      allowed = false;
      expect(await vm.retryPending(), false);
      allowed = true;
      expect(await vm.retryPending(), true);
      expect(keys.toSet(), hasLength(1));
    },
  );
  test(
    'old response cannot overwrite another animal or a disposed ViewModel',
    () async {
      final pending = Completer<Result<MedicationTreatmentPage>>();
      final repository = FakeMedicationsRepository()
        ..handler = (_, args) async => args.first == medicationAnimalId
            ? pending.future
            : const Success(MedicationTreatmentPage());
      final vm = MedicationEditorViewModel(repository);
      final first = vm.bindAnimal(medicationAnimalId, 'Luna');
      await Future<void>.delayed(Duration.zero);
      await vm.bindAnimal('77000000-0000-4000-8000-000000000002', 'Thor');
      pending.complete(
        const Success(MedicationTreatmentPage(items: [treatment])),
      );
      await first;
      expect(vm.state.animalName, 'Thor');
      expect(vm.state.treatments, isEmpty);
      vm.dispose();
      expect(vm.state.animalId, isNull);
    },
  );
  test(
    'both modes enforce exclusive fields and generation changes discard private state',
    () async {
      var generation = 0;
      final repository = FakeMedicationsRepository()
        ..handler = (_, _) async => const Success(MedicationTreatmentPage());
      final vm = MedicationEditorViewModel(
        repository,
        privateGeneration: () => generation,
      );
      addTearDown(vm.dispose);
      await vm.bindAnimal(medicationAnimalId, 'Luna');
      fill(vm);
      vm.setMode(MedicationScheduleMode.interval);
      vm.setInterval('8', hours: true);
      expect(vm.state.draft.schedule.fixedTimes, isEmpty);
      expect(vm.state.draft.schedule.intervalMinutes, 480);
      vm.setMode(MedicationScheduleMode.fixedTimes);
      expect(vm.state.draft.schedule.intervalMinutes, isNull);
      generation++;
      vm.refreshAccess();
      expect(vm.state.animalId, isNull);
      expect(vm.state.treatments, isEmpty);
      expect(vm.state.draft.medicationName, isEmpty);
    },
  );
  test(
    'edit sends confirmed versions and conflict preserves draft without false success',
    () async {
      final repo = FakeMedicationsRepository()
        ..handler = (method, args) async => method == 'listTreatments'
            ? const Success(MedicationTreatmentPage(items: [treatment]))
            : Failure<MedicationCommandResult>(
                AppFailure(FailureCode.conflict),
              );
      final vm = MedicationEditorViewModel(repo);
      addTearDown(vm.dispose);
      await vm.bindAnimal(medicationAnimalId, 'Atena');
      vm.beginEdit(treatment);
      vm.setName('Novo nome');
      expect(await vm.save(), false);
      expect(vm.state.draft.expectedRevision, 1);
      expect(vm.state.draft.expectedVersion, 1);
      expect(vm.state.draft.medicationName, 'Novo nome');
      expect(vm.state.treatments.single, treatment);
      expect(vm.state.message, contains('mudou'));
      expect(vm.state.uncertain, false);
    },
  );
  test(
    'stop timeout reconciles same treatment/version/key and cannot edit stopped record',
    () async {
      String? key;
      final stopped = treatment.copyWith(
        status: MedicationTreatmentStatus.stopped,
        version: 2,
      );
      final repo = FakeMedicationsRepository()
        ..handler = (method, args) async {
          if (method == 'listTreatments') {
            return const Success(MedicationTreatmentPage(items: [treatment]));
          }
          if (method == 'stopTreatment') {
            expect(args.first, treatment);
            key = args.last as String;
            return Failure<MedicationCommandResult>(
              AppFailure(FailureCode.timeout),
            );
          }
          return Success<MedicationCommandResult?>(
            MedicationCommandResult(
              operationKey: key!,
              serverNow: DateTime.utc(2026, 11, 1),
              treatment: stopped,
            ),
          );
        };
      final vm = MedicationEditorViewModel(repo);
      addTearDown(vm.dispose);
      await vm.bindAnimal(medicationAnimalId, 'Atena');
      expect(await vm.stop(treatment), false);
      expect(vm.canLeave, false);
      expect(
        vm.state.treatments.single.status,
        MedicationTreatmentStatus.active,
      );
      expect(await vm.reconcile(), true);
      expect(vm.state.treatments.single, stopped);
      expect(vm.canModify(stopped), false);
      expect(vm.state.message, contains('atrasadas'));
      expect(repo.calls.last.arguments.single, key);
    },
  );
}
