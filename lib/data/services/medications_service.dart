import '../../utils/result.dart';
import '../models/medication_dto.dart';

abstract interface class MedicationsService {
  Future<Result<MedicationDto>> listTreatments(
    String animalId, {
    String? cursor,
  });
  Future<Result<MedicationDto>> saveTreatment(
    Map<String, Object?> payload,
    String operationKey,
  );
  Future<Result<MedicationDto>> stopTreatment(
    String treatmentId,
    int revision,
    int version,
    String operationKey,
  );
  Future<Result<MedicationDto>> loadMonth(String month);
  Future<Result<MedicationDto>> loadDay(
    String day, {
    String? cursor,
    Map<String, String>? filter,
  });
  Future<Result<MedicationDto>> loadApplicationHistory(
    String applicationId, {
    String? cursor,
  });
  Future<Result<MedicationDto>> completeApplication(
    String applicationId,
    int version,
    String operationKey,
  );
  Future<Result<MedicationDto>> reverseCompletion(
    String applicationId,
    int version,
    String reason,
    String operationKey,
  );
  Future<Result<MedicationDto?>> getOperation(String operationKey);
}
