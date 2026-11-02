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
      expect(find.text('Equipe'), findsOneWidget);
      await tester.tap(find.text('Calendário'));
      await tester.pumpAndSettle();
      expect(find.byType(MedicationCalendarPanel), findsOneWidget);
      final reads = clinical.repository.calls.length;
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(clinical.repository.calls.length, greaterThan(reads));
      await tester.tap(find.byTooltip('Atualizar painel'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Equipe'));
      await tester.pumpAndSettle();
      expect(find.text('Equipe indisponível.'), findsOneWidget);
    },
  );
  for (final existing in [false, true]) {
    testWidgets(
      'animal editor ${existing ? 'existing' : 'new'} wires clinical module and removes private content on logout',
      (tester) async {
        final h = PublicAppHarness();
        h.animals.handler = (_, _) async =>
            Success(ManagedAnimal(animal: fixtureAnimal(1)));
        var access = const SessionAccess(
          level: AccessLevel.authorized,
          userId: 'staff',
          role: StaffRole.employee,
        );
        final auth = FakeAuthRepository()
          ..handler = (_, _) async => Success(access);
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
        ).pushNamed(
          '/animal-editor',
          arguments: existing ? fixtureId(1) : null,
        );
        await tester.pumpAndSettle();
        expect(find.byType(AnimalEditorScreen), findsOneWidget);
        if (existing) {
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
