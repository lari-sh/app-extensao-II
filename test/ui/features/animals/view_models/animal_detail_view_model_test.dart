import 'dart:async';
import 'package:abrigo_dos_anjos/utils/app_failure.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/ui/features/animals/view_models/animal_detail_view_model.dart';
import 'package:abrigo_dos_anjos/domain/models/animal.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import '../../../../support/fakes/fake_animals_repository.dart';
import '../../../../support/fakes/fake_favorites_repository.dart';
import '../../../../support/fakes/fake_photo_repository.dart';
import '../../../../support/fakes/fake_adoption_message_repository.dart';
import '../../../../support/public_fixtures.dart';

void main() {
  test(
    'unexpected favorite storage exception preserves confirmed selection and hides internals',
    () async {
      final animals = FakeAnimalsRepository()
        ..handler = (_, _) async => Success(fixtureAnimal(1));
      final favorites = FakeFavoritesRepository()
        ..handler = (m, a) async {
          if (m == 'setFavorite') throw StateError('private storage details');
          return const Success(<String>{});
        };
      final vm = AnimalDetailViewModel(
        animals,
        favorites,
        FakePhotoRepository(),
        FakeAdoptionMessageRepository(),
      );
      addTearDown(vm.dispose);
      await vm.load(fixtureId(1));
      await vm.toggleFavorite();
      expect(vm.state.isFavorite, isFalse);
      expect(vm.state.changingFavorite, isFalse);
      expect(vm.state.message, 'Não foi possível atualizar os favoritos.');
    },
  );

  test(
    'public profile renders confirmed fields without private reads',
    () async {
      final animals = FakeAnimalsRepository()
        ..handler = (_, _) async => Success(
          fixtureAnimal(1).copyWith(
            lastDewormedOn: '2024-02-29',
            temperament: 'Calma',
            weightKg: 4.25,
            color: 'Branca',
            vaccinations: [
              const PublicVaccination(
                appliedOn: '2024-02-29',
                vaccineType: 'V4',
              ),
            ],
          ),
        );
      final vm = AnimalDetailViewModel(
        animals,
        FakeFavoritesRepository(),
        FakePhotoRepository(),
        FakeAdoptionMessageRepository(),
      );
      addTearDown(vm.dispose);
      await vm.load(fixtureId(1));
      expect(vm.state.publicInformation['Vacinas'], 'V4 • 29/02/2024');
      expect(vm.state.publicInformation['Vermifugado'], '29/02/2024');
      expect(vm.state.publicInformation['Peso'], '4,25 kg');
      expect(vm.state.publicInformation['Cor'], 'Branca');
      expect(vm.state.publicInformation['Temperamento'], 'Calma');
      expect(animals.calls.every((call) => call.method == 'getPublic'), true);
    },
  );
  test(
    'adoption capability is computed and copying revalidates visibility without sending',
    () async {
      var animal = fixtureAnimal(1);
      final animals = FakeAnimalsRepository()
        ..handler = (_, args) async => Success(animal);
      final copy = FakeAdoptionMessageRepository()
        ..handler = (_, args) async => const Success(Unit.value);
      final vm = AnimalDetailViewModel(
        animals,
        FakeFavoritesRepository(),
        FakePhotoRepository(),
        copy,
      );
      addTearDown(vm.dispose);
      await vm.load(animal.id);
      expect(vm.state.canAdopt, isTrue);
      expect(vm.state.photo, isNull);
      await vm.copyInterest();
      expect(copy.calls.length, 1);
      expect(vm.state.message, 'Mensagem copiada. Nenhum pedido foi enviado.');
      animal = animal.copyWith(status: AnimalStatus.treatment);
      await vm.load(animal.id);
      expect(vm.state.canAdopt, isFalse);
      await vm.copyInterest();
      expect(copy.calls.length, 1);
    },
  );
  test(
    'public detail maps tags and public flags without inventing planned clinical data',
    () async {
      final animals = FakeAnimalsRepository()
        ..handler = (_, _) async => Success(
          fixtureAnimal(1).copyWith(
            isVaccinated: true,
            isNeutered: true,
            publicDescription: 'História pública',
          ),
        );
      final vm = AnimalDetailViewModel(
        animals,
        FakeFavoritesRepository(),
        FakePhotoRepository(),
        FakeAdoptionMessageRepository(),
      );
      addTearDown(vm.dispose);
      await vm.load(fixtureId(1));
      expect(vm.state.hasAnimal, true);
      expect(vm.state.tags, ['Cachorro', 'Porte M', '2 anos', 'Fêmea']);
      expect(vm.state.publicInformation['Vacinas'], 'Não informado');
      expect(vm.state.publicInformation['Castrado'], 'Sim');
      expect(vm.state.publicInformation['Vermifugado'], 'Não informado');
      expect(vm.state.publicInformation['Temperamento'], 'Não informado');
      expect(animals.calls.every((call) => call.method == 'getPublic'), true);
      animals.handler = (_, _) async =>
          Failure<PublicAnimal>(AppFailure(FailureCode.notFound));
      await vm.reload();
      expect(vm.state.hasAnimal, false);
      expect(vm.state.tags, isEmpty);
      expect(vm.state.photo, isNull);
      expect(vm.state.canAdopt, false);
    },
  );
  test(
    'favorite is confirmed only after storage succeeds and failures preserve prior state',
    () async {
      final gate = Completer<Result<Set<String>>>();
      final favorites = FakeFavoritesRepository()
        ..handler = (method, _) async =>
            method == 'loadIds' ? const Success(<String>{}) : gate.future;
      final animals = FakeAnimalsRepository()
        ..handler = (_, _) async => Success(fixtureAnimal(1));
      final vm = AnimalDetailViewModel(
        animals,
        favorites,
        FakePhotoRepository(),
        FakeAdoptionMessageRepository(),
      );
      addTearDown(vm.dispose);
      await vm.load(fixtureId(1));
      final saving = vm.toggleFavorite();
      await Future<void>.delayed(Duration.zero);
      expect(vm.state.isFavorite, false);
      expect(vm.state.changingFavorite, true);
      gate.complete(Success({fixtureId(1)}));
      await saving;
      expect(vm.state.isFavorite, true);
      favorites.handler = (_, _) async =>
          Failure<Set<String>>(AppFailure(FailureCode.network));
      await vm.toggleFavorite();
      expect(vm.state.isFavorite, true);
      expect(vm.state.changingFavorite, false);
      expect(vm.state.message, isNotNull);
    },
  );
  test(
    'late favorite confirmation is ignored after closing the detail',
    () async {
      final gate = Completer<Result<Set<String>>>();
      final favorites = FakeFavoritesRepository()
        ..handler = (method, _) async =>
            method == 'loadIds' ? const Success(<String>{}) : gate.future;
      final animals = FakeAnimalsRepository()
        ..handler = (_, _) async => Success(fixtureAnimal(1));
      final vm = AnimalDetailViewModel(
        animals,
        favorites,
        FakePhotoRepository(),
        FakeAdoptionMessageRepository(),
      );
      await vm.load(fixtureId(1));
      final saving = vm.toggleFavorite();
      await Future<void>.delayed(Duration.zero);
      vm.dispose();
      gate.complete(Success({fixtureId(1)}));
      await saving;
      expect(vm.state.isFavorite, false);
    },
  );
  test(
    'favorite storage failure is visible and reload can recover without losing public boundaries',
    () async {
      final animals = FakeAnimalsRepository()
        ..handler = (_, _) async => Success(fixtureAnimal(1));
      final favorites = FakeFavoritesRepository()
        ..handler = (_, _) async =>
            Failure<Set<String>>(AppFailure(FailureCode.network));
      final vm = AnimalDetailViewModel(
        animals,
        favorites,
        FakePhotoRepository(),
        FakeAdoptionMessageRepository(),
      );
      addTearDown(vm.dispose);
      await vm.load(fixtureId(1));
      expect(vm.canToggleFavorite, false);
      expect(vm.state.message, contains('favoritos'));
      favorites.handler = (_, _) async => const Success(<String>{});
      await vm.reload();
      expect(vm.canToggleFavorite, true);
      expect(vm.state.message, isNull);
      expect(animals.calls.every((call) => call.method == 'getPublic'), true);
    },
  );
}
