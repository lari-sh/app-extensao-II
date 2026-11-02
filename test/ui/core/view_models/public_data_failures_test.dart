import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/ui/features/animals/view_models/catalog_view_model.dart';
import 'package:abrigo_dos_anjos/ui/features/favorites/view_models/favorites_view_model.dart';
import 'package:abrigo_dos_anjos/ui/features/animals/view_models/animal_detail_view_model.dart';
import 'package:abrigo_dos_anjos/domain/models/animal.dart';
import 'package:abrigo_dos_anjos/domain/models/photo_content.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import 'package:abrigo_dos_anjos/utils/app_failure.dart';
import '../../../support/public_app_harness.dart';
import '../../../support/public_fixtures.dart';

void main() {
  test(
    'catalog photo bytes are loaded after metadata without losing other cards',
    () async {
      final h = PublicAppHarness();
      h.animals.handler = (_, _) async => Success(
        AnimalPage(
          items: [
            fixtureAnimal(1).copyWith(primaryPhotoId: 'photo'),
            fixtureAnimal(2),
          ],
          total: 2,
        ),
      );
      h.photos.handler = (_, _) async =>
          const Success(PhotoContent(bytes: [1, 2, 3], mime: 'image/png'));
      final vm = CatalogViewModel(h.animals, h.favorites, h.photos);
      addTearDown(vm.dispose);
      await vm.load();
      await Future<void>.delayed(Duration.zero);
      expect(vm.state.items.first.photo, [1, 2, 3]);
      expect(vm.state.items.last.photo, isNull);
    },
  );
  for (final failure in [false, true]) {
    test(
      'favorite update ${failure ? 'exception' : 'typed failure'} clears pending marker and preserves confirmed state',
      () async {
        final h = PublicAppHarness();
        final vm = CatalogViewModel(h.animals, h.favorites, h.photos);
        addTearDown(vm.dispose);
        await vm.load();
        h.favorites.handler = (_, _) async {
          if (failure) throw StateError('private');
          return Failure<Set<String>>(AppFailure(FailureCode.network));
        };
        await vm.toggleFavorite(fixtureId(1));
        expect(vm.state.items.single.isFavorite, isTrue);
        expect(vm.state.updatingFavorites, isEmpty);
        expect(vm.state.message, isNotEmpty);
        expect(vm.state.message, isNot(contains('private')));
      },
    );
  }
  test('favorites storage failure prevents querying visible animals', () async {
    final h = PublicAppHarness();
    h.favorites.handler = (_, _) async =>
        Failure<Set<String>>(AppFailure(FailureCode.network));
    final vm = FavoritesViewModel(h.animals, h.favorites, h.photos);
    addTearDown(vm.dispose);
    await vm.load();
    expect(h.animals.calls, isEmpty);
    expect(vm.state.favoritesReady, isFalse);
    expect(vm.state.busy, isFalse);
  });
  test(
    'favorites list read failure and uncaught catalog read are safe and retryable',
    () async {
      final h = PublicAppHarness();
      h.animals.handler = (_, _) async =>
          Failure<List<PublicAnimal>>(AppFailure(FailureCode.notFound));
      final favorites = FavoritesViewModel(h.animals, h.favorites, h.photos);
      addTearDown(favorites.dispose);
      await favorites.load();
      expect(favorites.state.message, isNotEmpty);
      h.animals.handler = (_, _) async => throw StateError('private');
      final catalog = CatalogViewModel(h.animals, h.favorites, h.photos);
      addTearDown(catalog.dispose);
      await catalog.load();
      expect(catalog.state.busy, isFalse);
      expect(catalog.state.message, isNot(contains('private')));
    },
  );
  test(
    'invalid filters do not read data; valid combined filters clear explicitly',
    () async {
      final h = PublicAppHarness();
      final vm = CatalogViewModel(h.animals, h.favorites, h.photos);
      addTearDown(vm.dispose);
      await vm.setFilters(species: 'unknown');
      await vm.setFilters(sex: 'unknown');
      await vm.setFilters(size: 'unknown');
      expect(h.animals.calls, isEmpty);
      await vm.setFilters(species: 'cat', sex: 'male', size: 'large');
      expect(vm.speciesValue, 'cat');
      expect(vm.sexValue, 'male');
      expect(vm.sizeValue, 'large');
      await vm.setFilters(species: '', sex: '', size: '');
      expect(vm.state.query.species, isNull);
      expect(vm.state.query.sex, isNull);
      expect(vm.state.query.size, isNull);
    },
  );
  test(
    'duplicate favorite clicks are ignored while a write is pending',
    () async {
      final h = PublicAppHarness();
      final gate = Completer<Result<Set<String>>>();
      h.favorites.handler = (method, _) async =>
          method == 'loadIds' ? const Success(<String>{}) : gate.future;
      final vm = CatalogViewModel(h.animals, h.favorites, h.photos);
      addTearDown(vm.dispose);
      await vm.load();
      final changing = vm.toggleFavorite(fixtureId(1));
      await vm.toggleFavorite(fixtureId(1));
      gate.complete(Success({fixtureId(1)}));
      await changing;
      expect(
        h.favorites.calls.where((c) => c.method == 'setFavorite').length,
        1,
      );
    },
  );
  for (final outcome in [
    'notFound',
    'unpublished',
    'clipboardFailure',
    'exception',
    'success',
  ]) {
    test(
      'adoption interest revalidates availability before copying: $outcome',
      () async {
        final h = PublicAppHarness();
        final vm = AnimalDetailViewModel(
          h.animals,
          h.favorites,
          h.photos,
          h.adoption,
        );
        addTearDown(vm.dispose);
        await vm.load(fixtureId(1));
        if (outcome == 'notFound') {
          h.animals.handler = (_, _) async =>
              Failure<PublicAnimal>(AppFailure(FailureCode.notFound));
        }
        if (outcome == 'unpublished') {
          h.animals.handler = (_, _) async =>
              Success(fixtureAnimal(1).copyWith(isPublished: false));
        }
        if (outcome == 'clipboardFailure') {
          h.adoption.handler = (_, _) async =>
              Failure<Unit>(AppFailure(FailureCode.permissionDenied));
        }
        if (outcome == 'exception') {
          h.adoption.handler = (_, _) async => throw StateError('private');
        }
        await vm.copyInterest();
        expect(vm.state.copying, isFalse);
        expect(vm.state.message, isNotEmpty);
        expect(vm.state.message, isNot(contains('private')));
        if (outcome == 'notFound' || outcome == 'unpublished') {
          expect(h.adoption.calls, isEmpty);
          expect(vm.state.canAdopt, isFalse);
        } else {
          expect(h.adoption.calls.length, 1);
        }
      },
    );
  }
  test(
    'detail photo and favorites errors preserve public data and allow retry',
    () async {
      final h = PublicAppHarness();
      h.animals.handler = (_, _) async =>
          Success(fixtureAnimal(1).copyWith(primaryPhotoId: 'photo'));
      h.photos.handler = (_, _) async =>
          const Success(PhotoContent(bytes: [1, 2], mime: 'image/png'));
      h.favorites.handler = (_, _) async =>
          Failure<Set<String>>(AppFailure(FailureCode.network));
      final vm = AnimalDetailViewModel(
        h.animals,
        h.favorites,
        h.photos,
        h.adoption,
      );
      addTearDown(vm.dispose);
      await vm.load(fixtureId(1));
      expect(vm.state.photo, [1, 2]);
      expect(vm.state.hasAnimal, isTrue);
      expect(vm.canToggleFavorite, isFalse);
      h.animals.handler = (_, _) async => throw StateError('private');
      await vm.reload();
      expect(vm.state.busy, isFalse);
      expect(vm.state.hasAnimal, isFalse);
    },
  );
}
