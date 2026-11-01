import 'fake_behavior.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import 'package:abrigo_dos_anjos/domain/models/medication_treatment.dart';
import 'package:abrigo_dos_anjos/domain/models/medication_application.dart';
import 'package:abrigo_dos_anjos/domain/models/medication_agenda.dart';
import 'package:abrigo_dos_anjos/domain/repositories/medications_repository.dart';

class FakeMedicationsRepository extends FakeBehavior
    implements MedicationsRepository {
  @override
  Future<Result<MedicationTreatmentPage>> listTreatments(
    String animalId, {
    String? cursor,
  }) => invoke<MedicationTreatmentPage>('listTreatments', [animalId, cursor]);
  @override
  Future<Result<MedicationCommandResult>> saveTreatment(
    MedicationTreatmentDraft draft,
    String operationKey,
  ) => invoke<MedicationCommandResult>('saveTreatment', [draft, operationKey]);
  @override
  Future<Result<MedicationCommandResult>> stopTreatment(
    MedicationTreatment treatment,
    String operationKey,
  ) => invoke<MedicationCommandResult>('stopTreatment', [
    treatment,
    operationKey,
  ]);
  @override
  Future<Result<MedicationMonth>> loadMonth(String month) =>
      invoke<MedicationMonth>('loadMonth', [month]);
  @override
  Future<Result<MedicationDayPage>> loadDay(String day, {String? cursor}) =>
      invoke<MedicationDayPage>('loadDay', [day, cursor]);
  @override
  Future<Result<MedicationHistoryPage>> loadApplicationHistory(
    String applicationId, {
    String? cursor,
  }) => invoke<MedicationHistoryPage>('loadApplicationHistory', [
    applicationId,
    cursor,
  ]);
  @override
  Future<Result<MedicationCommandResult>> completeApplication(
    MedicationApplication application,
    String operationKey,
  ) => invoke<MedicationCommandResult>('completeApplication', [
    application,
    operationKey,
  ]);
  @override
  Future<Result<MedicationCommandResult>> reverseCompletion(
    MedicationApplication application,
    String reason,
    String operationKey,
  ) => invoke<MedicationCommandResult>('reverseCompletion', [
    application,
    reason,
    operationKey,
  ]);
  @override
  Future<Result<MedicationCommandResult?>> getOperation(String operationKey) =>
      invoke<MedicationCommandResult?>('getOperation', [operationKey]);
}
