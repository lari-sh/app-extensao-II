import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/data/repositories/animals_repository_impl.dart';
import 'package:abrigo_dos_anjos/data/models/animal_dto.dart';
import 'package:abrigo_dos_anjos/domain/models/animal.dart';
import 'package:abrigo_dos_anjos/domain/models/managed_animal_search_filter.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import 'package:abrigo_dos_anjos/utils/app_failure.dart';
import '../../support/fakes/fake_animals_service.dart';
import '../../support/public_fixtures.dart';

ManagedAnimalDto item({bool code = true}) => ManagedAnimalDto(
  animal: AnimalDto({
    ...fixtureDto(1).values,
    if (code) 'animal_code': 'A0001',
  }),
  clinicalNotes: 'Interno',
  careRecords: [],
);
void main() {
  test(
    'repository normalizes, forwards all filters and maps code/page',
    () async {
      final service = FakeAnimalsService()
        ..handler = (m, a) async => Success(
          ManagedAnimalsPageDto(items: [item()], total: 30, cursor: 'next'),
        );
      final result = await AnimalsRepositoryImpl(service).searchManagement(
        const ManagedAnimalSearchFilter(
          query: ' Luna ',
          color: ' preto ',
          species: AnimalSpecies.dog,
          sex: AnimalSex.female,
          size: AnimalSize.small,
          status: AnimalStatus.quarantine,
        ),
        cursor: 'previous',
      );
      final page = (result as Success<ManagedAnimalPage>).value;
      expect(page.items.single.animal.animalCode, 'A0001');
      expect(page.items.single.clinicalNotes, 'Interno');
      expect(page.total, 30);
      expect(page.cursor, 'next');
      expect(service.calls.single.arguments, [
        {
          'query': 'Luna',
          'color': 'preto',
          'species': 'dog',
          'sex': 'female',
          'size': 'small',
          'status': 'quarantine',
        },
        'previous',
      ]);
    },
  );
  test('invalid lengths never reach service', () async {
    final service = FakeAnimalsService();
    final repo = AnimalsRepositoryImpl(service);
    expect(
      (await repo.searchManagement(ManagedAnimalSearchFilter(query: 'x' * 81))
              as Failure)
          .failure
          .code,
      FailureCode.validation,
    );
    expect(
      await repo.searchManagement(
        const ManagedAnimalSearchFilter(),
        cursor: 'x' * 2049,
      ),
      isA<Failure>(),
    );
    expect(service.calls, isEmpty);
  });
  test('service failures and thrown transport errors do not escape', () async {
    final service = FakeAnimalsService()
      ..handler = (m, a) async =>
          Failure<ManagedAnimalsPageDto>(AppFailure(FailureCode.forbidden));
    final repo = AnimalsRepositoryImpl(service);
    expect(
      (await repo.searchManagement(
                const ManagedAnimalSearchFilter(query: 'Luna'),
              )
              as Failure)
          .failure
          .code,
      FailureCode.forbidden,
    );
    service.handler = (m, a) async => throw StateError('private error');
    expect(
      (await repo.searchManagement(const ManagedAnimalSearchFilter())
              as Failure)
          .failure
          .code,
      FailureCode.unknown,
    );
  });
  test(
    'missing new search identity is rejected while immutable legacy replay remains readable',
    () async {
      final service = FakeAnimalsService()
        ..handler = (m, a) async => Success(
          ManagedAnimalsPageDto(items: [item(code: false)], total: 1),
        );
      final repo = AnimalsRepositoryImpl(service);
      expect(
        await repo.searchManagement(const ManagedAnimalSearchFilter()),
        isA<Failure>(),
      );
      service.handler = (m, a) async => Success<Map<String, dynamic>?>({
        'animal': fixtureDto(1).values,
        'clinical_notes': 'Original',
        'care_records': [],
      });
      final replay = await repo.getOperation('x' * 32);
      expect(
        (replay as Success<ManagedAnimal?>).value!.animal.animalCode,
        isNull,
      );
      expect(replay.value!.clinicalNotes, 'Original');
    },
  );
}
