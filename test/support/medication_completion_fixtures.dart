import 'package:abrigo_dos_anjos/domain/models/medication_application.dart';
import 'medication_fixtures.dart';

const medicationActorId = '57000000-0000-4000-8000-000000000001';
MedicationApplication pendingMedication() => MedicationApplication(
  id: medicationApplicationId,
  treatmentId: medicationTreatmentId,
  animalId: medicationAnimalId,
  animalName: 'Atena',
  medicationName: 'Amoxicilina 250 mg',
  instructions: '1 comprimido',
  revision: 1,
  version: 1,
  scheduledAt: DateTime.utc(2026, 11, 1, 11),
  scheduledLocalDate: '2026-11-01',
  scheduledLocalTime: '08:00',
);
MedicationCommandResult completedMedication(
  String key, {
  MedicationApplication? application,
}) {
  final pending = application ?? pendingMedication();
  final time = DateTime.utc(2026, 11, 1, 12, 6);
  return MedicationCommandResult(
    operationKey: key,
    serverNow: time,
    application: pending.copyWith(
      state: MedicationApplicationState.completed,
      version: pending.version + 1,
      performedBy: medicationActorId,
      actorLabel: 'Equipe de teste',
      performedAt: time,
      performedLocalDate: '2026-11-01',
      performedLocalTime: '09:06',
    ),
    event: MedicationApplicationEvent(
      id: '98000000-0000-4000-8000-${(pending.version + 1).toString().padLeft(12, '0')}',
      applicationId: pending.id,
      type: MedicationEventType.completed,
      actorId: medicationActorId,
      actorLabel: 'Equipe de teste',
      occurredAt: time,
      occurredLocalDate: '2026-11-01',
      occurredLocalTime: '09:06',
      applicationVersion: pending.version + 1,
    ),
  );
}

MedicationCommandResult reversedMedication(
  String key,
  MedicationApplication completed,
  String reason,
) {
  final time = DateTime.utc(2026, 11, 1, 12, 7);
  return MedicationCommandResult(
    operationKey: key,
    serverNow: time,
    application: completed.copyWith(
      state: MedicationApplicationState.pending,
      version: completed.version + 1,
      performedBy: null,
      actorLabel: null,
      performedAt: null,
      performedLocalDate: null,
      performedLocalTime: null,
    ),
    event: MedicationApplicationEvent(
      id: '99000000-0000-4000-8000-${(completed.version + 1).toString().padLeft(12, '0')}',
      applicationId: completed.id,
      type: MedicationEventType.completionReversed,
      actorId: '57000000-0000-4000-8000-000000000002',
      actorLabel: 'Equipe revisora',
      occurredAt: time,
      occurredLocalDate: '2026-11-01',
      occurredLocalTime: '09:07',
      applicationVersion: completed.version + 1,
      reason: reason,
    ),
  );
}
