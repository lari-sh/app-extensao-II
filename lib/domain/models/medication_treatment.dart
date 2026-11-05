import 'package:freezed_annotation/freezed_annotation.dart';
import 'medication_schedule.dart';
part 'medication_treatment.freezed.dart';

enum MedicationTreatmentStatus { active, stopped }

bool isMedicationIdentifier(String value) => RegExp(
  r'^[a-fA-F0-9]{8}-(?:[a-fA-F0-9]{4}-){3}[a-fA-F0-9]{12}$',
).hasMatch(value);

@freezed
abstract class MedicationTreatment with _$MedicationTreatment {
  const factory MedicationTreatment({
    required String id,
    required String animalId,
    required int revision,
    required int version,
    required String medicationName,
    @Default('') String instructions,
    required MedicationSchedule schedule,
    @Default(MedicationTreatmentStatus.active) MedicationTreatmentStatus status,
  }) = _MedicationTreatment;
}

@freezed
abstract class MedicationTreatmentDraft with _$MedicationTreatmentDraft {
  const MedicationTreatmentDraft._();
  const factory MedicationTreatmentDraft({
    String? treatmentId,
    @Default('') String animalId,
    int? expectedRevision,
    int? expectedVersion,
    @Default('') String medicationName,
    @Default('') String instructions,
    @Default(MedicationSchedule()) MedicationSchedule schedule,
  }) = _MedicationTreatmentDraft;
  Map<String, String> validate() {
    final errors = Map<String, String>.of(schedule.validate());
    if (!isMedicationIdentifier(animalId)) errors['animalId'] = 'identifier';
    if (medicationName.trim().runes.isEmpty ||
        medicationName.trim().runes.length > 120) {
      errors['medicationName'] = 'length';
    }
    if (instructions.runes.length > 1000) errors['instructions'] = 'length';
    if (treatmentId != null &&
        (!isMedicationIdentifier(treatmentId!) ||
            (expectedRevision ?? 0) < 1 ||
            (expectedVersion ?? 0) < 1)) {
      errors['version'] = 'version';
    }
    if (treatmentId == null &&
        (expectedRevision != null || expectedVersion != null)) {
      errors['version'] = 'version';
    }
    return Map.unmodifiable(errors);
  }
}
