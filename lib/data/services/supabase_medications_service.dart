import 'package:supabase_flutter/supabase_flutter.dart';
import '../../utils/result.dart';
import '../models/medication_dto.dart';
import 'medications_service.dart';
import 'service_result.dart';

final class SupabaseMedicationsService implements MedicationsService {
  SupabaseMedicationsService(this.client);
  final SupabaseClient client;
  @override
  Future<Result<MedicationDto>> listTreatments(
    String animalId, {
    String? cursor,
  }) => serviceResult(
    () async => MedicationDto.parse(
      MedicationResponseType.treatments,
      await client.rpc(
        'list_animal_medication_treatments',
        params: {'p_animal_id': animalId, 'p_cursor': cursor},
      ),
    ),
  );
  @override
  Future<Result<MedicationDto>> saveTreatment(
    Map<String, Object?> payload,
    String operationKey,
  ) => serviceResult(
    () async => MedicationDto.parse(
      MedicationResponseType.command,
      await client.rpc(
        'save_medication_treatment',
        params: {'p_payload': payload, 'p_operation_key': operationKey},
      ),
    ),
  );
  @override
  Future<Result<MedicationDto>> stopTreatment(
    String treatmentId,
    int revision,
    int version,
    String operationKey,
  ) => serviceResult(
    () async => MedicationDto.parse(
      MedicationResponseType.command,
      await client.rpc(
        'stop_medication_treatment',
        params: {
          'p_treatment_id': treatmentId,
          'p_expected_revision': revision,
          'p_expected_treatment_version': version,
          'p_operation_key': operationKey,
        },
      ),
    ),
  );
  @override
  Future<Result<MedicationDto>> loadMonth(String month) => serviceResult(
    () async => MedicationDto.parse(
      MedicationResponseType.month,
      await client.rpc(
        'get_medication_calendar_month',
        params: {'p_month': month},
      ),
    ),
  );
  @override
  Future<Result<MedicationDto>> loadDay(String day, {String? cursor}) =>
      serviceResult(
        () async => MedicationDto.parse(
          MedicationResponseType.day,
          await client.rpc(
            'list_medication_day',
            params: {'p_day': day, 'p_cursor': cursor},
          ),
        ),
      );
  @override
  Future<Result<MedicationDto>> loadApplicationHistory(
    String applicationId, {
    String? cursor,
  }) => serviceResult(
    () async => MedicationDto.parse(
      MedicationResponseType.history,
      await client.rpc(
        'get_medication_application_history',
        params: {'p_application_id': applicationId, 'p_cursor': cursor},
      ),
    ),
  );
  @override
  Future<Result<MedicationDto>> completeApplication(
    String applicationId,
    int version,
    String operationKey,
  ) => serviceResult(
    () async => MedicationDto.parse(
      MedicationResponseType.command,
      await client.rpc(
        'complete_medication_application',
        params: {
          'p_application_id': applicationId,
          'p_expected_version': version,
          'p_operation_key': operationKey,
        },
      ),
    ),
  );
  @override
  Future<Result<MedicationDto>> reverseCompletion(
    String applicationId,
    int version,
    String reason,
    String operationKey,
  ) => serviceResult(
    () async => MedicationDto.parse(
      MedicationResponseType.command,
      await client.rpc(
        'reverse_medication_completion',
        params: {
          'p_application_id': applicationId,
          'p_expected_version': version,
          'p_reason': reason,
          'p_operation_key': operationKey,
        },
      ),
    ),
  );
  @override
  Future<Result<MedicationDto?>> getOperation(String operationKey) =>
      serviceResult(() async {
        final value = await client.rpc(
          'get_medication_operation',
          params: {'p_operation_key': operationKey},
        );
        return value == null
            ? null
            : MedicationDto.parse(MedicationResponseType.command, value);
      });
}
