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
  test(
    'confirmed commands reload global counts, publication is blocked for adopted',
    () async {
      final repo = repository();
      final vm = DashboardViewModel(repo, isAuthorized: () => true);
      addTearDown(vm.dispose);
      await vm.load();
      expect(
        vm.canPublish(fixtureAnimal(1).copyWith(status: AnimalStatus.adopted)),
        false,
      );
      final previous = repo.calls
          .where((c) => c.method == 'getStatusCounts')
          .length;
      await vm.setPublication(fixtureId(1), false);
      expect(vm.state.uncertain, false);
      expect(vm.state.busy, false);
      expect(
        repo.calls.where((c) => c.method == 'getStatusCounts').length,
        previous + 1,
      );
    },
  );
  test(
    'empty and denied loads settle loading, never authorize using cached pages',
    () async {
      final repo = FakeAnimalsRepository()
        ..handler = (method, args) async => method == 'getStatusCounts'
            ? const Success<Map<AnimalStatus, int>>({})
            : const Success(ManagedAnimalPage(items: [], total: 0));
      var allowed = true;
      final vm = DashboardViewModel(repo, isAuthorized: () => allowed);
      addTearDown(vm.dispose);
      await vm.load();
      expect(vm.total, 0);
      expect(vm.state.loading, false);
      allowed = false;
      await vm.load();
      expect(vm.state.pages, isEmpty);
      expect(vm.canManage, false);
    },
  );
  test(
    '401 during counts discards pages and revalidates; late mutation never confirms after dispose',
    () async {
      final repo = repository();
      var checks = 0;
      final vm = DashboardViewModel(
        repo,
        isAuthorized: () => true,
        authorize: () async {
          checks++;
          return true;
        },
      );
      await vm.load();
      repo.handler = (_, _) async => Failure<Map<AnimalStatus, int>>(
        AppFailure(FailureCode.unauthenticated),
      );
      await vm.load();
      expect(vm.state.pages, isEmpty);
      expect(checks, greaterThan(1));
      final gate = Completer<Result<PublicAnimal>>();
      repo.handler = (_, _) => gate.future;
      final mutation = vm.setStatus(fixtureId(1), AnimalStatus.adopted);
      await Future<void>.delayed(Duration.zero);
      vm.dispose();
      gate.complete(Success(fixtureAnimal(1)));
      await mutation;
      expect(vm.state.message, isNull);
    },
  );
  test(
    'epoch change during write keeps operation uncertain until explicit reconciliation',
    () async {
      var epoch = 0;
      final repo = repository();
      final vm = DashboardViewModel(
        repo,
        isAuthorized: () => true,
        accessEpoch: () => epoch,
        delay: (_) async {},
      );
      addTearDown(vm.dispose);
      await vm.load();
      final gate = Completer<Result<PublicAnimal>>();
      repo.handler = (_, _) => gate.future;
      final sending = vm.setStatus(fixtureId(1), AnimalStatus.treatment);
      await Future<void>.delayed(Duration.zero);
      epoch++;
      gate.complete(Success(fixtureAnimal(1)));
      await sending;
      expect(vm.state.uncertain, true);
      expect(vm.canManage, false);
      expect(vm.state.busy, false);
      repo.handler = (_, _) async => const Success<ManagedAnimal?>(null);
      await vm.reconcile();
      expect(vm.state.canRetry, true);
    },
  );
}
