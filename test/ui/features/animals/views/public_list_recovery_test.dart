import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/ui/core/widgets/public_animal_list.dart';
import 'package:abrigo_dos_anjos/ui/core/view_models/public_list_view_model.dart';
import 'package:abrigo_dos_anjos/ui/features/animals/view_models/catalog_view_model.dart';
import 'package:abrigo_dos_anjos/domain/models/animal.dart';
import 'package:abrigo_dos_anjos/domain/models/photo_content.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import 'package:abrigo_dos_anjos/utils/app_failure.dart';
import '../../../../support/public_app_harness.dart';
import '../../../../support/presentation_fixtures.dart';

void main() {
  testWidgets(
    'public list recovers favorites, loads JPEGs, paginates and refreshes after detail',
    (tester) async {
      final h = PublicAppHarness();
      var favoritesFail = true;
      final mel = presentationAnimal(
        'mel',
      ).copyWith(status: AnimalStatus.quarantine);
      final amora = presentationAnimal(
        'amora',
      ).copyWith(status: AnimalStatus.treatment);
      h.animals.handler = (_, a) async => Success(
        AnimalPage(
          items: a.last == null ? [mel] : [mel, amora],
          total: 2,
          cursor: a.last == null ? 'next' : null,
        ),
      );
      h.favorites.handler = (m, a) async => favoritesFail
          ? Failure<Set<String>>(AppFailure(FailureCode.network))
          : Success(<String>{if (m == 'setFavorite') a.first as String});
      h.photos.handler = (_, a) async => Success(
        PhotoContent(
          bytes: a.first == mel.id ? presentationPhoto('mel') : [1, 2, 3],
          mime: 'image/jpeg',
        ),
      );
      final vm = CatalogViewModel(h.animals, h.favorites, h.photos);
      addTearDown(vm.dispose);
      await vm.load();
      expect(vm.canToggleFavorite(mel.id), isFalse);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ListenableBuilder(
                listenable: vm,
                builder: (_, _) => PublicAnimalList(
                  viewModel: vm,
                  emptyMessage: 'Nenhum animal',
                ),
              ),
            ),
          ),
          onGenerateRoute: (settings) => MaterialPageRoute<void>(
            settings: settings,
            builder: (_) =>
                Scaffold(appBar: AppBar(), body: const Text('Ficha pública')),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('conectar'), findsOneWidget);
      favoritesFail = false;
      await tester.ensureVisible(find.text('Atualizar'));
      await tester.tap(find.text('Atualizar'));
      await tester.pumpAndSettle();
      expect(vm.canToggleFavorite(mel.id), isTrue);
      await tester.ensureVisible(find.text('Carregar mais'));
      await tester.tap(find.text('Carregar mais'));
      await tester.pumpAndSettle();
      expect(vm.state.items.length, 2);
      expect(vm.state.cursor, isNull);
      expect(find.text('Em quarentena'), findsOneWidget);
      expect(animalStatusLabel(AnimalStatus.adopted), 'Adotado');
      await tester.ensureVisible(find.byTooltip('Favoritar Mel'));
      await tester.tap(find.byTooltip('Favoritar Mel'));
      await tester.pumpAndSettle();
      expect(vm.state.items.first.isFavorite, isTrue);
      await tester.tap(find.text('Mel'));
      await tester.pumpAndSettle();
      expect(find.text('Ficha pública'), findsOneWidget);
      final calls = h.animals.calls.length;
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(h.animals.calls.length, greaterThan(calls));
      expect(tester.takeException(), isNull);
    },
  );
}
