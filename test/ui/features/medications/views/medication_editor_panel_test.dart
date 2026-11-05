import 'package:abrigo_dos_anjos/app/auth_application.dart';
import 'package:abrigo_dos_anjos/app/app_router.dart';
import 'package:abrigo_dos_anjos/domain/models/session_access.dart';
import 'package:abrigo_dos_anjos/domain/models/animal.dart';
import 'package:abrigo_dos_anjos/ui/features/auth/view_models/session_view_model.dart';
import '../../../../support/fakes/fake_auth_repository.dart';
import '../../../../support/fakes/fake_animals_repository.dart';
import '../../../../support/fakes/fake_photo_repository.dart';
import '../../../../support/fakes/fake_favorites_repository.dart';
import '../../../../support/fakes/fake_adoption_message_repository.dart';
import '../../../../support/public_fixtures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/ui/features/medications/views/medication_editor_panel.dart';
import 'package:abrigo_dos_anjos/ui/features/medications/view_models/medication_editor_view_model.dart';
import 'package:abrigo_dos_anjos/domain/models/medication_agenda.dart';
import 'package:abrigo_dos_anjos/domain/models/medication_application.dart';
import 'package:abrigo_dos_anjos/domain/models/medication_treatment.dart';
import 'package:abrigo_dos_anjos/domain/models/medication_schedule.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import 'package:abrigo_dos_anjos/ui/core/theme/app_theme.dart';
import '../../../../support/fakes/fake_medications_repository.dart';
import '../../../../support/medication_fixtures.dart';

void main() {
  testWidgets('real protected medication route clears form on logout', (
    tester,
  ) async {
    final auth = FakeAuthRepository()
      ..handler = (_, _) async => const Success(
        SessionAccess(level: AccessLevel.authorized, userId: 'staff'),
      );
    addTearDown(auth.dispose);
    final session = SessionViewModel(auth);
    addTearDown(session.dispose);
    await session.start();
    final animals = FakeAnimalsRepository()
      ..handler = (_, _) async => Success(
        ManagedAnimal(
          animal: fixtureAnimal(
            1,
          ).copyWith(id: medicationAnimalId, name: 'Atena'),
        ),
      );
    final medications = FakeMedicationsRepository()
      ..handler = (_, _) async => const Success(MedicationTreatmentPage());
    final router = AppRouter(
      animals: animals,
      favorites: FakeFavoritesRepository(),
      photos: FakePhotoRepository(),
      adoption: FakeAdoptionMessageRepository(),
      auth: auth,
      session: session,
      medications: medications,
    );
    await tester.pumpWidget(AuthApplication(session: session, router: router));
    await tester.pumpAndSettle();
    final homeContext = tester.element(find.text('Quero Adotar (Visitante)'));
    Navigator.of(homeContext).pushNamed(
      '/medication-editor',
      arguments: {'animalId': medicationAnimalId},
    );
    await tester.pumpAndSettle();
    expect(find.text('Atena'), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('medicationName')),
      'Rascunho privado da medicação',
    );
    auth.events.add(const Success(SessionAccess(level: AccessLevel.visitor)));
    await tester.pumpAndSettle();
    expect(find.byType(MedicationProgrammingScreen), findsNothing);
    expect(find.text('Quero Adotar (Visitante)'), findsOneWidget);
    expect(
      find.text('Rascunho privado da medicação', skipOffstage: false),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'approved editor fills fixed times, validates and confirms treatment',
    (tester) async {
      MedicationTreatment? saved;
      final repository = FakeMedicationsRepository()
        ..handler = (method, args) async {
          if (method == 'listTreatments') {
            return Success(
              MedicationTreatmentPage(items: [if (saved != null) saved!]),
            );
          }
          final draft = args.first as MedicationTreatmentDraft;
          saved = MedicationTreatment(
            id: medicationTreatmentId,
            animalId: medicationAnimalId,
            revision: 1,
            version: 1,
            medicationName: draft.medicationName,
            schedule: draft.schedule,
          );
          return Success(
            MedicationCommandResult(
              operationKey: args.last as String,
              serverNow: DateTime.utc(2026, 11, 1),
              treatment: saved,
            ),
          );
        };
      final vm = MedicationEditorViewModel(repository);
      addTearDown(vm.dispose);
      await vm.bindAnimal(medicationAnimalId, 'Atena');
      await tester.pumpWidget(
        MaterialApp(
          theme: buildTheme(),
          onGenerateRoute: (_) {
            vm.startCreate();
            return MaterialPageRoute(
              builder: (_) => MedicationProgrammingScreen(viewModel: vm),
            );
          },
          home: Scaffold(
            body: SingleChildScrollView(
              child: MedicationEditorPanel(viewModel: vm),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Adicionar medicação'));
      await tester.pumpAndSettle();
      expect(find.text('Programar medicação'), findsOneWidget);
      Future<void> enter(String key, String text) async {
        final field = find.byKey(ValueKey(key));
        await tester.scrollUntilVisible(
          field,
          180,
          scrollable: find
              .descendant(
                of: find.byKey(const ValueKey('medicationFormScroll')),
                matching: find.byType(Scrollable),
              )
              .first,
        );
        await tester.enterText(field, text);
        await tester.pump();
      }

      await enter('medicationName', 'Medicação de teste');
      await enter('medicationStartsOn', '01/11/2026');
      await enter('medicationEndsOn', '02/11/2026');
      await tester.tap(find.text('Salvar programação'));
      await tester.pumpAndSettle();
      expect(find.text('Programar medicação'), findsNothing);
      expect(find.text('Medicação de teste'), findsOneWidget);
      expect(find.text('Programação salva com sucesso.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('compact approved form supports interval mode and error state', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repository = FakeMedicationsRepository()
      ..handler = (_, _) async => const Success(MedicationTreatmentPage());
    final vm = MedicationEditorViewModel(repository);
    addTearDown(vm.dispose);
    await vm.bindAnimal(medicationAnimalId, 'Atena');
    vm.startCreate();
    await tester.pumpWidget(
      MaterialApp(
        theme: buildTheme(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.4)),
          child: child!,
        ),
        home: MedicationProgrammingScreen(viewModel: vm),
      ),
    );
    final mode = find.text('Por intervalo');
    await tester.scrollUntilVisible(
      mode,
      180,
      scrollable: find
          .descendant(
            of: find.byKey(const ValueKey('medicationFormScroll')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.tap(mode);
    await tester.pump();
    expect(vm.state.draft.schedule.mode, MedicationScheduleMode.interval);
    await tester.tap(find.text('Salvar programação'));
    await tester.pumpAndSettle();
    expect(vm.state.errors, isNotEmpty);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'treatment panel stops confirmed record and disables editing without removing it',
    (tester) async {
      var treatment = const MedicationTreatment(
        id: medicationTreatmentId,
        animalId: medicationAnimalId,
        revision: 1,
        version: 1,
        medicationName: 'Exemplo',
        schedule: MedicationSchedule(
          startsOn: '2026-11-01',
          endsOn: '2026-11-02',
        ),
      );
      final repository = FakeMedicationsRepository()
        ..handler = (method, args) async {
          if (method == 'listTreatments') {
            return Success(MedicationTreatmentPage(items: [treatment]));
          }
          treatment = treatment.copyWith(
            status: MedicationTreatmentStatus.stopped,
            version: 2,
          );
          return Success(
            MedicationCommandResult(
              operationKey: args.last as String,
              serverNow: DateTime.utc(2026, 11, 1),
              treatment: treatment,
            ),
          );
        };
      final vm = MedicationEditorViewModel(repository);
      addTearDown(vm.dispose);
      await vm.bindAnimal(medicationAnimalId, 'Atena');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MedicationEditorPanel(viewModel: vm)),
        ),
      );
      await tester.tap(find.byTooltip('Interromper Exemplo'));
      await tester.pumpAndSettle();
      expect(find.text('Exemplo'), findsOneWidget);
      expect(find.textContaining('Interrompido'), findsOneWidget);
      expect(
        tester
            .widget<IconButton>(
              find
                  .ancestor(
                    of: find.byTooltip('Interromper Exemplo'),
                    matching: find.byType(IconButton),
                  )
                  .first,
            )
            .onPressed,
        isNull,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
