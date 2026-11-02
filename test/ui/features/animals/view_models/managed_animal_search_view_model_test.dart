import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/ui/features/animals/view_models/managed_animal_search_view_model.dart';
import 'package:abrigo_dos_anjos/domain/models/animal.dart';
import 'package:abrigo_dos_anjos/domain/models/managed_animal_search_filter.dart';
import 'package:abrigo_dos_anjos/domain/models/photo_content.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import 'package:abrigo_dos_anjos/utils/app_failure.dart';
import '../../../../support/fakes/fake_animals_repository.dart';
import '../../../../support/fakes/fake_photo_repository.dart';
import '../../../../support/public_fixtures.dart';

ManagedAnimal item(int n, {String? photo}) => ManagedAnimal(
  animal: fixtureAnimal(
    n,
  ).copyWith(animalCode: 'A000$n', primaryPhotoId: photo),
);
void main() {
  testWidgets(
    'typing debounces; submit cancels timer; empty restores normal mode',
    (tester) async {
      final r = FakeAnimalsRepository()
        ..handler = (m, a) async =>
            Success(ManagedAnimalPage(items: [item(1)], total: 1));
      final vm = ManagedAnimalSearchViewModel(
        r,
        FakePhotoRepository(),
        isAuthorized: () => true,
      );
      addTearDown(vm.dispose);
      vm.setQuery('L');
      vm.setQuery('Luna');
      await tester.pump(const Duration(milliseconds: 299));
      expect(r.calls, isEmpty);
      await tester.pump(const Duration(milliseconds: 1));
      await tester.pump();
      expect(r.calls, hasLength(1));
      expect(vm.state.items, hasLength(1));
      expect(vm.countLabel, '1 animal encontrado');
      vm.setQuery('Bento');
      await vm.search();
      await tester.pump(const Duration(seconds: 1));
      expect(r.calls, hasLength(2));
      await vm.clearText();
      expect(vm.showGlobalResults, false);
      expect(vm.state.items, isEmpty);
    },
  );
  test(
    'draft cancellation, all five chips, remove, clear text versus clear all',
    () async {
      final r = FakeAnimalsRepository()
        ..handler = (m, a) async =>
            const Success(ManagedAnimalPage(items: [], total: 0));
      final vm = ManagedAnimalSearchViewModel(
        r,
        FakePhotoRepository(),
        isAuthorized: () => true,
      );
      addTearDown(vm.dispose);
      vm.setQuery('Luna');
      vm.beginFilters();
      vm.updateDraft(
        const ManagedAnimalSearchFilter(species: AnimalSpecies.dog),
      );
      vm.cancelFilters();
      expect(vm.state.filter.species, isNull);
      vm.updateDraft(
        const ManagedAnimalSearchFilter(
          species: AnimalSpecies.cat,
          sex: AnimalSex.male,
          size: AnimalSize.large,
          status: AnimalStatus.adopted,
          color: ' preto ',
        ),
      );
      await vm.applyFilters();
      expect(vm.state.filter.query, 'Luna');
      expect(vm.chips, hasLength(5));
      await vm.clearText();
      expect(vm.showGlobalResults, true);
      expect(vm.chips, hasLength(5));
      for (final key in ['species', 'sex', 'size', 'status', 'color']) {
        await vm.removeFilter(key);
      }
      expect(vm.showGlobalResults, false);
      vm.setQuery('Luna');
      vm.beginFilters();
      await vm.clearFilters();
      expect(vm.state.filter.query, 'Luna');
      vm.clearAll();
      expect(vm.state.filter, const ManagedAnimalSearchFilter());
    },
  );
  test(
    'late pages and photos cannot replace a newer search or revoked session',
    () async {
      final a = Completer<Result<ManagedAnimalPage>>(),
          b = Completer<Result<ManagedAnimalPage>>();
      final photo = Completer<Result<PhotoContent>>();
      final r = FakeAnimalsRepository()
        ..handler = (m, args) => rQuery(args) == 'first' ? a.future : b.future;
      final p = FakePhotoRepository()..handler = (m, args) => photo.future;
      var allowed = true, epoch = 0, private = 0;
      final vm = ManagedAnimalSearchViewModel(
        r,
        p,
        isAuthorized: () => allowed,
        accessEpoch: () => epoch,
        privateGeneration: () => private,
      );
      addTearDown(vm.dispose);
      vm.setQuery('first');
      final first = vm.search();
      vm.setQuery('second');
      final second = vm.search();
      b.complete(
        Success(ManagedAnimalPage(items: [item(2, photo: 'photo')], total: 1)),
      );
      await second;
      a.complete(Success(ManagedAnimalPage(items: [item(1)], total: 1)));
      await first;
      expect(vm.state.items.single.animal.id, fixtureId(2));
      allowed = false;
      epoch++;
      private++;
      vm.refreshAccess();
      photo.complete(
        const Success(PhotoContent(bytes: [1], mime: 'image/jpeg')),
      );
      await Future<void>.delayed(Duration.zero);
      expect(vm.state.items, isEmpty);
      expect(vm.state.photos, isEmpty);
      expect(vm.canSearch, false);
      await vm.search();
      vm.setQuery('blocked');
      expect(vm.state.filter.hasCriteria, false);
    },
  );
  test(
    'pagination preserves criteria, rejects duplicate cursor/items and sanitizes failures',
    () async {
      var page = 0;
      final r = FakeAnimalsRepository()
        ..handler = (m, args) async {
          page++;
          return Success(
            ManagedAnimalPage(
              items: [item(page == 1 ? 1 : 2)],
              total: 2,
              cursor: 'next',
            ),
          );
        };
      final vm = ManagedAnimalSearchViewModel(
        r,
        FakePhotoRepository(),
        isAuthorized: () => true,
      );
      addTearDown(vm.dispose);
      vm.setQuery('Luna');
      await vm.search();
      expect(vm.canLoadMore, true);
      await vm.search(next: true);
      expect(vm.state.message, isNotNull);
      expect(vm.state.cursor, isNull);
      r.handler = (m, args) async =>
          Failure<ManagedAnimalPage>(AppFailure(FailureCode.network));
      await vm.search();
      expect(vm.state.message, contains('conexão'));
      r.handler = (m, args) async => throw StateError('secret');
      await vm.search();
      expect(vm.state.message, isNot(contains('secret')));
      vm.setQuery('x' * 81);
      await vm.search();
      expect(vm.state.message, contains('80'));
      expect(vm.state.loading, false);
    },
  );
  test(
    'authorization denial and disposal discard all pending private state',
    () async {
      var allowed = true, denied = false, disposed = false;
      final r = FakeAnimalsRepository()
        ..handler = (m, args) async =>
            Failure<ManagedAnimalPage>(AppFailure(FailureCode.forbidden));
      final vm = ManagedAnimalSearchViewModel(
        r,
        FakePhotoRepository(),
        isAuthorized: () => allowed,
        authorize: () async => !denied,
        onDispose: () => disposed = true,
      );
      vm.setQuery('Luna');
      await vm.search();
      expect(vm.state.items, isEmpty);
      expect(vm.state.filter.hasCriteria, false);
      denied = true;
      vm.setQuery('Luna');
      await vm.search();
      expect(vm.state.loading, false);
      vm.setQuery('Luna');
      vm.dispose();
      expect(disposed, true);
      expect(vm.state.items, isEmpty);
      vm.refreshAccess();
      expect(vm.canSearch, false);
    },
  );
  test(
    'valid pagination, photo success and private generation changes',
    () async {
      var page = 0, generation = 0;
      final r = FakeAnimalsRepository()
        ..handler = (m, args) async => Success(
          ManagedAnimalPage(
            items: [item(++page, photo: 'photo')],
            total: 2,
            cursor: page == 1 ? 'next' : null,
          ),
        );
      final p = FakePhotoRepository()
        ..handler = (m, args) async =>
            const Success(PhotoContent(bytes: [1, 2], mime: 'image/jpeg'));
      final vm = ManagedAnimalSearchViewModel(
        r,
        p,
        isAuthorized: () => true,
        privateGeneration: () => generation,
      );
      addTearDown(vm.dispose);
      await vm.search(next: true);
      expect(r.calls, isEmpty);
      vm.setQuery('Luna');
      await vm.search();
      await Future<void>.delayed(Duration.zero);
      expect(vm.state.photos[fixtureId(1)], [1, 2]);
      await vm.search(next: true);
      expect(vm.state.items, hasLength(2));
      expect(vm.canLoadMore, false);
      expect(vm.countLabel, '2 animais encontrados');
      generation++;
      vm.refreshAccess();
      expect(vm.state.items, isEmpty);
    },
  );
  test(
    'photo access denial clears results; image transport errors are optional',
    () async {
      final r = FakeAnimalsRepository()
        ..handler = (m, args) async => Success(
          ManagedAnimalPage(items: [item(1, photo: 'photo')], total: 1),
        );
      final p = FakePhotoRepository()
        ..handler = (m, args) async => throw StateError('image');
      final vm = ManagedAnimalSearchViewModel(r, p, isAuthorized: () => true);
      addTearDown(vm.dispose);
      vm.setQuery('Luna');
      await vm.search();
      await Future<void>.delayed(Duration.zero);
      expect(vm.state.items, hasLength(1));
      p.handler = (m, args) async =>
          Failure<PhotoContent>(AppFailure(FailureCode.network));
      await vm.search();
      await Future<void>.delayed(Duration.zero);
      expect(vm.state.photos, isEmpty);
      p.handler = (m, args) async =>
          Failure<PhotoContent>(AppFailure(FailureCode.unauthenticated));
      await vm.search();
      await Future<void>.delayed(Duration.zero);
      expect(vm.state.items, isEmpty);
    },
  );
  test(
    'presentation derives characteristics and approved Portuguese labels',
    () {
      final vm = ManagedAnimalSearchViewModel(
        FakeAnimalsRepository(),
        FakePhotoRepository(),
        isAuthorized: () => true,
      );
      addTearDown(vm.dispose);
      final animal = item(1).animal;
      expect(vm.subtitle(animal), contains('Cor não informada'));
      expect(vm.statusLabel(animal), contains('Disponível'));
      expect(vm.publicationLabel(animal), 'Publicado');
      expect(
        vm.publicationLabel(animal.copyWith(isPublished: false)),
        'Privado',
      );
    },
  );
}

String rQuery(List<Object?> args) =>
    (args.first as ManagedAnimalSearchFilter).query;
