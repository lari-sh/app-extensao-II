import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/data/repositories/animals_repository_impl.dart';
import 'package:abrigo_dos_anjos/data/models/animal_dto.dart';
import 'package:abrigo_dos_anjos/domain/models/animal.dart';
import 'package:abrigo_dos_anjos/domain/models/animal_query.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import 'package:abrigo_dos_anjos/utils/app_failure.dart';
import '../../support/fakes/fake_animals_service.dart';
import '../../support/public_fixtures.dart';

void main() {
  test(
    'favorite IDs use batches of fifty instead of losing items to API limits',
    () async {
      final service = FakeAnimalsService()
        ..handler = (_, args) async => Success(<AnimalDto>[]);
      await AnimalsRepositoryImpl(
        service,
      ).getVisibleByIds(Set.from(List.generate(121, (i) => fixtureId(i + 1))));
      expect(service.calls.length, 3);
      expect(
        service.calls.map(
          (call) => (call.arguments.first as Set<String>).length,
        ),
        [50, 50, 21],
      );
    },
  );
  test(
    'repository maps DTOs and forwards combined query and cursor to Service',
    () async {
      final service = FakeAnimalsService()
        ..handler = (method, args) async => Success(
          AnimalsPageDto(items: [fixtureDto(1)], total: 61, cursor: 'next'),
        );
      final result = await AnimalsRepositoryImpl(service).listPublic(
        const AnimalQuery(
          name: 'Luna',
          species: AnimalSpecies.dog,
          sex: AnimalSex.female,
          size: AnimalSize.medium,
        ),
        cursor: 'previous',
      );
      final page = (result as Success<AnimalPage>).value;
      expect(page.items.single.name, 'Luna 1');
      expect(page.total, 61);
      expect(page.cursor, 'next');
      expect(service.calls.single.arguments, [
        {'name': 'Luna', 'species': 'dog', 'sex': 'female', 'size': 'medium'},
        'previous',
      ]);
    },
  );
  test(
    'hidden detail and service failures stay typed, unexpected errors are sanitized',
    () async {
      final service = FakeAnimalsService()
        ..handler = (method, args) async =>
            Failure<AnimalDto>(AppFailure(FailureCode.notFound));
      final repo = AnimalsRepositoryImpl(service);
      expect(
        (await repo.getPublic(fixtureId(1)) as Failure).failure.code,
        FailureCode.notFound,
      );
      service.handler = (_, args) async => throw StateError('raw secret');
      expect(
        (await repo.getPublic(fixtureId(1)) as Failure).failure.code,
        FailureCode.unknown,
      );
    },
  );
  test(
    'favorites exclude malformed IDs before any query and batch large sets',
    () async {
      final service = FakeAnimalsService()
        ..handler = (method, args) async => Success(<AnimalDto>[fixtureDto(1)]);
      final result = await AnimalsRepositoryImpl(
        service,
      ).getVisibleByIds({'A0024', fixtureId(1)});
      expect(
        (result as Success<List<PublicAnimal>>).value.single.id,
        fixtureId(1),
      );
      expect(service.calls.single.arguments.first, {fixtureId(1)});
    },
  );
}
