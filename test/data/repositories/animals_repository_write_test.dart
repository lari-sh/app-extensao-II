import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/data/repositories/animals_repository_impl.dart';
import 'package:abrigo_dos_anjos/data/models/animal_dto.dart';
import 'package:abrigo_dos_anjos/domain/models/animal.dart';
import 'package:abrigo_dos_anjos/domain/models/animal_draft.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import 'package:abrigo_dos_anjos/utils/app_failure.dart';
import '../../support/fakes/fake_animals_service.dart';
import '../../support/public_fixtures.dart';

void main() {
  final draft = AnimalDraft(
    name: 'Luna',
    approximateAge: '2 anos',
    species: AnimalSpecies.dog,
    sex: AnimalSex.female,
    size: AnimalSize.medium,
  );
  test(
    'real repository maps private data and writes only editable fields with stable key',
    () async {
      final service = FakeAnimalsService()
        ..handler = (method, args) async => Success(
          ManagedAnimalDto(
            animal: fixtureDto(1),
            clinicalNotes: 'Interno',
            careRecords: [],
          ),
        );
      final repository = AnimalsRepositoryImpl(service);
      final result = await repository.saveAnimal(draft, 'a' * 32);
      expect((result as Success<ManagedAnimal>).value.clinicalNotes, 'Interno');
      final call = service.calls.single;
      expect(call.arguments.last, 'a' * 32);
      final payload = call.arguments.first as Map;
      expect(payload.containsKey('status'), isFalse);
      expect(payload.containsKey('primary_photo_id'), isFalse);
      expect(await repository.getManagement(fixtureId(1)), isA<Success>());
    },
  );
  test(
    'invalid draft never reaches service; service denial and unexpected errors are typed',
    () async {
      final service = FakeAnimalsService();
      final repository = AnimalsRepositoryImpl(service);
      expect(
        (await repository.saveAnimal(const AnimalDraft(), 'a' * 32) as Failure)
            .failure
            .code,
        FailureCode.validation,
      );
      expect(service.calls, isEmpty);
      service.handler = (_, _) async =>
          Failure<ManagedAnimalDto>(AppFailure(FailureCode.forbidden));
      expect(
        (await repository.saveAnimal(draft, 'a' * 32) as Failure).failure.code,
        FailureCode.forbidden,
      );
      service.handler = (_, _) async => throw StateError('private');
      expect(await repository.getManagement(fixtureId(1)), isA<Failure>());
    },
  );
  test(
    'timeout after commit reconciles by same key without second save',
    () async {
      final service = FakeAnimalsService()
        ..handler = (method, args) async {
          if (method == 'saveAnimal') {
            return Failure<ManagedAnimalDto>(AppFailure(FailureCode.timeout));
          }
          return Success<Map<String, dynamic>?>({
            'animal': fixtureDto(1).values,
            'clinical_notes': 'Interno',
            'care_records': [],
          });
        };
      final repository = AnimalsRepositoryImpl(service);
      expect(await repository.saveAnimal(draft, 'a' * 32), isA<Failure>());
      expect(
        (await repository.getOperation('a' * 32) as Success<ManagedAnimal?>)
            .value
            ?.animal
            .id,
        fixtureId(1),
      );
      expect(service.calls.map((c) => c.method), [
        'saveAnimal',
        'getOperation',
      ]);
    },
  );
}
