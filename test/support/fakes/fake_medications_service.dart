import 'fake_behavior.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import 'package:abrigo_dos_anjos/data/models/medication_dto.dart';
import 'package:abrigo_dos_anjos/data/services/medications_service.dart';

class FakeMedicationsService extends FakeBehavior
    implements MedicationsService {
  @override
  Future<Result<MedicationDto>> listTreatments(
    String animalId, {
    String? cursor,
  }) => invoke<MedicationDto>('listTreatments', [animalId, cursor]);
  @override
  Future<Result<MedicationDto>> saveTreatment(
    Map<String, Object?> payload,
    String operationKey,
  ) => invoke<MedicationDto>('saveTreatment', [payload, operationKey]);
  @override
  Future<Result<MedicationDto>> stopTreatment(
    String treatmentId,
    int revision,
    int version,
    String operationKey,
  ) => invoke<MedicationDto>('stopTreatment', [
    treatmentId,
    revision,
    version,
    operationKey,
  ]);
  @override
  Future<Result<MedicationDto>> loadMonth(String month) =>
      invoke<MedicationDto>('loadMonth', [month]);
  @override
  Future<Result<MedicationDto>> loadDay(String day, {String? cursor}) =>
      invoke<MedicationDto>('loadDay', [day, cursor]);
  @override
  Future<Result<MedicationDto>> loadApplicationHistory(
    String applicationId, {
    String? cursor,
  }) =>
      invoke<MedicationDto>('loadApplicationHistory', [applicationId, cursor]);
  @override
  Future<Result<MedicationDto>> completeApplication(
    String applicationId,
    int version,
    String operationKey,
  ) => invoke<MedicationDto>('completeApplication', [
    applicationId,
    version,
    operationKey,
  ]);
  @override
  Future<Result<MedicationDto>> reverseCompletion(
    String applicationId,
    int version,
    String reason,
    String operationKey,
  ) => invoke<MedicationDto>('reverseCompletion', [
    applicationId,
    version,
    reason,
    operationKey,
  ]);
  @override
  Future<Result<MedicationDto?>> getOperation(String operationKey) =>
      invoke<MedicationDto?>('getOperation', [operationKey]);
}
