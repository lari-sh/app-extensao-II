import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/ui/features/animals/views/managed_animals_screen.dart';
import 'package:abrigo_dos_anjos/ui/features/animals/view_models/managed_animals_view_model.dart';
import 'package:abrigo_dos_anjos/domain/models/animal.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import '../../../../support/fakes/fake_animals_repository.dart';
import '../../../../support/presentation_fixtures.dart';

void main() {
  testWidgets(
    'managed list paginates, refreshes and reloads after create or edit',
    (tester) async {
      final repo = FakeAnimalsRepository()
        ..handler = (_, args) async => Success(
          ManagedAnimalPage(
            items: [
              ManagedAnimal(
                animal: presentationAnimal(args.last == null ? 'amora' : 'mel'),
              ),
            ],
            total: 2,
            cursor: args.last == null ? 'next' : null,
          ),
        );
      final vm = ManagedAnimalsViewModel(repo, isAuthorized: () => true);
      addTearDown(vm.dispose);
      await vm.load();
      final opened = <Object?>[];
      await tester.pumpWidget(
        MaterialApp(
          home: ManagedAnimalsScreen(viewModel: vm),
          onGenerateRoute: (settings) {
            opened.add(settings.arguments);
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) =>
                  Scaffold(appBar: AppBar(), body: const Text('Editor')),
            );
          },
        ),
      );
      await tester.tap(find.text('Carregar mais'));
      await tester.pumpAndSettle();
      expect(vm.state.items.length, 2);
      await tester.tap(find.byTooltip('Atualizar animais'));
      await tester.pumpAndSettle();
      expect(vm.state.items.length, 1);
      await tester.tap(find.text('Amora'));
      await tester.pumpAndSettle();
      expect(opened.last, presentationAnimal('amora').id);
      final before = repo.calls.length;
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(repo.calls.length, greaterThan(before));
      await tester.tap(find.text('Cadastrar animal'));
      await tester.pumpAndSettle();
      expect(opened.last, isNull);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Amora'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
