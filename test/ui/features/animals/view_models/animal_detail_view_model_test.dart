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
      expect(vm.state.publicInformation['Vacinas'], 'Registradas');
      expect(vm.state.publicInformation['Castrado'], 'Sim');
      expect(
        vm.state.publicInformation['Vermifugado'],
        'Cadastro em planejamento',
      );
      expect(
        vm.state.publicInformation['Temperamento'],
        'Cadastro em planejamento',
      );
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
}
