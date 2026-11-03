import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/ui/features/animals/views/animal_editor_screen.dart';
import 'package:abrigo_dos_anjos/ui/features/animals/view_models/animal_editor_view_model.dart';
import 'package:abrigo_dos_anjos/domain/models/animal.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import 'package:abrigo_dos_anjos/utils/app_failure.dart';
import '../../../../support/fakes/fake_animals_repository.dart';
import '../../../../support/presentation_fixtures.dart';

Future<void> reveal(WidgetTester tester, Finder target) async {
  await tester.scrollUntilVisible(
    target,
    300,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'failed editor load retries and uncertain save keeps same operation',
    (tester) async {
      final animal = presentationAnimal('amora');
      var failedLoad = true;
      var saves = 0;
      final repo = FakeAnimalsRepository()
        ..handler = (m, a) async {
          if (m == 'getManagement') {
            return failedLoad
                ? Failure<ManagedAnimal>(AppFailure(FailureCode.network))
                : Success(ManagedAnimal(animal: animal));
          }
          if (m == 'getOperation') return const Success<ManagedAnimal?>(null);
          saves++;
          return saves == 1
              ? Failure<ManagedAnimal>(AppFailure(FailureCode.network))
              : Success(ManagedAnimal(animal: animal));
        };
      final vm = AnimalEditorViewModel(repo);
      addTearDown(vm.dispose);
      await vm.load(animal.id);
      await tester.pumpWidget(
        MaterialApp(home: AnimalEditorScreen(viewModel: vm)),
      );
      await reveal(tester, find.text('Tentar carregar novamente'));
      failedLoad = false;
      await tester.tap(find.text('Tentar carregar novamente'));
      await tester.pumpAndSettle();
      expect(vm.state.loadFailed, isFalse);
      vm.setName('Amora');
      await vm.save();
      await tester.pumpAndSettle();
      await reveal(tester, find.text('Verificar resultado'));
      await tester.tap(find.text('Verificar resultado'));
      await tester.pumpAndSettle();
      expect(vm.state.canRetryPending, isTrue);
      await tester.ensureVisible(find.text('Tentar salvar novamente'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tentar salvar novamente'));
      await tester.pumpAndSettle();
      expect(vm.state.savedId, animal.id);
      expect(saves, 2);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'vaccine removal and care-kind selection remain independent public and private edits',
    (tester) async {
      final vm = AnimalEditorViewModel(FakeAnimalsRepository());
      addTearDown(vm.dispose);
      vm.addVaccination();
      await tester.pumpWidget(
        MaterialApp(home: AnimalEditorScreen(viewModel: vm)),
      );
      await reveal(tester, find.text('Remover vacina'));
      await tester.tap(find.text('Remover vacina'));
      await tester.pumpAndSettle();
      expect(vm.state.draft.vaccinations, isEmpty);
      await reveal(tester, find.text('Adicionar cuidado'));
      await tester.tap(find.text('Adicionar cuidado'));
      await tester.pumpAndSettle();
      final kind = find.byKey(const ValueKey('careKind0'));
      await tester.ensureVisible(kind);
      await tester.pumpAndSettle();
      await tester.tap(kind);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Vermifugação').last);
      await tester.pumpAndSettle();
      expect(vm.state.draft.careRecords.single.kind.name, 'deworming');
      expect(vm.state.draft.lastDewormedOn, isNull);
      expect(tester.takeException(), isNull);
    },
  );
}
