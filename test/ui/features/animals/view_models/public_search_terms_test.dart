import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/ui/features/animals/view_models/catalog_view_model.dart';
import 'package:abrigo_dos_anjos/domain/models/animal.dart';
import 'package:abrigo_dos_anjos/domain/models/animal_query.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import '../../../../support/fakes/fake_animals_repository.dart';
import '../../../../support/fakes/fake_favorites_repository.dart';
import '../../../../support/fakes/fake_photo_repository.dart';

void main() {
  CatalogViewModel model(FakeAnimalsRepository animals) => CatalogViewModel(
    animals,
    FakeFavoritesRepository()
      ..handler = (_, _) async => const Success(<String>{}),
    FakePhotoRepository(),
  );
  for (final entry in <String, (AnimalSpecies?, AnimalSex?, String)>{
    'gata fêmea': (AnimalSpecies.cat, AnimalSex.female, ''),
    'gato macho': (AnimalSpecies.cat, AnimalSex.male, ''),
    'gato femea': (AnimalSpecies.cat, AnimalSex.female, ''),
    'GATAS FÊMEAS': (AnimalSpecies.cat, AnimalSex.female, ''),
    'gato': (AnimalSpecies.cat, null, ''),
    'macho': (null, AnimalSex.male, ''),
    'fêmea': (null, AnimalSex.female, ''),
    'cães fêmeas': (AnimalSpecies.dog, AnimalSex.female, ''),
    'cão macho': (AnimalSpecies.dog, AnimalSex.male, ''),
    'cadelas': (AnimalSpecies.dog, null, ''),
    'cachorro fêmea': (AnimalSpecies.dog, AnimalSex.female, ''),
    'CACHORRAS MACHOS': (AnimalSpecies.dog, AnimalSex.male, ''),
    'Lúna gata fêmea': (AnimalSpecies.cat, AnimalSex.female, 'Lúna'),
    '  Luna   Maria  ': (null, null, 'Luna Maria'),
    'Fêmea-Sol': (null, null, 'Fêmea-Sol'),
    '': (null, null, ''),
  }.entries) {
    test('public terms ${entry.key}', () async {
      final r = FakeAnimalsRepository()
        ..handler = (_, _) async =>
            const Success(AnimalPage(items: [], total: 0));
      final vm = model(r);
      addTearDown(vm.dispose);
      vm.setSearchInput(entry.key);
      expect(r.calls, isEmpty);
      await vm.submitSearch(entry.key);
      final q = r.calls.single.arguments.first as AnimalQuery;
      expect(q.species, entry.value.$1);
      expect(q.sex, entry.value.$2);
      expect(q.name, entry.value.$3);
      expect(vm.searchInput, entry.value.$3);
    });
  }
  test(
    'explicit controls override parsed category; other criteria persist until cleared',
    () async {
      final r = FakeAnimalsRepository()
        ..handler = (_, _) async =>
            const Success(AnimalPage(items: [], total: 0));
      final vm = model(r);
      addTearDown(vm.dispose);
      await vm.submitSearch('Luna gato macho', species: 'dog', size: 'small');
      expect(
        vm.state.query,
        const AnimalQuery(
          name: 'Luna',
          species: AnimalSpecies.dog,
          sex: AnimalSex.male,
          size: AnimalSize.small,
        ),
      );
      await vm.submitSearch('Bento');
      expect(vm.state.query.species, AnimalSpecies.dog);
      expect(vm.state.query.sex, AnimalSex.male);
      await vm.clearFilters();
      expect(vm.state.query, const AnimalQuery());
      expect(vm.searchInput, isEmpty);
    },
  );
  for (final input in ['gato cachorro', 'macho fêmea', 'x' * 81]) {
    test('invalid public query $input never reaches Repository', () async {
      final r = FakeAnimalsRepository();
      final vm = model(r);
      addTearDown(vm.dispose);
      await vm.submitSearch(input);
      expect(r.calls, isEmpty);
      expect(vm.state.message, isNotNull);
      expect(vm.searchInput, input);
      expect(vm.state.busy, isFalse);
    });
  }
  test(
    'rejected terms invalidate an older request and disposal never submits',
    () async {
      final gate = Completer<Result<AnimalPage>>();
      final r = FakeAnimalsRepository()..handler = (_, _) => gate.future;
      final vm = model(r);
      final old = vm.submitSearch('Luna');
      await Future<void>.delayed(Duration.zero);
      await vm.submitSearch('gato cachorro');
      gate.complete(const Success(AnimalPage(items: [], total: 99)));
      await old;
      expect(vm.state.total, 0);
      expect(vm.state.message, contains('apenas uma'));
      vm.dispose();
      vm.setSearchInput('Bento');
      await vm.submitSearch('Bento');
      expect(r.calls, hasLength(1));
    },
  );
}
