import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/domain/models/animal.dart';
import 'package:abrigo_dos_anjos/domain/models/clinical_record.dart';
import 'package:abrigo_dos_anjos/ui/features/animals/view_models/animal_editor_view_model.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import 'package:abrigo_dos_anjos/utils/app_failure.dart';
import '../../../../support/fakes/fake_animals_repository.dart';
import '../../../../support/public_fixtures.dart';

void fill(AnimalEditorViewModel vm) {
  vm.setName('Luna');
  vm.setAge('2 anos');
  vm.setSpecies(AnimalSpecies.dog);
  vm.setSex(AnimalSex.female);
  vm.setSize(AnimalSize.medium);
}

void main() {
  test(
    'public care flags and clinical record kind remain independent draft fields',
    () {
      final vm = AnimalEditorViewModel(FakeAnimalsRepository());
      addTearDown(vm.dispose);
      vm.setVaccinated(true);
      vm.setNeutered(true);
      vm.addCare(ClinicalRecordKind.medication);
      vm.setCareKind(0, ClinicalRecordKind.deworming);
      vm.setCareKind(20, ClinicalRecordKind.medication);
      vm.setCareKind(0, null);
      expect(vm.state.draft.isVaccinated, isTrue);
      expect(vm.state.draft.isNeutered, isTrue);
      expect(
        vm.state.draft.careRecords.single.kind,
        ClinicalRecordKind.deworming,
      );
    },
  );
  test('load denial performs no private read', () async {
    final repo = FakeAnimalsRepository();
    final vm = AnimalEditorViewModel(repo, authorize: () async => false);
    addTearDown(vm.dispose);
    await vm.load(fixtureId(1));
    expect(vm.state.loadFailed, isTrue);
    expect(repo.calls, isEmpty);
    expect(vm.state.loading, isFalse);
  });
  test(
    'stale load after epoch change requires reload instead of populating private fields',
    () async {
      var epoch = 0;
      final pending = Completer<Result<ManagedAnimal>>();
      final repo = FakeAnimalsRepository()..handler = (_, _) => pending.future;
      final vm = AnimalEditorViewModel(repo, accessEpoch: () => epoch);
      addTearDown(vm.dispose);
      final work = vm.load(fixtureId(1));
      await Future<void>.delayed(Duration.zero);
      epoch++;
      pending.complete(
        Success(
          ManagedAnimal(animal: fixtureAnimal(1), clinicalNotes: 'Private'),
        ),
      );
      await work;
      expect(vm.state.loadFailed, isTrue);
      expect(vm.state.draft.clinicalNotes, isEmpty);
    },
  );
  test(
    'unexpected load exception is sanitized and does not allow saving',
    () async {
      final repo = FakeAnimalsRepository()
        ..handler = (_, _) async => throw StateError('private');
      final vm = AnimalEditorViewModel(repo);
      addTearDown(vm.dispose);
      await vm.load(fixtureId(1));
      expect(vm.state.loadFailed, isTrue);
      expect(vm.state.message, isNot(contains('private')));
    },
  );
  test(
    'unexpected save keeps uncertain draft; next save only reconciles',
    () async {
      final repo = FakeAnimalsRepository()
        ..handler = (method, args) async {
          if (method == 'saveAnimal') throw StateError('private');
          return const Success<ManagedAnimal?>(null);
        };
      final vm = AnimalEditorViewModel(repo);
      addTearDown(vm.dispose);
      fill(vm);
      await vm.save();
      expect(vm.state.uncertain, isTrue);
      expect(vm.state.savedId, isNull);
      await vm.save();
      expect(repo.calls.where((c) => c.method == 'saveAnimal').length, 1);
      expect(repo.calls.last.method, 'getOperation');
      expect(vm.state.canRetryPending, isTrue);
    },
  );
  test(
    'reconciliation exception preserves uncertain write and clears spinner',
    () async {
      final repo = FakeAnimalsRepository()
        ..handler = (method, args) async {
          if (method == 'saveAnimal') {
            return Failure<ManagedAnimal>(AppFailure(FailureCode.timeout));
          }
          throw StateError('private');
        };
      final vm = AnimalEditorViewModel(repo);
      addTearDown(vm.dispose);
      fill(vm);
      await vm.save();
      await vm.reconcile();
      expect(vm.state.saving, isFalse);
      expect(vm.state.uncertain, isTrue);
      expect(vm.state.message, isNot(contains('private')));
    },
  );
}
