import 'package:abrigo_dos_anjos/app/auth_application.dart';
import 'package:abrigo_dos_anjos/app/app_router.dart';
import 'package:abrigo_dos_anjos/domain/models/session_access.dart';
import 'package:abrigo_dos_anjos/domain/models/medication_agenda.dart';
import 'package:abrigo_dos_anjos/domain/models/medication_application.dart';
import 'package:abrigo_dos_anjos/ui/features/auth/view_models/session_view_model.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import '../../../../support/medication_completion_fixtures.dart';
import '../../../../support/fakes/fake_auth_repository.dart';
import '../../../../support/fakes/fake_animals_repository.dart';
import '../../../../support/fakes/fake_photo_repository.dart';
import '../../../../support/fakes/fake_favorites_repository.dart';
import '../../../../support/fakes/fake_adoption_message_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/ui/features/medications/views/medication_application_details_sheet.dart';
import 'package:abrigo_dos_anjos/ui/features/medications/view_models/medication_application_view_model.dart';
import 'package:abrigo_dos_anjos/ui/core/theme/app_theme.dart';
import 'package:abrigo_dos_anjos/utils/app_failure.dart';
import '../../../../support/fakes/fake_medication_completion_scenario.dart';
import '../../../../support/medication_fixtures.dart';

void main() {
  testWidgets(
    'approved details confirm actual actor/time and history without leaving the sheet',
    (tester) async {
      final scenario = FakeMedicationCompletionScenario();
      final vm = MedicationApplicationViewModel(scenario.repository);
      addTearDown(vm.dispose);
      await vm.open(medicationApplicationId);
      await tester.pumpWidget(
        MaterialApp(
          theme: buildTheme(),
          home: MedicationApplicationDetailsSheet(viewModel: vm),
        ),
      );
      expect(find.text('Detalhes da aplicação'), findsOneWidget);
      expect(find.text('08:00'), findsOneWidget);
      await tester.tap(find.text('Marcar como aplicada'));
      await tester.pumpAndSettle();
      final actual = find.text('01/11/2026 às 09:06');
      await tester.scrollUntilVisible(
        actual,
        150,
        scrollable: find.byType(Scrollable).first,
      );
      expect(actual, findsOneWidget);
      expect(find.text('Equipe de teste'), findsOneWidget);
      expect(find.text('Realizada'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Aplicação realizada'),
        150,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Aplicação realizada'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'uncertain completion blocks leaving and reconciles the same receipt at 320 px',
    (tester) async {
      tester.view.physicalSize = const Size(320, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final scenario = FakeMedicationCompletionScenario(
        failure: FailureCode.timeout,
      );
      final vm = MedicationApplicationViewModel(scenario.repository);
      addTearDown(vm.dispose);
      await vm.open(medicationApplicationId);
      await tester.pumpWidget(
        MaterialApp(
          theme: buildTheme(),
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(320, 844),
              textScaler: TextScaler.linear(1.4),
            ),
            child: MedicationApplicationDetailsSheet(viewModel: vm),
          ),
        ),
      );
      await tester.tap(find.text('Marcar como aplicada'));
      await tester.pumpAndSettle();
      expect(vm.state.application!.performedAt, isNull);
      expect(
        tester
            .widget<OutlinedButton>(
              find.widgetWithText(OutlinedButton, 'Voltar à agenda'),
            )
            .onPressed,
        isNull,
      );
      await tester.tap(find.text('Verificar resultado'));
      await tester.pumpAndSettle();
      expect(vm.actorLabel, 'Equipe de teste');
      expect(vm.canLeave, true);
      expect(scenario.keys, hasLength(1));
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'conflict reloads confirmed record and cannot issue a second completion',
    (tester) async {
      final scenario = FakeMedicationCompletionScenario(
        failure: FailureCode.conflict,
      );
      final vm = MedicationApplicationViewModel(scenario.repository);
      addTearDown(vm.dispose);
      await vm.open(medicationApplicationId);
      await tester.pumpWidget(
        MaterialApp(
          theme: buildTheme(),
          home: MedicationApplicationDetailsSheet(viewModel: vm),
        ),
      );
      await tester.tap(find.text('Marcar como aplicada'));
      await tester.pumpAndSettle();
      expect(vm.isCompleted, true);
      expect(
        tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, 'Marcar como aplicada'),
            )
            .onPressed,
        isNull,
      );
      expect(scenario.keys, hasLength(1));
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'details page history and recoverable load error use friendly actions',
    (tester) async {
      final scenario = FakeMedicationCompletionScenario();
      final normal = scenario.repository.handler!;
      var deny = true;
      scenario.repository.handler = (method, args) async {
        if (method == 'loadApplicationHistory') {
          if (deny) {
            return Failure<MedicationHistoryPage>(
              AppFailure(FailureCode.network),
            );
          }
          final event = completedMedication('k' * 32).event!;
          return Success(
            MedicationHistoryPage(
              application: pendingMedication().copyWith(version: 3),
              items: [
                args.last == null
                    ? event
                    : event.copyWith(
                        id: medicationAnimalId,
                        type: MedicationEventType.completionReversed,
                        applicationVersion: 3,
                        reason: 'Correção de teste',
                      ),
              ],
              cursor: args.last == null ? 'next' : null,
            ),
          );
        }
        return normal(method, args);
      };
      final vm = MedicationApplicationViewModel(scenario.repository);
      addTearDown(vm.dispose);
      await vm.open(medicationApplicationId);
      await tester.pumpWidget(
        MaterialApp(home: MedicationApplicationDetailsSheet(viewModel: vm)),
      );
      expect(find.text('Tentar carregar aplicação'), findsOneWidget);
      deny = false;
      await tester.tap(find.text('Tentar carregar aplicação'));
      await tester.pumpAndSettle();
      final more = find.text('Carregar mais registros');
      await tester.scrollUntilVisible(
        more,
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(more);
      await tester.pumpAndSettle();
      expect(vm.state.events, hasLength(2));
      expect(find.text('Registro corrigido'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'real private application route and history disappear on logout',
    (tester) async {
      final auth = FakeAuthRepository()
        ..handler = (_, _) async => const Success(
          SessionAccess(level: AccessLevel.authorized, userId: 'staff'),
        );
      addTearDown(auth.dispose);
      final session = SessionViewModel(auth);
      addTearDown(session.dispose);
      await session.start();
      final scenario = FakeMedicationCompletionScenario();
      final router = AppRouter(
        animals: FakeAnimalsRepository(),
        favorites: FakeFavoritesRepository(),
        photos: FakePhotoRepository(),
        adoption: FakeAdoptionMessageRepository(),
        auth: auth,
        session: session,
        medications: scenario.repository,
      );
      await tester.pumpWidget(
        AuthApplication(session: session, router: router),
      );
      await tester.pumpAndSettle();
      Navigator.of(
        tester.element(find.text('Quero Adotar (Visitante)')),
      ).pushNamed(
        '/medication-application',
        arguments: medicationApplicationId,
      );
      await tester.pumpAndSettle();
      expect(find.byType(MedicationApplicationDetailsSheet), findsOneWidget);
      expect(find.text('Atena'), findsOneWidget);
      auth.events.add(const Success(SessionAccess(level: AccessLevel.visitor)));
      await tester.pumpAndSettle();
      expect(
        find.byType(MedicationApplicationDetailsSheet, skipOffstage: false),
        findsNothing,
      );
      expect(find.text('Atena', skipOffstage: false), findsNothing);
      expect(find.text('Quero Adotar (Visitante)'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
