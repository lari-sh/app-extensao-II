import 'package:abrigo_dos_anjos/data/models/animal_dto.dart';
import 'package:abrigo_dos_anjos/domain/models/clinical_record.dart';
import 'package:abrigo_dos_anjos/domain/models/animal_draft.dart';
import 'package:abrigo_dos_anjos/utils/app_failure.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/data/repositories/animals_repository_impl.dart';
import 'package:abrigo_dos_anjos/domain/models/animal.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import '../../support/fakes/fake_animals_service.dart';
import '../../support/public_fixtures.dart';

void main() {
  test(
    'management maps public vaccines and private records and serializes trimmed care',
    () async {
      final dto = ManagedAnimalDto(
        animal: AnimalDto.fromJson({
          ...fixtureDto(1).values,
          'vaccinations': [
            {'applied_on': '2024-02-29', 'vaccine_type': 'V4'},
          ],
        }),
        clinicalNotes: 'Interno',
        careRecords: [
          {'id': 'record', 'kind': 'medication', 'description': 'Acompanhar'},
        ],
      );
      final service = FakeAnimalsService()
        ..handler = (_, _) async => Success(dto);
      final repo = AnimalsRepositoryImpl(service);
      final result =
          await repo.getManagement(fixtureId(1)) as Success<ManagedAnimal>;
      expect(result.value.animal.vaccinations.single.vaccineType, 'V4');
      expect(
        result.value.careRecords.single.kind,
        ClinicalRecordKind.medication,
      );
      await repo.saveAnimal(
        const AnimalDraft(
          name: 'Luna',
          species: AnimalSpecies.dog,
          sex: AnimalSex.female,
          size: AnimalSize.small,
          approximateAge: '2 anos',
          careRecords: [
            ClinicalRecord(
              kind: ClinicalRecordKind.medication,
              description: ' Acompanhar ',
            ),
          ],
        ),
        'k' * 32,
      );
      final payload = service.calls.last.arguments.first as Map;
      expect(payload['care_records'], [
        {'kind': 'medication', 'description': 'Acompanhar'},
      ]);
    },
  );
  test(
    'favorite batches propagate a service failure and sort homonyms by stable id',
    () async {
      final service = FakeAnimalsService()
        ..handler = (_, _) async => Success([
          AnimalDto.fromJson({...fixtureDto(2).values, 'name': 'Luna'}),
          AnimalDto.fromJson({...fixtureDto(1).values, 'name': 'Luna'}),
        ]);
      final repo = AnimalsRepositoryImpl(service);
      final result =
          await repo.getVisibleByIds({fixtureId(2), fixtureId(1)})
              as Success<List<PublicAnimal>>;
      expect(result.value.map((a) => a.id), [fixtureId(1), fixtureId(2)]);
      service.handler = (_, _) async =>
          Failure<List<AnimalDto>>(AppFailure(FailureCode.network));
      expect(await repo.getVisibleByIds({fixtureId(1)}), isA<Failure>());
    },
  );

  test(
    'private pagination maps column, cursor and aggregate without using page length as total',
    () async {
      final service = FakeAnimalsService()
        ..handler = (method, args) async => Success(
          ManagedAnimalsPageDto(
            items: [
              ManagedAnimalDto(
                animal: fixtureDto(1),
                clinicalNotes: 'Privado',
                careRecords: [],
              ),
            ],
            total: 75,
            cursor: 'next',
          ),
        );
      final repo = AnimalsRepositoryImpl(service);
      final result =
          await repo.listManagement(
                status: AnimalStatus.treatment,
                cursor: 'previous',
              )
              as Success<ManagedAnimalPage>;
      expect(result.value.total, 75);
      expect(result.value.items.single.clinicalNotes, 'Privado');
      expect(result.value.cursor, 'next');
      expect(service.calls.single.arguments, ['treatment', 'previous']);
    },
  );
  test(
    'all management service denials propagate without exposing SDK errors',
    () async {
      final service = FakeAnimalsService()
        ..handler = (method, args) async {
          final failure = AppFailure(FailureCode.forbidden);
          if (method == 'getStatusCounts') {
            return Failure<Map<String, int>>(failure);
          }
          if (method == 'listManagement') {
            return Failure<ManagedAnimalsPageDto>(failure);
          }
          return Failure<AnimalDto>(failure);
        };
      final repo = AnimalsRepositoryImpl(service);
      for (final result in [
        await repo.getStatusCounts(),
        await repo.listManagement(),
        await repo.setStatus(fixtureId(1), AnimalStatus.available, 'a' * 32),
        await repo.setPublication(fixtureId(1), true, 'a' * 32),
      ]) {
        expect((result as Failure).failure.code, FailureCode.forbidden);
      }
    },
  );
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
