import 'package:freezed_annotation/freezed_annotation.dart';
import 'clinical_record.dart';
part 'animal.freezed.dart';

enum AnimalSpecies { dog, cat }

enum AnimalSex { female, male }

enum AnimalSize { small, medium, large }

enum AnimalStatus { available, treatment, quarantine, adopted }

@freezed
abstract class PublicAnimal with _$PublicAnimal {
  const factory PublicAnimal({
    required String id,
    required String name,
    String? animalCode,
    required AnimalSpecies species,
    required AnimalSex sex,
    required AnimalSize size,
    required String approximateAge,
    @Default('') String publicDescription,
    @Default(AnimalStatus.available) AnimalStatus status,
    @Default(false) bool isPublished,
    @Default(false) bool isVaccinated,
    @Default(false) bool isNeutered,
    String? lastDewormedOn,
    String? temperament,
    double? weightKg,
    String? color,
    @Default([]) List<PublicVaccination> vaccinations,
    String? primaryPhotoId,
  }) = _PublicAnimal;
}

@freezed
abstract class ManagedAnimal with _$ManagedAnimal {
  const factory ManagedAnimal({
    required PublicAnimal animal,
    @Default('') String clinicalNotes,
    @Default([]) List<ClinicalRecord> careRecords,
  }) = _ManagedAnimal;
}

@freezed
abstract class AnimalPage with _$AnimalPage {
  const factory AnimalPage({
    required List<PublicAnimal> items,
    required int total,
    String? cursor,
  }) = _AnimalPage;
}

@freezed
abstract class ManagedAnimalPage with _$ManagedAnimalPage {
  const factory ManagedAnimalPage({
    required List<ManagedAnimal> items,
    required int total,
    String? cursor,
  }) = _ManagedAnimalPage;
}

@freezed
abstract class PublicVaccination with _$PublicVaccination {
  const factory PublicVaccination({
    required String appliedOn,
    required String vaccineType,
  }) = _PublicVaccination;
}
