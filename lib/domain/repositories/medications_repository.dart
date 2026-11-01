import '../../utils/result.dart';
import '../models/medication_treatment.dart';
import '../models/medication_application.dart';
import '../models/medication_agenda.dart';

abstract interface class MedicationsRepository {
  Future<Result<MedicationTreatmentPage>> listTreatments(
    String animalId, {
    String? cursor,
  });
  Future<Result<MedicationCommandResult>> saveTreatment(
    MedicationTreatmentDraft draft,
    String operationKey,
  );
  Future<Result<MedicationCommandResult>> stopTreatment(
    MedicationTreatment treatment,
    String operationKey,
  );
  Future<Result<MedicationMonth>> loadMonth(String month);
  Future<Result<MedicationDayPage>> loadDay(String day, {String? cursor});
  Future<Result<MedicationHistoryPage>> loadApplicationHistory(
    String applicationId, {
    String? cursor,
  });
  Future<Result<MedicationCommandResult>> completeApplication(
    MedicationApplication application,
    String operationKey,
  );
  Future<Result<MedicationCommandResult>> reverseCompletion(
    MedicationApplication application,
    String reason,
    String operationKey,
  );
  Future<Result<MedicationCommandResult?>> getOperation(String operationKey);
}
