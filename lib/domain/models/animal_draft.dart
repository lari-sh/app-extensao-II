import 'package:freezed_annotation/freezed_annotation.dart';
import 'animal.dart';
import '../../utils/civil_date.dart';
import 'clinical_record.dart';
part 'animal_draft.freezed.dart';

@freezed
abstract class AnimalDraft with _$AnimalDraft {
  const AnimalDraft._();
  const factory AnimalDraft({
    String? id,
    String? lastDewormedOn,
    String? temperament,
    double? weightKg,
    String? color,
    @Default([]) List<PublicVaccination> vaccinations,

    @Default('') String name,
    AnimalSpecies? species,
    AnimalSex? sex,
    AnimalSize? size,
    @Default('') String approximateAge,
    @Default('') String publicDescription,
    @Default('') String clinicalNotes,
    @Default(false) bool isVaccinated,
    @Default(false) bool isNeutered,
    @Default([]) List<ClinicalRecord> careRecords,
  }) = _AnimalDraft;
  Map<String, String> validate({DateTime? now}) {
    final errors = <String, String>{};
    void text(String field, String value, int minimum, int maximum) {
      final length = value.trim().runes.length;
      if (length < minimum || length > maximum) errors[field] = 'length';
    }

    text('name', name, 1, 80);
    text('approximateAge', approximateAge, 1, 80);
    if (publicDescription.runes.length > 3000) {
      errors['publicDescription'] = 'length';
    }
    if (clinicalNotes.runes.length > 3000) errors['clinicalNotes'] = 'length';
    if (species == null) errors['species'] = 'required';
    if (sex == null) errors['sex'] = 'required';
    if (size == null) errors['size'] = 'required';
    for (var index = 0; index < careRecords.length; index++) {
      text(
        'careRecords.$index.description',
        careRecords[index].description,
        1,
        1000,
      );
    }
    if (lastDewormedOn != null &&
        !validApplicationDate(lastDewormedOn!, now: now))
      errors['lastDewormedOn'] = 'date';
    if ((temperament?.trim().runes.length ?? 0) > 120)
      errors['temperament'] = 'length';
    if ((color?.trim().runes.length ?? 0) > 80) errors['color'] = 'length';
    if (weightKg != null &&
        (!weightKg!.isFinite || weightKg! <= 0 || weightKg! > 1000))
      errors['weightKg'] = 'range';
    if (vaccinations.length > 100) errors['vaccinations'] = 'length';
    for (var i = 0; i < vaccinations.length; i++) {
      if (!validApplicationDate(vaccinations[i].appliedOn, now: now))
        errors['vaccinations.$i.appliedOn'] = 'date';
      text('vaccinations.$i.vaccineType', vaccinations[i].vaccineType, 1, 120);
    }
    return Map.unmodifiable(errors);
  }
}
