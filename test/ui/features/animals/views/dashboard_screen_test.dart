import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/ui/features/animals/views/dashboard_screen.dart';
import 'package:abrigo_dos_anjos/ui/features/animals/view_models/dashboard_view_model.dart';
import 'package:abrigo_dos_anjos/domain/models/animal.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import '../../../../support/fakes/fake_animals_repository.dart';
import '../../../../support/public_fixtures.dart';

void main() {
  testWidgets(
    'prototype dashboard switches list, updates status by menu and publishes confirmed animal',
    (tester) async {
      var animal = fixtureAnimal(1).copyWith(isPublished: false);
      final repo = FakeAnimalsRepository()
        ..handler = (method, args) async {
          if (method == 'getStatusCounts') {
            return Success<Map<AnimalStatus, int>>({
              for (final s in AnimalStatus.values)
                s: s == animal.status ? 1 : 0,
            });
          }
          if (method == 'listManagement') {
            return Success(
              ManagedAnimalPage(
                items: args.first == animal.status
                    ? [ManagedAnimal(animal: animal)]
                    : [],
                total: args.first == animal.status ? 1 : 0,
              ),
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
      final vm = DashboardViewModel(repo, isAuthorized: () => true);
      addTearDown(vm.dispose);
      await vm.load();
      await tester.pumpWidget(
        MaterialApp(home: DashboardScreen(viewModel: vm)),
      );
      expect(find.text('Kanban'), findsOneWidget);
      expect(find.text('Olá, equipe'), findsOneWidget);
      await tester.tap(find.text('Lista'));
      await tester.pumpAndSettle();
      expect(vm.state.listMode, true);
      await tester.tap(find.byTooltip('Ações de Luna 1'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mover para Em tratamento'));
      await tester.pumpAndSettle();
      expect(animal.status, AnimalStatus.treatment);
      expect(vm.state.counts[AnimalStatus.treatment], 1);
      await tester.tap(find.byTooltip('Ações de Luna 1'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Publicar no catálogo'));
      await tester.pumpAndSettle();
      expect(animal.isPublished, true);
      expect(find.text('Publicado'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
