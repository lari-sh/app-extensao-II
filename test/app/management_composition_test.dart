import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/app/app_router.dart';
import 'package:abrigo_dos_anjos/app/auth_application.dart';
import 'package:abrigo_dos_anjos/domain/models/animal.dart';
import 'package:abrigo_dos_anjos/domain/models/session_access.dart';
import 'package:abrigo_dos_anjos/ui/features/auth/view_models/session_view_model.dart';
import 'package:abrigo_dos_anjos/ui/features/animals/views/animal_editor_screen.dart';
import 'package:abrigo_dos_anjos/ui/features/medications/views/medication_calendar_panel.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import '../support/public_app_harness.dart';
import '../support/public_fixtures.dart';
import '../support/fakes/fake_auth_repository.dart';
import '../support/fakes/fake_medication_completion_scenario.dart';

void main() {
  testWidgets(
    'administrator dashboard composes calendar, refreshes on resume and routes team action',
    (tester) async {
      final h = PublicAppHarness();
      h.animals.handler = (method, args) async => method == 'getStatusCounts'
          ? const Success<Map<AnimalStatus, int>>({})
          : const Success(ManagedAnimalPage(items: [], total: 0));
      final auth = FakeAuthRepository()
        ..handler = (_, _) async => const Success(
          SessionAccess(
            level: AccessLevel.authorized,
            userId: 'admin',
            role: StaffRole.administrator,
          ),
        );
      addTearDown(auth.dispose);
      final session = SessionViewModel(auth);
      addTearDown(session.dispose);
      await session.start();
      final clinical = FakeMedicationCompletionScenario();
      final router = AppRouter(
        animals: h.animals,
        favorites: h.favorites,
        photos: h.photos,
        adoption: h.adoption,
        auth: auth,
        session: session,
        medications: clinical.repository,
      );
      await tester.pumpWidget(
        AuthApplication(session: session, router: router),
      );
      await tester.pumpAndSettle();
      Navigator.of(
        tester.element(find.text('Quero Adotar (Visitante)')),
      ).pushNamed('/animal-management');
      await tester.pumpAndSettle();
      expect(find.byTooltip('Administração'), findsOneWidget);
      expect(find.text('Equipe e acessos'), findsNothing);
      await tester.tap(find.text('Calendário'));
      await tester.pumpAndSettle();
      expect(find.byType(MedicationCalendarPanel), findsOneWidget);
      final reads = clinical.repository.calls.length;
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(clinical.repository.calls.length, greaterThan(reads));
      await tester.tap(find.byTooltip('Administração'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Atualizar painel'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Administração'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Equipe e acessos'));
      await tester.pumpAndSettle();
      expect(find.text('Equipe indisponível.'), findsOneWidget);
    },
  );
  testWidgets(
    'editor finishes its read before binding sibling clinical readers',
    (tester) async {
      final h = PublicAppHarness();
      final gate = Completer<Result<ManagedAnimal>>();
      h.animals.handler = (_, _) => gate.future;
      const access = SessionAccess(
        level: AccessLevel.authorized,
        userId: 'staff',
        role: StaffRole.employee,
      );
      final auth = FakeAuthRepository()
        ..handler = (_, _) async => const Success(access);
      addTearDown(auth.dispose);
      final session = SessionViewModel(auth);
      addTearDown(session.dispose);
      await session.start();
      final clinical = FakeMedicationCompletionScenario();
      final router = AppRouter(
        animals: h.animals,
        favorites: h.favorites,
        photos: h.photos,
        adoption: h.adoption,
        auth: auth,
        session: session,
        medications: clinical.repository,
      );
      await tester.pumpWidget(
        AuthApplication(session: session, router: router),
      );
      await tester.pumpAndSettle();
      Navigator.of(
        tester.element(find.text('Quero Adotar (Visitante)')),
      ).pushNamed('/animal-editor', arguments: fixtureId(1));
      // Pump bounded frames while the intentionally delayed repository remains pending.
      for (var i = 0; i < 15; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(
        h.animals.calls.where((c) => c.method == 'getManagement'),
        hasLength(1),
      );
      gate.complete(Success(ManagedAnimal(animal: fixtureAnimal(1))));
      await tester.pumpAndSettle();
      final screen = tester.widget<AnimalEditorScreen>(
        find.byType(AnimalEditorScreen),
      );
      expect(screen.viewModel.canEdit, isTrue);
      expect(screen.managementViewModel!.canManageFocused, isTrue);
      expect(screen.medicationViewModel!.state.loadFailed, isFalse);
      expect(
        clinical.repository.calls.where((c) => c.method == 'listTreatments'),
        hasLength(1),
      );
    },
  );
  for (final existing in [false, true]) {
    testWidgets(
      'animal editor ${existing ? 'existing' : 'new'} wires clinical module and removes private content on logout',
      (tester) async {
        final h = PublicAppHarness();
        h.animals.handler = (_, _) async => () async {
          await Future<void>.delayed(const Duration(milliseconds: 30));
          return Success(ManagedAnimal(animal: fixtureAnimal(1)));
        }();
        var access = const SessionAccess(
          level: AccessLevel.authorized,
          userId: 'staff',
          role: StaffRole.employee,
        );
        final auth = FakeAuthRepository()
          ..handler = (_, _) async {
            await Future<void>.delayed(const Duration(milliseconds: 40));
            return Success(access);
          };
        addTearDown(auth.dispose);
        final session = SessionViewModel(auth);
        addTearDown(session.dispose);
        final started = session.start();
        await tester.pump(const Duration(milliseconds: 40));
        await started;
        final clinical = FakeMedicationCompletionScenario();
        final router = AppRouter(
          animals: h.animals,
          favorites: h.favorites,
          photos: h.photos,
          adoption: h.adoption,
          auth: auth,
          session: session,
          medications: clinical.repository,
        );
        await tester.pumpWidget(
          AuthApplication(session: session, router: router),
        );
        await tester.pumpAndSettle();
        Navigator.of(
          tester.element(find.text('Quero Adotar (Visitante)')),
        ).pushNamed(
          '/animal-editor',
          arguments: existing ? fixtureId(1) : null,
        );
        await tester.pumpAndSettle();
        expect(find.byType(AnimalEditorScreen), findsOneWidget);
        if (existing) {
          final screen = tester.widget<AnimalEditorScreen>(
            find.byType(AnimalEditorScreen),
          );
          expect(screen.viewModel.state.loadFailed, isFalse);
          expect(screen.viewModel.canEdit, isTrue);
          expect(screen.medicationViewModel!.state.loadFailed, isFalse);
          expect(screen.managementViewModel!.canManageFocused, isTrue);
          expect(
            clinical.repository.calls.any((c) => c.method == 'listTreatments'),
            isTrue,
          );
        } else {
          expect(clinical.repository.calls, isEmpty);
        }
        access = const SessionAccess();
        auth.events.add(Success(access));
        await tester.pumpAndSettle();
        expect(
          find.byType(AnimalEditorScreen, skipOffstage: false),
          findsNothing,
        );
        expect(find.text('Quero Adotar (Visitante)'), findsOneWidget);
      },
    );
  }
}
