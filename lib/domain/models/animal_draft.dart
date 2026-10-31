import 'package:freezed_annotation/freezed_annotation.dart';
import 'animal.dart';
import 'clinical_record.dart';
part 'animal_draft.freezed.dart';

@freezed
abstract class AnimalDraft with _$AnimalDraft {
  const AnimalDraft._();
  const factory AnimalDraft({
    String? id,
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
  Map<String, String> validate() {
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
    return Map.unmodifiable(errors);
  }
}
