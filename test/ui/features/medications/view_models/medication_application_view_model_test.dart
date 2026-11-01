import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/domain/models/medication_agenda.dart';
import 'package:abrigo_dos_anjos/domain/models/medication_application.dart';
import 'package:abrigo_dos_anjos/ui/features/medications/view_models/medication_application_view_model.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import 'package:abrigo_dos_anjos/utils/app_failure.dart';
import '../../../../support/fakes/fake_medications_repository.dart';
import '../../../../support/medication_fixtures.dart';
import '../../../../support/medication_completion_fixtures.dart';

FakeMedicationsRepository repository() => FakeMedicationsRepository()
  ..handler = (method, args) async => switch (method) {
    'loadApplicationHistory' => Success(
      MedicationHistoryPage(application: pendingMedication()),
    ),
    'loadDay' => Success(
      MedicationDayPage(
        day: '2026-11-01',
        serverNow: DateTime.utc(2026, 11, 1, 12),
        agendaVersion: 1,
      ),
    ),
    'listTreatments' => const Success(MedicationTreatmentPage()),
    'completeApplication' => Success(completedMedication(args.last as String)),
    'getOperation' => const Success<MedicationCommandResult?>(null),
    _ => throw StateError('Unexpected'),
  };
void main() {
  test(
    'details use server clock/civil values and confirmed completion records actor/time',
    () async {
      final vm = MedicationApplicationViewModel(repository());
      addTearDown(vm.dispose);
      await vm.open(medicationApplicationId);
      expect(vm.canComplete, true);
      expect(vm.scheduledDate, '01/11/2026');
      expect(vm.stateLabel, 'Atrasada');
      expect(await vm.complete(), true);
      expect(vm.stateLabel, 'Realizada');
      expect(vm.actorLabel, 'Equipe de teste');
      expect(vm.actualTime, '01/11/2026 às 09:06');
      expect(vm.state.events, hasLength(1));
      expect(vm.canComplete, false);
    },
  );
  test(
    'future/cancelled applications and loading cannot be completed',
    () async {
      final repo = repository();
      final normal = repo.handler!;
      repo.handler = (method, args) => method == 'loadApplicationHistory'
          ? Future.value(
              Success(
                MedicationHistoryPage(
                  application: pendingMedication().copyWith(
                    scheduledAt: DateTime.utc(2100),
                  ),
                ),
              ),
            )
          : normal(method, args);
      final vm = MedicationApplicationViewModel(repo);
      addTearDown(vm.dispose);
      await vm.open(medicationApplicationId);
      expect(vm.canComplete, false);
      expect(await vm.complete(), false);
      repo.handler = (method, args) => method == 'loadApplicationHistory'
          ? Future.value(
              Success(
                MedicationHistoryPage(
                  application: pendingMedication().copyWith(
                    state: MedicationApplicationState.cancelled,
                  ),
                ),
              ),
            )
          : normal(method, args);
      await vm.load();
      expect(vm.canComplete, false);
      expect(vm.stateLabel, 'Cancelada');
      expect(
        repo.calls.where((c) => c.method == 'completeApplication'),
        isEmpty,
      );
    },
  );
  test(
    'pending request never displays optimistic success or permits leaving',
    () async {
      final delayed = Completer<Result<MedicationCommandResult>>();
      final repo = repository();
      final normal = repo.handler!;
      repo.handler = (method, args) => method == 'completeApplication'
          ? delayed.future
          : normal(method, args);
      final vm = MedicationApplicationViewModel(repo);
      addTearDown(vm.dispose);
      await vm.open(medicationApplicationId);
      final action = vm.complete();
      await Future<void>.delayed(Duration.zero);
      expect(vm.canLeave, false);
      expect(vm.state.application!.state, MedicationApplicationState.pending);
      expect(vm.state.events, isEmpty);
      final key = repo.calls.last.arguments.last as String;
      delayed.complete(Success(completedMedication(key)));
      expect(await action, true);
      expect(vm.canLeave, true);
    },
  );
  test(
    'timeout preserves key and original actor/time during receipt reconciliation',
    () async {
      final repo = repository();
      final normal = repo.handler!;
      String? key;
      repo.handler = (method, args) async {
        if (method == 'completeApplication') {
          key = args.last as String;
          return Failure<MedicationCommandResult>(
            AppFailure(FailureCode.timeout),
          );
        }
        if (method == 'getOperation') {
          expect(args.single, key);
          return Success<MedicationCommandResult?>(completedMedication(key!));
        }
        return normal(method, args);
      };
      final vm = MedicationApplicationViewModel(repo);
      addTearDown(vm.dispose);
      await vm.open(medicationApplicationId);
      expect(await vm.complete(), false);
      expect(vm.state.uncertain, true);
      expect(vm.canLeave, false);
      expect(await vm.reconcile(), true);
      expect(vm.actualTime, '01/11/2026 às 09:06');
      expect(vm.state.events, hasLength(1));
    },
  );
  test(
    'missing receipt allows only same frozen application/version/key retry',
    () async {
      var attempts = 0;
      final keys = <String>[];
      final repo = repository();
      final normal = repo.handler!;
      repo.handler = (method, args) async {
        if (method == 'completeApplication') {
          keys.add(args.last as String);
          attempts++;
          return attempts == 1
              ? Failure<MedicationCommandResult>(
                  AppFailure(FailureCode.network),
                )
              : Success(completedMedication(args.last as String));
        }
        return normal(method, args);
      };
      final vm = MedicationApplicationViewModel(repo);
      addTearDown(vm.dispose);
      await vm.open(medicationApplicationId);
      await vm.complete();
      expect(await vm.complete(), false);
      await vm.open(medicationAnimalId);
      expect(vm.state.application!.id, medicationApplicationId);
      await vm.reconcile();
      expect(vm.state.canRetry, true);
      expect(await vm.retryPending(), true);
      expect(keys, hasLength(2));
      expect(keys.toSet(), hasLength(1));
    },
  );
  test(
    'conflict reloads authoritative completed state without duplicate event',
    () async {
      var completed = false;
      final repo = repository();
      final normal = repo.handler!;
      repo.handler = (method, args) async {
        if (method == 'completeApplication') {
          completed = true;
          return Failure<MedicationCommandResult>(
            AppFailure(FailureCode.conflict),
          );
        }
        if (method == 'loadApplicationHistory' && completed) {
          final result = completedMedication('k' * 32);
          return Success(
            MedicationHistoryPage(
              application: result.application!,
              items: [result.event!],
            ),
          );
        }
        return normal(method, args);
      };
      final vm = MedicationApplicationViewModel(repo);
      addTearDown(vm.dispose);
      await vm.open(medicationApplicationId);
      expect(await vm.complete(), false);
      expect(vm.isCompleted, true);
      expect(vm.state.events, hasLength(1));
      expect(vm.canComplete, false);
      expect(vm.state.message, contains('mudou'));
    },
  );
  test(
    'history pagination preserves events and detects changed projection',
    () async {
      final repo = repository();
      final normal = repo.handler!;
      var changed = false;
      repo.handler = (method, args) async {
        if (method == 'loadApplicationHistory') {
          final event = completedMedication('k' * 32).event!;
          return Success(
            MedicationHistoryPage(
              application: changed
                  ? completedMedication('k' * 32).application!
                  : pendingMedication(),
              items: args.last == null
                  ? [event]
                  : [
                      event.copyWith(
                        id: medicationAnimalId,
                        applicationVersion: 3,
                      ),
                    ],
              cursor: args.last == null && !changed ? 'next' : null,
            ),
          );
        }
        return normal(method, args);
      };
      final vm = MedicationApplicationViewModel(repo);
      addTearDown(vm.dispose);
      await vm.open(medicationApplicationId);
      await vm.load(more: true);
      expect(vm.state.events, hasLength(2));
      await vm.load();
      changed = true;
      await vm.load(more: true);
      expect(vm.isCompleted, true);
      expect(vm.state.events, hasLength(1));
    },
  );
  test(
    'logout generation discards private state and late confirmation',
    () async {
      var generation = 0;
      var allowed = true;
      final delayed = Completer<Result<MedicationCommandResult>>();
      final repo = repository();
      final normal = repo.handler!;
      repo.handler = (method, args) => method == 'completeApplication'
          ? delayed.future
          : normal(method, args);
      final vm = MedicationApplicationViewModel(
        repo,
        isAuthorized: () => allowed,
        privateGeneration: () => generation,
      );
      addTearDown(vm.dispose);
      await vm.open(medicationApplicationId);
      final action = vm.complete();
      await Future<void>.delayed(Duration.zero);
      final key = repo.calls.last.arguments.last as String;
      generation++;
      allowed = false;
      vm.refreshAccess();
      delayed.complete(Success(completedMedication(key)));
      expect(await action, false);
      expect(vm.state.application, isNull);
      expect(vm.state.events, isEmpty);
    },
  );
  test(
    'same user access epoch changes keep uncertain command available for reconciliation',
    () async {
      var epoch = 0;
      final delayed = Completer<Result<MedicationCommandResult>>();
      final repo = repository();
      final normal = repo.handler!;
      String? key;
      repo.handler = (method, args) {
        if (method == 'completeApplication') {
          key = args.last as String;
          return delayed.future;
        }
        if (method == 'getOperation') {
          return Future.value(
            Success<MedicationCommandResult?>(completedMedication(key!)),
          );
        }
        return normal(method, args);
      };
      final vm = MedicationApplicationViewModel(repo, accessEpoch: () => epoch);
      addTearDown(vm.dispose);
      await vm.open(medicationApplicationId);
      final action = vm.complete();
      await Future<void>.delayed(Duration.zero);
      epoch++;
      delayed.complete(Success(completedMedication(key!)));
      expect(await action, false);
      expect(vm.state.uncertain, true);
      expect(await vm.reconcile(), true);
    },
  );
  test(
    'exceptions are uncertain and read authorization failure removes private details',
    () async {
      final repo = repository();
      final normal = repo.handler!;
      repo.handler = (method, args) => method == 'completeApplication'
          ? throw StateError('private')
          : normal(method, args);
      final vm = MedicationApplicationViewModel(repo);
      addTearDown(vm.dispose);
      await vm.open(medicationApplicationId);
      expect(await vm.complete(), false);
      expect(vm.state.uncertain, true);
      expect(vm.state.message, isNot(contains('private')));
      final denied = MedicationApplicationViewModel(
        FakeMedicationsRepository()
          ..handler = (_, _) async =>
              Failure<MedicationHistoryPage>(AppFailure(FailureCode.forbidden)),
      );
      addTearDown(denied.dispose);
      await denied.open(medicationApplicationId);
      expect(denied.state.application, isNull);
      expect(denied.state.loadFailed, true);
    },
  );
}
