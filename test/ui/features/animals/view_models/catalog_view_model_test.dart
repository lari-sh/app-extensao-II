import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/ui/features/animals/view_models/catalog_view_model.dart';
import 'package:abrigo_dos_anjos/domain/models/animal.dart';
import 'package:abrigo_dos_anjos/domain/models/animal_query.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import 'package:abrigo_dos_anjos/utils/app_failure.dart';
import '../../../../support/fakes/fake_animals_repository.dart';
import '../../../../support/fakes/fake_favorites_repository.dart';
import '../../../../support/fakes/fake_photo_repository.dart';
import '../../../../support/public_fixtures.dart';

void main() {
  test('invalid filter is reported without calling repositories', () async {
    final animals = FakeAnimalsRepository();
    final vm = CatalogViewModel(
      animals,
      FakeFavoritesRepository(),
      FakePhotoRepository(),
    );
    await vm.setFilters(species: 'not-an-enum');
    expect(vm.state.message, 'Filtro inválido.');
    expect(animals.calls, isEmpty);
    vm.dispose();
  });
  test(
    'filters restart cursor and stale page never overwrites new query',
    () async {
      final old = Completer<Object?>();
      var count = 0;
      final animals = FakeAnimalsRepository()
        ..handler = (_, args) async {
          count++;
          if (count == 1) return old.future;
          return Success(AnimalPage(items: [fixtureAnimal(2)], total: 1));
        };
      final favorites = FakeFavoritesRepository()
        ..handler = (_, args) async => const Success(<String>{});
      final vm = CatalogViewModel(animals, favorites, FakePhotoRepository());
      addTearDown(vm.dispose);
      final first = vm.load();
      await Future<void>.delayed(Duration.zero);
      expect(vm.state.busy, isTrue);
      await vm.setFilters(name: 'Nova', species: 'dog');
      old.complete(
        Success(
          AnimalPage(items: [fixtureAnimal(1)], total: 61, cursor: 'old'),
        ),
      );
      await first;
      expect(vm.state.items.single.id, fixtureId(2));
      expect(vm.state.busy, isFalse);
      expect(vm.state.cursor, isNull);
      expect((animals.calls.last.arguments.first as AnimalQuery).name, 'Nova');
      expect(animals.calls.last.arguments.last, isNull);
    },
  );
  test(
    'failures finish loading with Portuguese message, disposal ignores completion',
    () async {
      final animals = FakeAnimalsRepository()
        ..handler = (_, args) async =>
            Failure<AnimalPage>(AppFailure(FailureCode.network));
      final favorites = FakeFavoritesRepository()
        ..handler = (_, args) async => const Success(<String>{});
      final vm = CatalogViewModel(animals, favorites, FakePhotoRepository());
      await vm.load();
      expect(vm.state.busy, isFalse);
      expect(vm.state.message, contains('conexão'));
      final delayed = Completer<Object?>();
      animals.handler = (_, args) => delayed.future;
      final future = vm.load();
      await Future<void>.delayed(Duration.zero);
      vm.dispose();
      delayed.complete(
        Success(AnimalPage(items: [fixtureAnimal(1)], total: 1)),
      );
      await future;
      expect(vm.state.items, isEmpty);
    },
  );
  for (final code in [
    FailureCode.network,
    FailureCode.timeout,
    FailureCode.configuration,
    FailureCode.notFound,
  ]) {
    test(
      'catalog failure matrix ${code.name} ends loading with Portuguese message',
      () async {
        final animals = FakeAnimalsRepository()
          ..handler = (_, _) async => Failure<AnimalPage>(AppFailure(code));
        final favorites = FakeFavoritesRepository()
          ..handler = (_, _) async => const Success(<String>{});
        final vm = CatalogViewModel(animals, favorites, FakePhotoRepository());
        addTearDown(vm.dispose);
        await vm.load();
        expect(vm.state.busy, false);
        expect(vm.state.items, isEmpty);
        expect(vm.state.message, isNotNull);
        expect(
          vm.state.message,
          anyOf(contains('Não foi possível'), contains('disponível')),
        );
      },
    );
  }
}
