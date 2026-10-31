import 'package:flutter/widgets.dart';
import 'package:abrigo_dos_anjos/app/abrigo_app.dart';
import 'package:abrigo_dos_anjos/app/app_router.dart';
import 'package:abrigo_dos_anjos/domain/models/animal.dart';
import 'package:abrigo_dos_anjos/domain/models/animal_query.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import 'fakes/fake_animals_repository.dart';
import 'fakes/fake_favorites_repository.dart';
import 'fakes/fake_photo_repository.dart';
import 'fakes/fake_adoption_message_repository.dart';
import 'public_fixtures.dart';

class PublicAppHarness {
  final animals = FakeAnimalsRepository();
  final favorites = FakeFavoritesRepository();
  final photos = FakePhotoRepository();
  final adoption = FakeAdoptionMessageRepository();
  Set<String> ids = {fixtureId(1)};
  PublicAppHarness() {
    animals.handler = (method, args) async {
      if (method == 'getPublic') return Success(fixtureAnimal(1));
      if (method == 'getVisibleByIds') {
        return Success([
          if ((args.first as Set<String>).contains(fixtureId(1)))
            fixtureAnimal(1),
        ]);
      }
      final query = args.first as AnimalQuery;
      final items = [fixtureAnimal(1)]
          .where(
            (animal) =>
                animal.name.toLowerCase().contains(query.name.toLowerCase()),
          )
          .toList();
      return Success(AnimalPage(items: items, total: items.length));
    };
    favorites.handler = (method, args) async {
      if (method == 'setFavorite') {
        final id = args[0] as String;
        if (args[1] as bool) {
          ids.add(id);
        } else {
          ids.remove(id);
        }
      }
      return Success(Set<String>.of(ids));
    };
    adoption.handler = (_, args) async => const Success(Unit.value);
  }
  Widget app() => AbrigoApp(
    onGenerateRoute: AppRouter(
      animals: animals,
      favorites: favorites,
      photos: photos,
      adoption: adoption,
    ).onGenerateRoute,
  );
}
