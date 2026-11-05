import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/ui/features/medications/views/medication_application_details_sheet.dart';
import 'package:abrigo_dos_anjos/ui/features/medications/view_models/medication_application_view_model.dart';
import 'package:abrigo_dos_anjos/domain/models/medication_agenda.dart';
import 'package:abrigo_dos_anjos/domain/models/medication_application.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import 'package:abrigo_dos_anjos/utils/app_failure.dart';
import '../../../../support/fakes/fake_medication_completion_scenario.dart';
import '../../../../support/medication_completion_fixtures.dart';
import '../../../../support/medication_fixtures.dart';

void main() {
  testWidgets(
    'application shows loading, refreshes on resume and closes to previous route',
    (tester) async {
      final scenario = FakeMedicationCompletionScenario();
      final repo = scenario.repository;
      final base = repo.handler!;
      final gate = Completer<Result<MedicationHistoryPage>>();
      var delayed = true;
      repo.handler = (m, a) =>
          m == 'loadApplicationHistory' && delayed ? gate.future : base(m, a);
      final vm = MedicationApplicationViewModel(repo);
      addTearDown(vm.dispose);
      final opening = vm.open(medicationApplicationId);
      await tester.pump();
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        MedicationApplicationDetailsSheet(viewModel: vm),
                  ),
                ),
                child: const Text('Abrir aplicação'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Abrir aplicação'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      delayed = false;
      gate.complete(
        Success(
          MedicationHistoryPage(application: pendingMedication(), items: []),
        ),
      );
      await opening;
      await tester.pumpAndSettle();
      final before = repo.calls.length;
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(repo.calls.length, greaterThan(before));
      await tester.tap(find.byTooltip('Fechar aplicação'));
      await tester.pumpAndSettle();
      expect(find.text('Abrir aplicação'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'application only repeats the same command after missing receipt confirmation',
    (tester) async {
      final scenario = FakeMedicationCompletionScenario();
      final repo = scenario.repository;
      final base = repo.handler!;
      var attempts = 0;
      String? operation;
      repo.handler = (m, a) async {
        if (m == 'completeApplication') {
          attempts++;
          operation ??= a.last as String;
          expect(a.last, operation);
          return attempts == 1
              ? Failure<MedicationCommandResult>(
                  AppFailure(FailureCode.timeout),
                )
              : Success(completedMedication(operation!));
        }
        if (m == 'getOperation') {
          return const Success<MedicationCommandResult?>(null);
        }
        return await base(m, a);
      };
      final vm = MedicationApplicationViewModel(repo);
      addTearDown(vm.dispose);
      await vm.open(medicationApplicationId);
      await vm.complete();
      await tester.pumpWidget(
        MaterialApp(home: MedicationApplicationDetailsSheet(viewModel: vm)),
      );
      await tester.tap(find.text('Verificar resultado'));
      await tester.pumpAndSettle();
      expect(vm.state.canRetry, isTrue);
      await tester.scrollUntilVisible(
        find.text('Repetir a mesma operação'),
        180,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Repetir a mesma operação'));
      await tester.pumpAndSettle();
      expect(attempts, 2);
      expect(vm.state.application!.state, MedicationApplicationState.completed);
      expect(tester.takeException(), isNull);
    },
  );
  test(
    'cancelled history remains visible when a repeated cursor is rejected',
    () async {
      final scenario = FakeMedicationCompletionScenario();
      final repo = scenario.repository;
      final base = repo.handler!;
      final app = pendingMedication().copyWith(
        state: MedicationApplicationState.cancelled,
      );
      final event = completedMedication('k' * 32).event!.copyWith(
        type: MedicationEventType.cancelled,
        reason: 'treatment_stopped',
      );
      repo.handler = (m, a) async {
        if (m == 'loadApplicationHistory') {
          return Success(
            MedicationHistoryPage(
              application: app,
              items: [event],
              cursor: 'next',
            ),
          );
        }
        if (m == 'loadDay') {
          return Success(
            MedicationDayPage(
              day: app.scheduledLocalDate,
              serverNow: DateTime.utc(2026, 11, 1, 12, 6),
              agendaVersion: 1,
              items: [app],
            ),
          );
        }
        return await base(m, a);
      };
      final vm = MedicationApplicationViewModel(repo);
      addTearDown(vm.dispose);
      await vm.open(medicationApplicationId);
      expect(vm.eventTitle(event), 'Aplicação cancelada');
      await vm.load(more: true);
      expect(vm.state.events, [event]);
      expect(vm.state.message, isNotNull);
      expect(vm.state.loading, isFalse);
    },
  );
  test(
    'forbidden completion is friendly and explicitly revalidates access',
    () async {
      final scenario = FakeMedicationCompletionScenario();
      final repo = scenario.repository;
      final base = repo.handler!;
      var checks = 0;
      repo.handler = (m, a) async => m == 'completeApplication'
          ? Failure<MedicationCommandResult>(AppFailure(FailureCode.forbidden))
          : await base(m, a);
      final vm = MedicationApplicationViewModel(
        repo,
        authorize: () async {
          checks++;
          return true;
        },
      );
      addTearDown(vm.dispose);
      await vm.open(medicationApplicationId);
      final before = checks;
      expect(await vm.complete(), isFalse);
      expect(checks, greaterThanOrEqualTo(before + 2));
      expect(vm.state.message, contains('Seu acesso'));
      expect(vm.state.uncertain, isFalse);
    },
  );
}
