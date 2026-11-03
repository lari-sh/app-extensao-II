import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/domain/models/animal.dart';
import 'package:abrigo_dos_anjos/ui/features/animals/view_models/dashboard_view_model.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import 'package:abrigo_dos_anjos/utils/app_failure.dart';
import '../../../../support/management_scenarios.dart';
import '../../../../support/presentation_fixtures.dart';

void main() {
  test(
    'revalidation that fails or revokes access clears private dashboard',
    () async {
      for (final deny in [true, false]) {
        var allowed = true;
        final repo = managementScenario();
        final vm = DashboardViewModel(
          repo,
          isAuthorized: () => allowed,
          authorize: () async {
            if (!deny) allowed = false;
            return !deny;
          },
        );
        await vm.load();
        expect(repo.calls, isEmpty);
        expect(vm.total, 0);
        expect(vm.state.loading, isFalse);
        vm.dispose();
      }
    },
  );
  test(
    'page failures preserve loaded animals and friendly state without stale loading',
    () async {
      final repo = managementScenario();
      final vm = DashboardViewModel(repo, isAuthorized: () => true);
      addTearDown(vm.dispose);
      repo.handler = (m, a) async => m == 'getStatusCounts'
          ? await managementResponse(m, a)
          : Failure<ManagedAnimalPage>(AppFailure(FailureCode.network));
      await vm.load();
      expect(vm.state.pages, isEmpty);
      expect(vm.state.message, contains('conectar'));
      repo.handler = managementResponse;
      await vm.load();
      final original = vm.state.pages;
      repo.handler = (m, a) async =>
          Failure<ManagedAnimalPage>(AppFailure(FailureCode.network));
      await vm.loadMore(AnimalStatus.available);
      expect(vm.state.pages, original);
      expect(vm.state.busy, isFalse);
    },
  );
  for (final focused in [true, false]) {
    test(
      'receipt recovery refreshes ${focused ? 'focused animal' : 'global totals'} and never retries an uncertain failure',
      () async {
        final repo = managementScenario();
        var receipt = 0;
        final vm = DashboardViewModel(
          repo,
          isAuthorized: () => true,
          delay: (_) async {},
        );
        addTearDown(vm.dispose);
        final animal = presentationAnimal('bento');
        if (focused) {
          await vm.loadFocused(animal.id);
        } else {
          await vm.load();
        }
        repo.handler = (m, a) async {
          if (m == 'setStatus') {
            return Failure<PublicAnimal>(AppFailure(FailureCode.timeout));
          }
          if (m == 'getOperation') {
            if (receipt == 0) {
              return Failure<ManagedAnimal?>(AppFailure(FailureCode.network));
            }
            if (receipt == 1) return const Success<ManagedAnimal?>(null);
            return Success<ManagedAnimal?>(ManagedAnimal(animal: animal));
          }
          return await managementResponse(m, a);
        };
        if (focused) {
          await vm.setFocusedStatus(AnimalStatus.treatment);
        } else {
          await vm.setStatus(animal.id, AnimalStatus.treatment);
        }
        await vm.reconcile();
        expect(vm.state.canRetry, isFalse);
        expect(vm.state.uncertain, isTrue);
        receipt = 1;
        await vm.reconcile();
        expect(vm.state.canRetry, isTrue);
        receipt = 2;
        await vm.reconcile();
        expect(vm.state.uncertain, isFalse);
        expect(
          repo.calls
              .where(
                (c) =>
                    c.method == (focused ? 'getManagement' : 'getStatusCounts'),
              )
              .length,
          greaterThanOrEqualTo(2),
        );
      },
    );
  }
  test(
    'mode and adopted summary labels are consistent with all management statuses',
    () {
      final vm = DashboardViewModel(
        managementScenario(),
        isAuthorized: () => true,
      );
      addTearDown(vm.dispose);
      for (final mode in DashboardMode.values) {
        vm.setMode(mode);
        expect(vm.modeLabel, ['Kanban', 'Lista', 'Calendário'][mode.index]);
      }
      expect(
        vm.cardClinicalSummary(
          ManagedAnimal(
            animal: presentationAnimal(
              'bento',
            ).copyWith(status: AnimalStatus.adopted),
          ),
        ),
        'Adotado',
      );
    },
  );
}
