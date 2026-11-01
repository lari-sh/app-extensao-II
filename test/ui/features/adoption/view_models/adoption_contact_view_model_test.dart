import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/domain/models/animal.dart';
import 'package:abrigo_dos_anjos/domain/repositories/adoption_contact_repository.dart';
import 'package:abrigo_dos_anjos/ui/features/adoption/view_models/adoption_contact_view_model.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import '../../../../support/public_fixtures.dart';
import '../../../../support/fakes/fake_animals_repository.dart';

class ContactFake implements AdoptionContactRepository {
  int calls = 0;
  @override
  Future<Result<Unit>> open(
    AdoptionChannel channel,
    PublicAnimal animal,
  ) async {
    calls++;
    return const Success(Unit.value);
  }
}

void main() {
  test(
    'loads public name and revalidates before opening without reporting sent',
    () async {
      final animals = FakeAnimalsRepository()
        ..handler = (_, args) async => Success(fixtureAnimal(1));
      final contact = ContactFake();
      final vm = AdoptionContactViewModel(animals, contact);
      addTearDown(vm.dispose);
      await vm.load(fixtureId(1));
      expect(vm.state.animalName, 'Luna 1');
      await vm.open(AdoptionChannel.whatsapp);
      expect(contact.calls, 1);
      expect(animals.calls.length, 2);
      expect(vm.state.message, isNull);
      expect(vm.state.contactNotice, isNot(contains('link')));
      animals.handler = (_, args) async =>
          Success(fixtureAnimal(1).copyWith(isPublished: false));
      await vm.open(AdoptionChannel.whatsapp);
      expect(contact.calls, 1);
      expect(vm.state.canContact, isFalse);
    },
  );
  test(
    'blocks duplicate commands and discards completion after dispose',
    () async {
      final animals = FakeAnimalsRepository()
        ..handler = (_, args) async => Success(fixtureAnimal(1));
      final contact = ContactFake();
      final vm = AdoptionContactViewModel(animals, contact);
      await vm.load(fixtureId(1));
      final waiting = Completer<Result<PublicAnimal>>();
      animals.handler = (_, args) => waiting.future;
      final pending = vm.open(AdoptionChannel.instagram);
      await vm.open(AdoptionChannel.facebook);
      vm.dispose();
      waiting.complete(Success(fixtureAnimal(1)));
      await pending;
      expect(contact.calls, 0);
    },
  );
  test(
    'ignores stale loads and turns repository errors into friendly messages',
    () async {
      final animals = FakeAnimalsRepository();
      final contact = ContactFake();
      final vm = AdoptionContactViewModel(animals, contact);
      addTearDown(vm.dispose);
      final old = Completer<Result<PublicAnimal>>();
      animals.handler = (_, args) => old.future;
      final first = vm.load(fixtureId(1));
      animals.handler = (_, args) async => Success(fixtureAnimal(2));
      await vm.load(fixtureId(2));
      old.complete(Success(fixtureAnimal(1)));
      await first;
      expect(vm.state.animalName, 'Luna 2');
      animals.handler = (_, args) async => throw StateError('secret');
      await vm.open(AdoptionChannel.whatsapp);
      expect(contact.calls, 0);
      expect(vm.state.opening, isFalse);
      expect(vm.state.message, contains('Não foi possível'));
      expect(vm.state.message, isNot(contains('secret')));
      await vm.retry();
      expect(vm.state.canContact, isFalse);
      expect(vm.state.loading, isFalse);
    },
  );
}
