import 'dart:async';
import 'package:abrigo_dos_anjos/domain/models/animal_draft.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/ui/features/animals/view_models/animal_editor_view_model.dart';
import 'package:abrigo_dos_anjos/domain/models/animal.dart';
import 'package:abrigo_dos_anjos/domain/models/clinical_record.dart';
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
    'editor loads and saves confirmed public fields while preserving notes',
    () async {
      final confirmed = fixtureAnimal(1).copyWith(
        lastDewormedOn: '2024-02-29',
        temperament: 'Calma',
        color: 'Branca',
        weightKg: 4.25,
        vaccinations: [
          const PublicVaccination(appliedOn: '2024-02-29', vaccineType: 'V4'),
        ],
      );
      final repository = FakeAnimalsRepository()
        ..handler = (_, _) async =>
            Success(ManagedAnimal(animal: confirmed, clinicalNotes: 'Interna'));
      final vm = AnimalEditorViewModel(repository);
      addTearDown(vm.dispose);
      await vm.load(confirmed.id);
      expect(vm.dewormingDateText, '29/02/2024');
      expect(vm.state.draft.vaccinations.single.vaccineType, 'V4');
      vm.setTemperament('Sociável');
      await vm.save();
      final draft = repository.calls.last.arguments.first as AnimalDraft;
      expect(draft.temperament, 'Sociável');
      expect(draft.clinicalNotes, 'Interna');
      expect(vm.state.savedId, confirmed.id);
      expect(vm.state.message, 'Animal salvo com sucesso.');
    },
  );
  test(
    'public editor rejects invalid input, preserves draft and clears optional values',
    () async {
      final vm = AnimalEditorViewModel(
        FakeAnimalsRepository(),
        now: () => DateTime.utc(2026, 10, 31, 12),
      );
      addTearDown(vm.dispose);
      fill(vm);
      vm.setLastDewormedOn('31/02/2024');
      vm.setWeight('abc');
      vm.addVaccination();
      vm.setVaccinationDate(0, '01/11/2026');
      vm.setVaccineType(0, 'V4');
      await vm.save();
      expect(
        vm.state.errors.keys,
        containsAll(['lastDewormedOn', 'weightKg', 'vaccinations.0.appliedOn']),
      );
      expect(vm.dewormingDateText, '31/02/2024');
      vm.setLastDewormedOn('29/02/2024');
      vm.setVaccinationDate(0, '29/02/2024');
      vm.setWeight('4,25');
      vm.setColor('Branca');
      vm.setTemperament('Calma');
      expect(
        vm.state.draft.validate(now: DateTime.utc(2026, 10, 31, 12)),
        isEmpty,
      );
      expect(vm.state.draft.lastDewormedOn, '2024-02-29');
      vm.setLastDewormedOn('');
      vm.setWeight('');
      vm.removeVaccination(0);
      expect(vm.state.draft.lastDewormedOn, isNull);
      expect(vm.state.draft.weightKg, isNull);
      expect(vm.state.draft.vaccinations, isEmpty);
    },
  );
  test(
    'denied reconciliation keeps uncertain operation and failed load can be retried',
    () async {
      final repository = FakeAnimalsRepository()
        ..handler = (method, _) async => method == 'getOperation'
            ? Failure<ManagedAnimal?>(AppFailure(FailureCode.forbidden))
            : Failure<ManagedAnimal>(AppFailure(FailureCode.timeout));
      final vm = AnimalEditorViewModel(repository);
      addTearDown(vm.dispose);
      fill(vm);
      await vm.save();
      await vm.reconcile();
      expect(vm.state.uncertain, isTrue);
      expect(vm.canEdit, isFalse);
      expect(vm.state.saving, isFalse);
      final edit = AnimalEditorViewModel(repository);
      addTearDown(edit.dispose);
      await edit.load(fixtureId(1));
      expect(edit.state.loadFailed, isTrue);
      expect(edit.state.draft.id, fixtureId(1));
      repository.handler = (_, _) async =>
          Success(ManagedAnimal(animal: fixtureAnimal(1)));
      await edit.retryLoad();
      expect(edit.state.loadFailed, isFalse);
      expect(edit.state.formVersion, 1);
      expect(edit.state.draft.name, 'Luna 1');
    },
  );
  test(
    'reconciliation with no result allows safe retry using original payload and key',
    () async {
      var saves = 0;
      final repository = FakeAnimalsRepository()
        ..handler = (method, _) async {
          if (method == 'getOperation') {
            return const Success<ManagedAnimal?>(null);
          }
          if (saves++ == 0) {
            return Failure<ManagedAnimal>(AppFailure(FailureCode.network));
          }
          return Success(ManagedAnimal(animal: fixtureAnimal(1)));
        };
      final vm = AnimalEditorViewModel(repository);
      addTearDown(vm.dispose);
      fill(vm);
      await vm.save();
      await vm.reconcile();
      expect(vm.state.canRetryPending, isTrue);
      await vm.retryPending();
      expect(vm.state.savedId, fixtureId(1));
      expect(
        repository.calls.first.arguments.last,
        repository.calls.last.arguments.last,
      );
      expect(
        repository.calls.first.arguments.first,
        repository.calls.last.arguments.first,
      );
    },
  );
  test(
    'failed edit load blocks accidental creation and definitive write denial ends loading',
    () async {
      var checks = 0;
      final repository = FakeAnimalsRepository()
        ..handler = (_, _) async =>
            Failure<ManagedAnimal>(AppFailure(FailureCode.forbidden));
      final vm = AnimalEditorViewModel(
        repository,
        authorize: () async {
          checks++;
          return true;
        },
      );
      addTearDown(vm.dispose);
      await vm.load(fixtureId(1));
      expect(vm.state.loadFailed, isTrue);
      expect(vm.canEdit, isFalse);
      expect(vm.state.loading, isFalse);
      await vm.save();
      expect(repository.calls.length, 1);
      expect(checks, 2);
      final fresh = AnimalEditorViewModel(
        repository,
        authorize: () async => true,
      );
      addTearDown(fresh.dispose);
      fill(fresh);
      await fresh.save();
      expect(fresh.state.saving, isFalse);
      expect(fresh.state.uncertain, isFalse);
      expect(fresh.state.message, contains('acesso'));
    },
  );
  test(
    'invalid boundaries and missing enums do not save; limits count Unicode characters',
    () async {
      final repository = FakeAnimalsRepository();
      final vm = AnimalEditorViewModel(repository);
      addTearDown(vm.dispose);
      await vm.save();
      expect(repository.calls, isEmpty);
      expect(
        vm.state.errors.keys,
        containsAll(['name', 'approximateAge', 'species', 'sex', 'size']),
      );
      fill(vm);
      for (final length in [0, 81]) {
        vm.setName('a' * length);
        await vm.save();
        expect(vm.state.errors, contains('name'));
      }
      vm.setName('🐾' * 80);
      vm.setAge('a' * 81);
      await vm.save();
      expect(vm.state.errors, contains('approximateAge'));
      expect(vm.state.errors.containsKey('name'), isFalse);
      vm.setAge('a');
      vm.setDescription('a' * 3001);
      vm.setNotes('a' * 3001);
      vm.addCare(ClinicalRecordKind.medication);
      await vm.save();
      expect(
        vm.state.errors.keys,
        containsAll([
          'publicDescription',
          'clinicalNotes',
          'careRecords.0.description',
        ]),
      );
      vm.setDescription('a' * 3000);
      vm.setNotes('a' * 3000);
      vm.setCareDescription(0, 'a' * 1001);
      await vm.save();
      expect(vm.state.errors, contains('careRecords.0.description'));
      vm.setCareDescription(0, 'a' * 1000);
      expect(vm.state.draft.validate(), isEmpty);
      vm.removeCare(0);
      expect(vm.state.draft.careRecords, isEmpty);
    },
  );
  test(
    'double click is blocked and success requires remote confirmation',
    () async {
      final complete = Completer<Result<ManagedAnimal>>();
      final repository = FakeAnimalsRepository()
        ..handler = (_, _) => complete.future;
      final vm = AnimalEditorViewModel(repository);
      addTearDown(vm.dispose);
      fill(vm);
      final work = vm.save();
      await Future<void>.delayed(Duration.zero);
      await vm.save();
      expect(repository.calls.length, 1);
      expect(vm.state.savedId, isNull);
      complete.complete(Success(ManagedAnimal(animal: fixtureAnimal(1))));
      await work;
      expect(vm.state.savedId, fixtureId(1));
      expect(vm.state.saving, isFalse);
    },
  );
  test(
    'timeout retains key, draft and reconciles without duplicate save',
    () async {
      final repository = FakeAnimalsRepository()
        ..handler = (method, _) async => method == 'saveAnimal'
            ? Failure<ManagedAnimal>(AppFailure(FailureCode.timeout))
            : Success<ManagedAnimal?>(ManagedAnimal(animal: fixtureAnimal(1)));
      final vm = AnimalEditorViewModel(repository);
      addTearDown(vm.dispose);
      fill(vm);
      await vm.save();
      expect(vm.state.uncertain, isTrue);
      vm.setName('Alterado');
      expect(vm.state.draft.name, 'Luna');
      await vm.reconcile();
      expect(vm.state.savedId, fixtureId(1));
      expect(repository.calls.map((c) => c.method), [
        'saveAnimal',
        'getOperation',
      ]);
      expect(
        repository.calls[0].arguments.last,
        repository.calls[1].arguments.single,
      );
    },
  );
  test(
    'lost authorization blocks commands and stale private completion; disposal clears memory',
    () async {
      var authorized = true, epoch = 0;
      final complete = Completer<Result<ManagedAnimal>>();
      final repository = FakeAnimalsRepository()
        ..handler = (_, _) => complete.future;
      final vm = AnimalEditorViewModel(
        repository,
        isAuthorized: () => authorized,
        accessEpoch: () => epoch,
      );
      fill(vm);
      final work = vm.save();
      await Future<void>.delayed(Duration.zero);
      authorized = false;
      epoch++;
      vm.setNotes('hidden edit');
      expect(vm.state.draft.clinicalNotes, '');
      complete.complete(Success(ManagedAnimal(animal: fixtureAnimal(1))));
      await work;
      expect(vm.state.savedId, isNull);
      authorized = true;
      expect(vm.state.draft.name, 'Luna');
      vm.dispose();
      expect(vm.state.draft.name, '');
    },
  );
  for (final code in [
    FailureCode.network,
    FailureCode.timeout,
    FailureCode.configuration,
    FailureCode.notFound,
  ]) {
    test(
      'editor failure matrix ${code.name} preserves draft and settles flags',
      () async {
        final repo = FakeAnimalsRepository()
          ..handler = (_, _) async => Failure<ManagedAnimal>(AppFailure(code));
        final vm = AnimalEditorViewModel(repo);
        addTearDown(vm.dispose);
        fill(vm);
        vm.setNotes('Rascunho protegido');
        await vm.save();
        expect(vm.state.saving, false);
        expect(vm.state.draft.clinicalNotes, 'Rascunho protegido');
        expect(vm.state.message, isNotNull);
        if (vm.state.uncertain) {
          repo.handler = (_, _) async =>
              Failure<ManagedAnimal?>(AppFailure(code));
          final before = repo.calls.length;
          await vm.reconcile();
          expect(repo.calls.length, before + 1);
          expect(vm.state.canRetryPending, false);
        }
      },
    );
  }
}
