import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/ui/features/animals/view_models/dashboard_view_model.dart';
import 'package:abrigo_dos_anjos/domain/models/animal.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import 'package:abrigo_dos_anjos/utils/app_failure.dart';
import '../../../../support/fakes/fake_animals_repository.dart';
import '../../../../support/public_fixtures.dart';

void main() {
  FakeAnimalsRepository repository() => FakeAnimalsRepository()
    ..handler = (method, args) async {
      if (method == 'getStatusCounts') {
        return Success<Map<AnimalStatus, int>>({
          for (final s in AnimalStatus.values)
            s: s == AnimalStatus.available ? 75 : 0,
        });
      }
      if (method == 'listManagement') {
        return Success(
          ManagedAnimalPage(
            items: args.first == AnimalStatus.available
                ? [ManagedAnimal(animal: fixtureAnimal(1))]
                : [],
            total: args.first == AnimalStatus.available ? 75 : 0,
            cursor: args.first == AnimalStatus.available && args.last == null
                ? 'next'
                : null,
          ),
        );
      }
      return Success(fixtureAnimal(1));
    };
  test(
    'global totals exceed loaded page; independent columns and list mode',
    () async {
      final repo = repository();
      final vm = DashboardViewModel(repo, isAuthorized: () => true);
      addTearDown(vm.dispose);
      await vm.load();
      expect(vm.total, 75);
      expect(vm.state.pages[AnimalStatus.available]!.items.length, 1);
      expect(vm.canManage, true);
      vm.setListMode(true);
      expect(vm.state.listMode, true);
      await vm.loadMore(AnimalStatus.available);
      expect(repo.calls.last.arguments, [AnimalStatus.available, 'next']);
      expect(vm.total, 75);
    },
  );
  test(
    'failed command preserves confirmed cards and loss of access clears all private data',
    () async {
      final repo = repository();
      final vm = DashboardViewModel(repo, isAuthorized: () => true);
      addTearDown(vm.dispose);
      await vm.load();
      repo.handler = (method, args) async =>
          Failure<PublicAnimal>(AppFailure(FailureCode.validation));
      await vm.setStatus(fixtureId(1), AnimalStatus.treatment);
      expect(
        vm.state.pages[AnimalStatus.available]!.items.single.animal.status,
        AnimalStatus.available,
      );
      expect(vm.state.message, isNotNull);
      expect(vm.state.busy, false);
      repo.handler = (method, args) async =>
          Failure<PublicAnimal>(AppFailure(FailureCode.forbidden));
      await vm.setPublication(fixtureId(1), false);
      expect(vm.state.pages, isEmpty);
      expect(vm.total, 0);
    },
  );
  test(
    'timeout retains key and only retries after missing operation is confirmed',
    () async {
      final repo = repository();
      final vm = DashboardViewModel(
        repo,
        isAuthorized: () => true,
        delay: (_) async {},
      );
      addTearDown(vm.dispose);
      await vm.load();
      repo.handler = (method, args) async {
        if (method == 'getOperation') {
          return const Success<ManagedAnimal?>(null);
        }
        return Failure<PublicAnimal>(AppFailure(FailureCode.timeout));
      };
      await vm.setStatus(fixtureId(1), AnimalStatus.treatment);
      expect(vm.state.uncertain, true);
      expect(vm.state.canRetry, false);
      final first = repo.calls.last.arguments.last;
      await vm.reconcile();
      expect(vm.state.canRetry, true);
      await vm.retry();
      expect(repo.calls.last.arguments.last, first);
      expect(repo.calls.where((c) => c.method == 'getOperation').length, 3);
    },
  );
  test('late load is dropped after epoch changes and dispose', () async {
    var epoch = 0;
    final gate = Completer<Result<Map<AnimalStatus, int>>>();
    final repo = repository()..handler = (method, args) => gate.future;
    final vm = DashboardViewModel(
      repo,
      isAuthorized: () => true,
      accessEpoch: () => epoch,
    );
    final load = vm.load();
    await Future<void>.delayed(Duration.zero);
    epoch++;
    gate.complete(const Success({}));
    await load;
    expect(vm.state.pages, isEmpty);
    expect(vm.state.loading, false);
    vm.dispose();
    await vm.load();
  });
}
