import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/data/repositories/animals_repository_impl.dart';
import 'package:abrigo_dos_anjos/domain/models/animal.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import '../../support/fakes/fake_animals_service.dart';
import '../../support/public_fixtures.dart';

void main() {
  test(
    'maps global counts and confirmed commands without guessing state',
    () async {
      final service = FakeAnimalsService()
        ..handler = (method, args) async => method == 'getStatusCounts'
            ? Success<Map<String, int>>({
                'available': 75,
                'treatment': 2,
                'quarantine': 0,
                'adopted': 1,
              })
            : Success(fixtureDto(1));
      final repo = AnimalsRepositoryImpl(service);
      expect(
        (await repo.getStatusCounts() as Success<Map<AnimalStatus, int>>)
            .value[AnimalStatus.available],
        75,
      );
      expect(
        (await repo.setStatus(fixtureId(1), AnimalStatus.adopted, 'a' * 32)
                as Success<PublicAnimal>)
            .value
            .status,
        AnimalStatus.available,
      );
      expect(service.calls.last.arguments, [fixtureId(1), 'adopted', 'a' * 32]);
      expect(
        await repo.setPublication(fixtureId(1), true, 'b' * 32),
        isA<Success>(),
      );
      expect(service.calls.last.arguments, [fixtureId(1), true, 'b' * 32]);
    },
  );
  test(
    'invalid ids never call service and unexpected failures stay typed',
    () async {
      final service = FakeAnimalsService();
      final repo = AnimalsRepositoryImpl(service);
      expect(
        await repo.setStatus('bad', AnimalStatus.available, 'a' * 32),
        isA<Failure>(),
      );
      expect(await repo.setPublication('bad', true, 'a' * 32), isA<Failure>());
      expect(service.calls, isEmpty);
      service.handler = (_, _) async => throw StateError('private');
      expect(await repo.getStatusCounts(), isA<Failure>());
      expect(
        await repo.setPublication(fixtureId(1), true, 'a' * 32),
        isA<Failure>(),
      );
    },
  );
}
