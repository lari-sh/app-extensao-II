import 'package:freezed_annotation/freezed_annotation.dart';
import 'medication_treatment.dart';
part 'medication_application.freezed.dart';

enum MedicationApplicationState { pending, completed, cancelled }

enum MedicationEventType { completed, completionReversed, cancelled }

@freezed
abstract class MedicationApplication with _$MedicationApplication {
  const MedicationApplication._();
  const factory MedicationApplication({
    required String id,
    required String treatmentId,
    required String animalId,
    required String animalName,
    required String medicationName,
    @Default('') String instructions,
    required int revision,
    required int version,
    required DateTime scheduledAt,
    required String scheduledLocalDate,
    required String scheduledLocalTime,
    @Default(MedicationApplicationState.pending)
    MedicationApplicationState state,
    String? performedBy,
    String? actorLabel,
    DateTime? performedAt,
    String? performedLocalDate,
    String? performedLocalTime,
  }) = _MedicationApplication;
  bool isOverdue(DateTime serverNow) =>
      state == MedicationApplicationState.pending &&
      scheduledAt.isBefore(serverNow);
  bool isDue(DateTime serverNow) =>
      state == MedicationApplicationState.pending &&
      !scheduledAt.isAfter(serverNow);
}

@freezed
abstract class MedicationApplicationEvent with _$MedicationApplicationEvent {
  const factory MedicationApplicationEvent({
    required String id,
    required String applicationId,
    required MedicationEventType type,
    required String actorId,
    required String actorLabel,
    required DateTime occurredAt,
    required String occurredLocalDate,
    required String occurredLocalTime,
    required int applicationVersion,
    String? reason,
  }) = _MedicationApplicationEvent;
}

@freezed
abstract class MedicationCommandResult with _$MedicationCommandResult {
  const factory MedicationCommandResult({
    required String operationKey,
    required DateTime serverNow,
    MedicationTreatment? treatment,
    MedicationApplication? application,
    MedicationApplicationEvent? event,
    @Default(0) int cancelledCount,
  }) = _MedicationCommandResult;
}
