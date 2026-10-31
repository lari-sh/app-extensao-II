import '../../utils/app_failure.dart';
import '../models/animal_dto.dart';
import 'repository_result.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import 'package:abrigo_dos_anjos/domain/models/animal.dart';
import 'package:abrigo_dos_anjos/domain/models/animal_draft.dart';
import 'package:abrigo_dos_anjos/domain/models/animal_query.dart';
import '../../domain/repositories/animals_repository.dart';
import '../services/animals_service.dart';

class AnimalsRepositoryImpl implements AnimalsRepository {
  AnimalsRepositoryImpl(this.service);
  final AnimalsService service;

  PublicAnimal _animal(AnimalDto dto) {
    final data = dto.values;
    return PublicAnimal(
      id: data['id'] as String,
      name: data['name'] as String,
      species: AnimalSpecies.values.byName(data['species'] as String),
      sex: AnimalSex.values.byName(data['sex'] as String),
      size: AnimalSize.values.byName(data['size'] as String),
      approximateAge: data['approximate_age'] as String,
      publicDescription: data['public_description'] as String,
      status: AnimalStatus.values.byName(data['status'] as String),
      isPublished: data['is_published'] as bool,
      isVaccinated: data['is_vaccinated'] as bool,
      isNeutered: data['is_neutered'] as bool,
      primaryPhotoId: data['primary_photo_id'] as String?,
    );
  }

  @override
  Future<Result<AnimalPage>> listPublic(AnimalQuery query, {String? cursor}) =>
      mapRepositoryResult(
        () => service.listPublic(
          filters: {
            'name': query.name.trim(),
            if (query.species != null) 'species': query.species!.name,
            if (query.sex != null) 'sex': query.sex!.name,
            if (query.size != null) 'size': query.size!.name,
          },
          cursor: cursor,
        ),
        (page) => AnimalPage(
          items: page.items.map(_animal).toList(growable: false),
          total: page.total,
          cursor: page.cursor,
        ),
      );
  @override
  Future<Result<PublicAnimal>> getPublic(String id) async {
    if (!isAnimalId(id)) return Failure(AppFailure(FailureCode.notFound));
    return mapRepositoryResult(() => service.getPublic(id), _animal);
  }

  @override
  Future<Result<List<PublicAnimal>>> getVisibleByIds(Set<String> ids) async {
    final valid = ids.where(isAnimalId).toList();
    final animals = <PublicAnimal>[];
    for (var offset = 0; offset < valid.length; offset += 50) {
      final batch = valid.skip(offset).take(50).toSet();
      final result = await mapRepositoryResult(
        () => service.getVisibleByIds(batch),
        (rows) => rows.map(_animal).toList(growable: false),
      );
      if (result case Failure<List<PublicAnimal>>(:final failure)) {
        return Failure(failure);
      }
      animals.addAll((result as Success<List<PublicAnimal>>).value);
    }
    animals.sort((a, b) {
      final name = a.name.compareTo(b.name);
      return name == 0 ? a.id.compareTo(b.id) : name;
    });
    return Success(List.unmodifiable(animals));
  }

  @override
  Future<Result<ManagedAnimalPage>> listManagement({
    AnimalStatus? status,
    String? cursor,
  }) async => Failure(AppFailure(FailureCode.configuration));
  @override
  Future<Result<ManagedAnimal>> getManagement(String id) async =>
      Failure(AppFailure(FailureCode.configuration));
  @override
  Future<Result<Map<AnimalStatus, int>>> getStatusCounts() async =>
      Failure(AppFailure(FailureCode.configuration));
  @override
  Future<Result<ManagedAnimal>> saveAnimal(
    AnimalDraft draft,
    String operationKey,
  ) async => Failure(AppFailure(FailureCode.configuration));
  @override
  Future<Result<PublicAnimal>> setStatus(
    String id,
    AnimalStatus status,
    String operationKey,
  ) async => Failure(AppFailure(FailureCode.configuration));
  @override
  Future<Result<PublicAnimal>> setPublication(
    String id,
    bool published,
    String operationKey,
  ) async => Failure(AppFailure(FailureCode.configuration));
  @override
  Future<Result<ManagedAnimal?>> getOperation(String operationKey) async =>
      Failure(AppFailure(FailureCode.configuration));
}
