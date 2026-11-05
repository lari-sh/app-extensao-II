import 'package:flutter_test/flutter_test.dart';
import 'dart:async';
import 'package:abrigo_dos_anjos/utils/app_failure.dart';
import 'package:abrigo_dos_anjos/ui/features/animals/view_models/managed_animals_view_model.dart';
import 'package:abrigo_dos_anjos/domain/models/animal.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import '../../../../support/fakes/fake_animals_repository.dart';
import '../../../../support/public_fixtures.dart';

void main() {
  test(
    'paging preserves cursor, deduplicates and refresh resets the list',
    () async {
      final repository = FakeAnimalsRepository()
        ..handler = (_, args) async => Success(
          ManagedAnimalPage(
            items: [
              ManagedAnimal(animal: fixtureAnimal(args.last == null ? 1 : 2)),
            ],
            total: 2,
            cursor: args.last == null ? 'next' : null,
          ),
        );
      final vm = ManagedAnimalsViewModel(repository, isAuthorized: () => true);
      addTearDown(vm.dispose);
      await vm.load();
      await vm.load(more: true);
      expect(vm.state.items.length, 2);
      expect(repository.calls.last.arguments.last, 'next');
      await vm.load();
      expect(vm.state.items.length, 1);
    },
  );
  test(
    'denied access and transport failures end loading without private confirmation',
    () async {
      final repository = FakeAnimalsRepository()
        ..handler = (_, _) async =>
            Failure<ManagedAnimalPage>(AppFailure(FailureCode.forbidden));
      var checks = 0;
      final vm = ManagedAnimalsViewModel(
        repository,
        isAuthorized: () => true,
        authorize: () async {
          checks++;
          return true;
        },
      );
      addTearDown(vm.dispose);
      await vm.load();
      expect(vm.state.loading, isFalse);
      expect(vm.state.message, isNotNull);
      expect(checks, 2);
      repository.handler = (_, _) async => throw StateError('private');
      await vm.load();
      expect(vm.state.loading, isFalse);
      expect(vm.state.items, isEmpty);
      final denied = ManagedAnimalsViewModel(
        repository,
        isAuthorized: () => true,
        authorize: () async => false,
      );
      addTearDown(denied.dispose);
      final before = repository.calls.length;
      await denied.load();
      expect(repository.calls.length, before);
      expect(denied.state.loading, isFalse);
    },
  );
  test(
    'private result from an older access epoch is discarded and disposal clears data',
    () async {
      var epoch = 0;
      final pending = Completer<Result<ManagedAnimalPage>>();
      final repository = FakeAnimalsRepository()
        ..handler = (_, _) => pending.future;
      final vm = ManagedAnimalsViewModel(
        repository,
        isAuthorized: () => true,
        accessEpoch: () => epoch,
      );
      final work = vm.load();
      await Future<void>.delayed(Duration.zero);
      epoch++;
      pending.complete(
        Success(
          ManagedAnimalPage(
            items: [ManagedAnimal(animal: fixtureAnimal(1))],
            total: 1,
          ),
        ),
      );
      await work;
      expect(vm.state.items, isEmpty);
      expect(vm.state.loading, isFalse);
      vm.dispose();
      expect(vm.state.items, isEmpty);
    },
  );
  test(
    'private list loads pages, deduplicates and blocks access without authorization',
    () async {
      var allowed = true;
      final repository = FakeAnimalsRepository()
        ..handler = (_, _) async => Success(
          ManagedAnimalPage(
            items: [ManagedAnimal(animal: fixtureAnimal(1))],
            total: 1,
            cursor: null,
          ),
        );
      final vm = ManagedAnimalsViewModel(
        repository,
        isAuthorized: () => allowed,
      );
      addTearDown(vm.dispose);
      await vm.load();
      expect(vm.state.items.single.animal.id, fixtureId(1));
      expect(vm.state.loading, isFalse);
      await vm.load(more: true);
      expect(repository.calls.length, 1);
      allowed = false;
      await vm.load();
      expect(repository.calls.length, 1);
    },
  );
}
