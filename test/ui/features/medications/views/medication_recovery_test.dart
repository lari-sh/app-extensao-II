import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/ui/features/medications/views/medication_editor_panel.dart';
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
  medicationName: 'Cuidados simulados — Amora',
  schedule: MedicationSchedule(startsOn: '2026-11-01', endsOn: '2026-11-02'),
);
void fill(MedicationEditorViewModel vm) {
  vm.startCreate();
  vm.setName('Cuidados simulados — Amora');
  vm.setStartDate('01/11/2026');
  vm.setEndDate('02/11/2026');
}

Future<void> scrollTo(WidgetTester tester, Finder target) async {
  await tester.scrollUntilVisible(
    target,
    160,
    scrollable: find
        .descendant(
          of: find.byKey(const ValueKey('medicationFormScroll')),
          matching: find.byType(Scrollable),
        )
        .first,
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'programming load failure offers explicit retry without inventing a treatment',
    (tester) async {
      var failed = true;
      final repo = FakeMedicationsRepository()
        ..handler = (_, _) async => failed
            ? Failure<MedicationTreatmentPage>(AppFailure(FailureCode.network))
            : const Success(MedicationTreatmentPage());
      final vm = MedicationEditorViewModel(repo);
      addTearDown(vm.dispose);
      await vm.bindAnimal(medicationAnimalId, 'Amora');
      await tester.pumpWidget(
        MaterialApp(home: MedicationProgrammingScreen(viewModel: vm)),
      );
      await scrollTo(tester, find.text('Tentar carregar novamente'));
      failed = false;
      await tester.tap(find.text('Tentar carregar novamente'));
      await tester.pumpAndSettle();
      expect(vm.state.loadFailed, isFalse);
      expect(vm.state.treatments, isEmpty);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'failed treatment list reloads, paginates and opens existing treatment',
    (tester) async {
      var fail = true;
      var more = false;
      final repo = FakeMedicationsRepository()
        ..handler = (m, a) async {
          if (fail) {
            return Failure<MedicationTreatmentPage>(
              AppFailure(FailureCode.network),
            );
          }
          return Success(
            MedicationTreatmentPage(
              items: [treatment],
              cursor: more ? null : 'next',
            ),
          );
        };
      final vm = MedicationEditorViewModel(repo);
      addTearDown(vm.dispose);
      await vm.bindAnimal(medicationAnimalId, 'Amora');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MedicationEditorPanel(viewModel: vm),
            ),
          ),
          onGenerateRoute: (settings) {
            vm.beginEdit(treatment);
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => MedicationProgrammingScreen(viewModel: vm),
            );
          },
        ),
      );
      fail = false;
      await tester.tap(find.text('Tentar carregar medicações'));
      await tester.pumpAndSettle();
      more = true;
      await tester.tap(find.text('Carregar mais tratamentos'));
      await tester.pumpAndSettle();
      expect(vm.state.treatments.length, 1);
      await tester.tap(find.text(treatment.medicationName));
      await tester.pumpAndSettle();
      expect(vm.state.draft.treatmentId, treatment.id);
      await tester.tap(find.byTooltip('Fechar programação'));
      await tester.pumpAndSettle();
      expect(vm.state.hasDraft, isFalse);
      expect(find.byType(MedicationProgrammingScreen), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
  for (final retry in [true, false]) {
    testWidgets(
      'uncertain stop exposes verification and ${retry ? 'same operation retry' : 'confirmed receipt'}',
      (tester) async {
        var attempts = 0;
        var confirmed = false;
        String? key;
        final repo = FakeMedicationsRepository()
          ..handler = (m, a) async {
            if (m == 'listTreatments') {
              return const Success(MedicationTreatmentPage(items: [treatment]));
            }
            if (m == 'stopTreatment') {
              attempts++;
              key = a.last as String;
              if (attempts == 1) {
                return Failure<MedicationCommandResult>(
                  AppFailure(FailureCode.timeout),
                );
              }
              confirmed = true;
            }
            if (!confirmed) {
              return const Success<MedicationCommandResult?>(null);
            }
            return Success(
              MedicationCommandResult(
                operationKey: key!,
                serverNow: DateTime.utc(2026, 11, 2),
                treatment: treatment.copyWith(
                  status: MedicationTreatmentStatus.stopped,
                ),
              ),
            );
          };
        final vm = MedicationEditorViewModel(repo);
        addTearDown(vm.dispose);
        await vm.bindAnimal(medicationAnimalId, 'Amora');
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: MedicationEditorPanel(viewModel: vm),
              ),
            ),
          ),
        );
        await tester.tap(
          find.byTooltip('Interromper ${treatment.medicationName}'),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Verificar resultado'));
        await tester.pumpAndSettle();
        expect(vm.state.canRetryPending, isTrue);
        if (!retry) confirmed = true;
        await tester.tap(
          find.text(retry ? 'Repetir a mesma operação' : 'Verificar resultado'),
        );
        await tester.pumpAndSettle();
        expect(vm.state.uncertain, isFalse);
        expect(
          vm.state.treatments.single.status,
          MedicationTreatmentStatus.stopped,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
  for (final retry in [true, false]) {
    testWidgets(
      'programming footer ${retry ? 'retries' : 'reconciles'} confirmed submission and returns',
      (tester) async {
        var attempts = 0;
        var confirmed = false;
        String? key;
        final repo = FakeMedicationsRepository()
          ..handler = (m, a) async {
            if (m == 'listTreatments') {
              return const Success(MedicationTreatmentPage());
            }
            if (m == 'saveTreatment') {
              attempts++;
              key = a.last as String;
              if (attempts == 1) {
                return Failure<MedicationCommandResult>(
                  AppFailure(FailureCode.timeout),
                );
              }
              confirmed = true;
            }
            if (!confirmed) {
              return const Success<MedicationCommandResult?>(null);
            }
            return Success(
              MedicationCommandResult(
                operationKey: key!,
                serverNow: DateTime.utc(2026, 11, 2),
                treatment: treatment,
              ),
            );
          };
        final vm = MedicationEditorViewModel(repo);
        addTearDown(vm.dispose);
        await vm.bindAnimal(medicationAnimalId, 'Amora');
        fill(vm);
        await vm.save();
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          MedicationProgrammingScreen(viewModel: vm),
                    ),
                  ),
                  child: const Text('Programar'),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Programar'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Verificar resultado'));
        await tester.pumpAndSettle();
        if (retry) {
          await tester.tap(find.text('Repetir operação'));
        } else {
          confirmed = true;
          await tester.tap(find.text('Verificar resultado'));
        }
        await tester.pumpAndSettle();
        expect(find.byType(MedicationProgrammingScreen), findsNothing);
        expect(vm.state.confirmedTreatmentId, treatment.id);
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets(
    'programming reports inverted period and duplicate fixed times, then cancels',
    (tester) async {
      final repo = FakeMedicationsRepository()
        ..handler = (_, _) async => const Success(MedicationTreatmentPage());
      final vm = MedicationEditorViewModel(repo);
      addTearDown(vm.dispose);
      await vm.bindAnimal(medicationAnimalId, 'Amora');
      fill(vm);
      vm.setStartDate('03/11/2026');
      vm.setTime(1, '08:00');
      await vm.save();
      await tester.pumpWidget(
        MaterialApp(home: MedicationProgrammingScreen(viewModel: vm)),
      );
      expect(vm.state.errors.keys, containsAll(['period', 'fixedTimes']));
      for (final field in ['period', 'fixedTimes']) {
        await scrollTo(tester, find.text(vm.state.errors[field]!));
        expect(find.text(vm.state.errors[field]!), findsOneWidget);
      }
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(vm.state.hasDraft, isFalse);
      expect(tester.takeException(), isNull);
    },
  );
}
