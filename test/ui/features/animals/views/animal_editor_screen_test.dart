import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/ui/features/animals/view_models/animal_editor_view_model.dart';
import 'package:abrigo_dos_anjos/ui/features/animals/views/animal_editor_screen.dart';
import 'package:abrigo_dos_anjos/domain/models/animal.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import 'package:provider/provider.dart';
import 'package:abrigo_dos_anjos/ui/features/auth/views/protected_scope.dart';
import 'package:abrigo_dos_anjos/ui/features/auth/view_models/session_view_model.dart';
import 'package:abrigo_dos_anjos/ui/features/auth/view_models/login_view_model.dart';
import 'package:abrigo_dos_anjos/domain/models/session_access.dart';
import '../../../../support/fakes/fake_auth_repository.dart';
import '../../../../support/fakes/fake_animals_repository.dart';
import '../../../../support/public_fixtures.dart';
import 'package:abrigo_dos_anjos/ui/features/animals/view_models/managed_animals_view_model.dart';
import 'package:abrigo_dos_anjos/ui/features/animals/views/managed_animals_screen.dart';

void main() {
  testWidgets(
    'retained editor enables inputs again after access verification',
    (tester) async {
      var authorized = true;
      final vm = AnimalEditorViewModel(
        FakeAnimalsRepository(),
        isAuthorized: () => authorized,
      );
      addTearDown(vm.dispose);
      await tester.pumpWidget(
        MaterialApp(home: AnimalEditorScreen(viewModel: vm)),
      );
      final field = find.descendant(
        of: find.byKey(const ValueKey('animalName')),
        matching: find.byType(TextFormField),
      );
      authorized = false;
      vm.refreshAccess();
      await tester.pump();
      expect(tester.widget<TextFormField>(field).enabled, false);
      authorized = true;
      vm.refreshAccess();
      await tester.pump();
      expect(tester.widget<TextFormField>(field).enabled, true);
      await tester.enterText(field, 'Luna editada');
      expect(vm.state.draft.name, 'Luna editada');
    },
  );
  testWidgets(
    'public fields accept data and vaccination removal without overflow',
    (tester) async {
      final vm = AnimalEditorViewModel(FakeAnimalsRepository());
      addTearDown(vm.dispose);
      await tester.pumpWidget(
        MaterialApp(home: AnimalEditorScreen(viewModel: vm)),
      );
      Future<void> enter(String key, String value) async {
        final field = find.byKey(ValueKey(key));
        await tester.scrollUntilVisible(
          field,
          180,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.enterText(field, value);
        await tester.pump();
      }

      await enter('animalWeight', '4,25');
      await enter('animalColor', 'Branca');
      await enter('animalTemperament', 'Calma');
      await enter('animalLastDewormedOn', '29/02/2024');
      final add = find.text('Adicionar vacina');
      await tester.scrollUntilVisible(
        add,
        180,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(add);
      await tester.pump();
      await enter('vaccinationDate0', '29/02/2024');
      await enter('vaccineType0', 'V4');
      expect(vm.state.draft.vaccinations.single.vaccineType, 'V4');
      expect(vm.state.draft.lastDewormedOn, '2024-02-29');
      expect(vm.state.draft.weightKg, 4.25);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'private list displays remote animals and opens selected editor',
    (tester) async {
      final repository = FakeAnimalsRepository()
        ..handler = (_, _) async => Success(
          ManagedAnimalPage(
            items: [ManagedAnimal(animal: fixtureAnimal(1))],
            total: 1,
          ),
        );
      final vm = ManagedAnimalsViewModel(repository, isAuthorized: () => true);
      addTearDown(vm.dispose);
      await vm.load();
      await tester.pumpWidget(
        MaterialApp(
          home: ManagedAnimalsScreen(viewModel: vm),
          onGenerateRoute: (settings) => MaterialPageRoute(
            builder: (_) =>
                Scaffold(body: Text('Editar ${settings.arguments}')),
          ),
        ),
      );
      expect(find.text('1 animais cadastrados'), findsOneWidget);
      await tester.tap(find.text('Luna 1'));
      await tester.pumpAndSettle();
      expect(find.text('Editar ${fixtureId(1)}'), findsOneWidget);
    },
  );
  testWidgets(
    'real editor stays mounted but masked during expiry; same user resumes and logout discards',
    (tester) async {
      const staff = SessionAccess(level: AccessLevel.authorized, userId: 'u');
      final auth = FakeAuthRepository()
        ..handler = (method, _) async => method == 'signOut'
            ? const Success(Unit.value)
            : const Success(staff);
      addTearDown(auth.dispose);
      final session = SessionViewModel(auth);
      addTearDown(session.dispose);
      await session.start();
      final login = LoginViewModel(auth);
      addTearDown(login.dispose);
      late AnimalEditorViewModel editor;
      await tester.pumpWidget(
        MaterialApp(
          home: ProtectedScope(
            session: session,
            login: login,
            privateBuilder: () {
              editor = AnimalEditorViewModel(
                FakeAnimalsRepository(),
                isAuthorized: () => session.state.canAccessPrivate,
                accessEpoch: () => session.state.accessEpoch,
              );
              return ChangeNotifierProvider(
                create: (_) => editor,
                lazy: false,
                child: AnimalEditorScreen(viewModel: editor),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('animalName')),
        'Rascunho interno',
      );
      auth.events.add(
        const Success(
          SessionAccess(
            userId: 'u',
            interruption: AccessInterruption.recoverableExpiration,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Rascunho interno'), findsNothing);
      expect(editor.state.draft.name, 'Rascunho interno');
      editor.setName('Bloqueado');
      expect(editor.state.draft.name, 'Rascunho interno');
      final ticket = session.beginSignIn()!;
      session.completeSignIn(ticket, staff);
      await tester.pumpAndSettle();
      expect(find.text('Rascunho interno'), findsOneWidget);
      await session.signOut();
      await tester.pumpAndSettle();
      expect(editor.state.draft.name, '');
      expect(find.text('Rascunho interno'), findsNothing);
    },
  );
  testWidgets(
    'create fills fields and care then confirms persisted animal; edit loads private values',
    (tester) async {
      final repository = FakeAnimalsRepository()
        ..handler = (_, _) async => Success(
          ManagedAnimal(animal: fixtureAnimal(1), clinicalNotes: 'Interno'),
        );
      final vm = AnimalEditorViewModel(repository);
      addTearDown(vm.dispose);
      await tester.pumpWidget(
        MaterialApp(home: AnimalEditorScreen(viewModel: vm)),
      );
      for (final entry in {
        'animalName': 'Luna',
        'animalAge': '2 anos',
      }.entries) {
        final field = find.byKey(ValueKey(entry.key));
        await tester.ensureVisible(field);
        await tester.enterText(field, entry.value);
      }
      for (final entry in {
        'animalSpecies': 'Cachorro',
        'animalSex': 'Fêmea',
        'animalSize': 'Médio',
      }.entries) {
        final field = find.byKey(ValueKey(entry.key));
        await tester.ensureVisible(field);
        await tester.tap(field);
        await tester.pumpAndSettle();
        await tester.tap(find.text(entry.value).last);
        await tester.pumpAndSettle();
      }
      final care = find.text('Adicionar cuidado');
      await tester.scrollUntilVisible(
        care,
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(care);
      await tester.pump();
      final remove = find.text('Remover cuidado');
      await tester.ensureVisible(remove);
      await tester.pumpAndSettle();
      await tester.tap(remove);
      await tester.pump();
      expect(find.byKey(const ValueKey('careDescription0')), findsNothing);
      await tester.scrollUntilVisible(
        care,
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(care);
      await tester.pump();
      final description = find.byKey(const ValueKey('careDescription0'));
      await tester.ensureVisible(description);
      await tester.enterText(description, 'Registro de vacina');
      final save = find.text('Salvar animal');
      await tester.scrollUntilVisible(
        save,
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(find.text('Animal salvo com sucesso.'), findsOneWidget);
      final edit = AnimalEditorViewModel(repository);
      addTearDown(edit.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: AnimalEditorScreen(
            key: const ValueKey('edit'),
            viewModel: edit,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await edit.load(fixtureId(1));
      await tester.pumpAndSettle();
      expect(find.text('Luna 1'), findsOneWidget);
    },
  );
}
