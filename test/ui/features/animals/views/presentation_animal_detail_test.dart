import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/domain/models/animal.dart';
import 'package:abrigo_dos_anjos/domain/models/photo_content.dart';
import 'package:abrigo_dos_anjos/ui/features/animals/views/animal_detail_screen.dart';
import 'package:abrigo_dos_anjos/ui/features/animals/view_models/animal_detail_view_model.dart';
import 'package:abrigo_dos_anjos/utils/app_failure.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import '../../../../support/public_app_harness.dart';
import '../../../../support/presentation_fixtures.dart';

void main() {
  for (final slug in ['amora', 'bento', 'mel']) {
    testWidgets('$slug shows illustrative JPEG and complete public facts', (
      tester,
    ) async {
      final h = PublicAppHarness();
      final animal = presentationAnimal(slug);
      h.animals.handler = (_, _) async => Success(animal);
      h.photos.handler = (_, _) async => Success(
        PhotoContent(bytes: presentationPhoto(slug), mime: 'image/jpeg'),
      );
      final vm = AnimalDetailViewModel(
        h.animals,
        h.favorites,
        h.photos,
        h.adoption,
      );
      addTearDown(vm.dispose);
      await vm.load(animal.id);
      await tester.pumpWidget(
        MaterialApp(home: AnimalDetailScreen(viewModel: vm)),
      );
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('Foto de ${animal.name}'), findsOneWidget);
      expect(find.text(animal.name), findsOneWidget);
      expect(vm.state.publicInformation['Peso'], contains('kg'));
      expect(vm.state.publicInformation['Vacinas'], contains('Antirrábica'));
      expect(vm.state.publicInformation['Cor'], animal.color);
      expect(vm.state.publicInformation['Temperamento'], animal.temperament);
      expect(h.animals.calls.map((c) => c.method), ['getPublic']);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets(
    'failed read retries, waits for photo and falls back for damaged image',
    (tester) async {
      final h = PublicAppHarness();
      final first = Completer<Result<PublicAnimal>>();
      final photo = Completer<Result<PhotoContent>>();
      var reads = 0;
      final animal = presentationAnimal('bento');
      h.animals.handler = (_, _) {
        reads++;
        return reads == 1 ? first.future : Future.value(Success(animal));
      };
      h.photos.handler = (_, _) => photo.future;
      final vm = AnimalDetailViewModel(
        h.animals,
        h.favorites,
        h.photos,
        h.adoption,
      );
      addTearDown(vm.dispose);
      final loading = vm.load(animal.id);
      await tester.pumpWidget(
        MaterialApp(home: AnimalDetailScreen(viewModel: vm)),
      );
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      first.complete(Failure(AppFailure(FailureCode.network)));
      await loading;
      await tester.pumpAndSettle();
      expect(find.text('Tentar novamente'), findsOneWidget);
      await tester.tap(find.text('Tentar novamente'));
      await tester.pump();
      expect(find.byType(LinearProgressIndicator), findsWidgets);
      photo.complete(
        Success(PhotoContent(bytes: [1, 2, 3], mime: 'image/jpeg')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Bento'), findsOneWidget);
      expect(find.byIcon(Icons.pets_outlined), findsOneWidget);
      expect(reads, 2);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'unavailable sheet closes and backdrop returns to previous route',
    (tester) async {
      final h = PublicAppHarness();
      h.animals.handler = (_, _) async =>
          Failure<PublicAnimal>(AppFailure(FailureCode.notFound));
      final vm = AnimalDetailViewModel(
        h.animals,
        h.favorites,
        h.photos,
        h.adoption,
      );
      addTearDown(vm.dispose);
      await vm.load(presentationAnimal('mel').id);
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => AnimalDetailScreen(viewModel: vm),
                  ),
                ),
                child: const Text('Abrir ficha'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Abrir ficha'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Fechar detalhes'));
      await tester.pumpAndSettle();
      expect(find.text('Abrir ficha'), findsOneWidget);
      await tester.tap(find.text('Abrir ficha'));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(2, 100));
      await tester.pumpAndSettle();
      expect(find.text('Abrir ficha'), findsOneWidget);
    },
  );
}
