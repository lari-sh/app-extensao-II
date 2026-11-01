import '../../utils/app_failure.dart';
import '../../utils/civil_date.dart';
import '../../domain/models/clinical_record.dart';
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
  String? _optional(String? text) =>
      text == null || text.trim().isEmpty ? null : text.trim();

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
      lastDewormedOn: data['last_dewormed_on'] as String?,
      temperament: data['temperament'] as String?,
      weightKg: data['weight_kg'] as double?,
      color: data['color'] as String?,
      vaccinations: ((data['vaccinations'] as List?) ?? [])
          .map(
            (item) => PublicVaccination(
              appliedOn: item['applied_on'] as String,
              vaccineType: item['vaccine_type'] as String,
            ),
          )
          .toList(),
    );
  }

  ManagedAnimal _managed(ManagedAnimalDto dto) => ManagedAnimal(
    animal: _animal(dto.animal),
    clinicalNotes: dto.clinicalNotes,
    careRecords: dto.careRecords
        .map(
          (record) => ClinicalRecord(
            id: record['id'] as String?,
            kind: ClinicalRecordKind.values.byName(record['kind'] as String),
            description: record['description'] as String,
          ),
        )
        .toList(),
  );
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
  }) => mapRepositoryResult(
    () => service.listManagement(status: status?.name, cursor: cursor),
    (page) => ManagedAnimalPage(
      items: page.items.map(_managed).toList(),
      total: page.total,
      cursor: page.cursor,
    ),
  );
  @override
  Future<Result<ManagedAnimal>> getManagement(String id) async {
    if (!isAnimalId(id)) return Failure(AppFailure(FailureCode.notFound));
    return mapRepositoryResult(() => service.getManagement(id), _managed);
  }

  @override
  Future<Result<Map<AnimalStatus, int>>> getStatusCounts() =>
      mapRepositoryResult(
        service.getStatusCounts,
        (counts) => Map.unmodifiable({
          for (final status in AnimalStatus.values)
            status: counts[status.name] ?? 0,
        }),
      );
  @override
  Future<Result<ManagedAnimal>> saveAnimal(
    AnimalDraft draft,
    String operationKey,
  ) async {
    if (draft.validate().isNotEmpty ||
        (draft.id != null && !isAnimalId(draft.id!))) {
      return Failure(AppFailure(FailureCode.validation));
    }
    return mapRepositoryResult(
      () => service.saveAnimal({
        'last_dewormed_on': draft.lastDewormedOn == null
            ? null
            : canonicalDate(draft.lastDewormedOn!),
        'temperament': _optional(draft.temperament),
        'weight_kg': draft.weightKg,
        'color': _optional(draft.color),
        'vaccinations': draft.vaccinations
            .map(
              (item) => {
                'applied_on': canonicalDate(item.appliedOn),
                'vaccine_type': item.vaccineType.trim(),
              },
            )
            .toList(),
        'id': draft.id,
        'name': draft.name.trim(),
        'species': draft.species!.name,
        'sex': draft.sex!.name,
        'size': draft.size!.name,
        'approximate_age': draft.approximateAge.trim(),
        'public_description': draft.publicDescription,
        'clinical_notes': draft.clinicalNotes,
        'is_vaccinated': draft.isVaccinated,
        'is_neutered': draft.isNeutered,
        'care_records': draft.careRecords
            .map(
              (record) => {
                'kind': record.kind.name,
                'description': record.description.trim(),
              },
            )
            .toList(),
      }, operationKey),
      _managed,
    );
  }

  @override
  Future<Result<PublicAnimal>> setStatus(
    String id,
    AnimalStatus status,
    String operationKey,
  ) async {
    if (!isAnimalId(id)) return Failure(AppFailure(FailureCode.validation));
    return mapRepositoryResult(
      () => service.setStatus(id, status.name, operationKey),
      _animal,
    );
  }

  @override
  Future<Result<PublicAnimal>> setPublication(
    String id,
    bool published,
    String operationKey,
  ) async {
    if (!isAnimalId(id)) return Failure(AppFailure(FailureCode.validation));
    return mapRepositoryResult(
      () => service.setPublication(id, published, operationKey),
      _animal,
    );
  }

  @override
  Future<Result<ManagedAnimal?>> getOperation(String operationKey) =>
      mapRepositoryResult(
        () => service.getOperation(operationKey),
        (data) =>
            data == null ? null : _managed(ManagedAnimalDto.fromJson(data)),
      );
}
