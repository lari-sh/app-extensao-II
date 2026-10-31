import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/ui/features/favorites/view_models/favorites_view_model.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import 'package:abrigo_dos_anjos/utils/app_failure.dart';
import '../../../../support/fakes/fake_animals_repository.dart';
import '../../../../support/fakes/fake_favorites_repository.dart';
import '../../../../support/fakes/fake_photo_repository.dart';
import '../../../../support/public_fixtures.dart';

void main() {
  test(
    'favorites show only visible animals and preserve state on storage failure',
    () async {
      final animals = FakeAnimalsRepository()
        ..handler = (_, args) async => Success([fixtureAnimal(1)]);
      final favorites = FakeFavoritesRepository()
        ..handler = (method, args) async => method == 'loadIds'
            ? Success({fixtureId(1), fixtureId(2)})
            : Failure<Set<String>>(AppFailure(FailureCode.unknown));
      final vm = FavoritesViewModel(animals, favorites, FakePhotoRepository());
      addTearDown(vm.dispose);
      await vm.load();
      expect(vm.state.items.single.id, fixtureId(1));
      expect(vm.state.items.single.isFavorite, isTrue);
      await vm.toggleFavorite(fixtureId(1));
      expect(vm.state.items.single.isFavorite, isTrue);
      expect(vm.state.updatingFavorites, isEmpty);
      expect(vm.state.message, isNotNull);
    },
  );
}
