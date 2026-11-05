import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/domain/models/animal.dart';
import 'package:abrigo_dos_anjos/ui/features/animals/views/animal_editor_screen.dart';
import 'package:abrigo_dos_anjos/ui/features/animals/view_models/animal_editor_view_model.dart';
import 'package:abrigo_dos_anjos/ui/features/animals/view_models/dashboard_view_model.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import '../../../../support/fakes/fake_animals_repository.dart';
import '../../../../support/public_fixtures.dart';

void main() {
  testWidgets(
    'editor changes confirmed situation and publication without saving unsaved clinical draft',
    (tester) async {
      var animal = fixtureAnimal(1).copyWith(isPublished: false);
      final repo = FakeAnimalsRepository()
        ..handler = (method, args) async {
          if (method == 'getManagement') {
            return Success(
              ManagedAnimal(animal: animal, clinicalNotes: 'Persistida'),
            );
          }
          if (method == 'setStatus') {
            animal = animal.copyWith(status: args[1] as AnimalStatus);
          }
          if (method == 'setPublication') {
            animal = animal.copyWith(isPublished: args[1] as bool);
          }
          return Success(animal);
        };
      final editor = AnimalEditorViewModel(repo);
      final management = DashboardViewModel(repo, isAuthorized: () => true);
      addTearDown(editor.dispose);
      addTearDown(management.dispose);
      await editor.load(fixtureId(1));
      editor.setNotes('Rascunho ainda não salvo');
      await management.loadFocused(fixtureId(1));
      await tester.pumpWidget(
        MaterialApp(
          home: AnimalEditorScreen(
            viewModel: editor,
            managementViewModel: management,
          ),
        ),
      );
      await tester.tap(
        find.widgetWithText(
          DropdownButtonFormField<AnimalStatus>,
          'Disponíveis',
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Em tratamento').last);
      await tester.pumpAndSettle();
      expect(animal.status, AnimalStatus.treatment);
      await tester.tap(find.byType(SwitchListTile));
      await tester.pumpAndSettle();
      expect(animal.isPublished, true);
      expect(editor.state.draft.clinicalNotes, 'Rascunho ainda não salvo');
      expect(repo.calls.where((call) => call.method == 'saveAnimal'), isEmpty);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('unsaved animal cannot publish or change situation', (
    tester,
  ) async {
    final repo = FakeAnimalsRepository();
    final editor = AnimalEditorViewModel(repo);
    final management = DashboardViewModel(repo, isAuthorized: () => true);
    addTearDown(editor.dispose);
    addTearDown(management.dispose);
    await management.loadFocused(null);
    await tester.pumpWidget(
      MaterialApp(
        home: AnimalEditorScreen(
          viewModel: editor,
          managementViewModel: management,
        ),
      ),
    );
    expect(
      tester.widget<SwitchListTile>(find.byType(SwitchListTile)).onChanged,
      isNull,
    );
    expect(management.canManageFocused, false);
    expect(repo.calls, isEmpty);
    expect(tester.takeException(), isNull);
  });
}
