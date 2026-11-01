import 'dart:convert';
import '../../domain/models/medication_agenda.dart';
import '../../domain/models/medication_application.dart';
import '../../domain/models/medication_schedule.dart';
import '../../domain/models/medication_treatment.dart';
import '../../domain/repositories/medications_repository.dart';
import '../../utils/app_failure.dart';
import '../../utils/result.dart';
import '../services/medications_service.dart';
import 'repository_result.dart';

class MedicationsRepositoryImpl implements MedicationsRepository {
  MedicationsRepositoryImpl(this.service);
  final MedicationsService service;
  bool _key(String value) => RegExp(r'^[A-Za-z0-9_-]{32}$').hasMatch(value);
  bool _cursor(String? value) =>
      value == null || (value.isNotEmpty && utf8.encode(value).length <= 1024);
  Failure<T> _invalid<T>() => Failure(AppFailure(FailureCode.validation));
  Map<String, dynamic> _map(Object? value) =>
      (value as Map).cast<String, dynamic>();
  DateTime _instant(Object? value) => DateTime.parse(value as String).toUtc();
  MedicationTreatment _treatment(Object? value) {
    final d = _map(value);
    return MedicationTreatment(
      id: d['id'] as String,
      animalId: d['animal_id'] as String,
      revision: d['revision'] as int,
      version: d['version'] as int,
      medicationName: d['medication_name'] as String,
      instructions: d['instructions'] as String,
      status: MedicationTreatmentStatus.values.byName(d['status'] as String),
      schedule: MedicationSchedule(
        mode: d['schedule_mode'] == 'fixed_times'
            ? MedicationScheduleMode.fixedTimes
            : MedicationScheduleMode.interval,
        startsOn: d['starts_on'] as String,
        startsTime: d['starts_time'] as String,
        endsOn: d['ends_on'] as String,
        endsTime: d['ends_time'] as String,
        fixedTimes: (d['fixed_times'] as List).cast<String>(),
        intervalMinutes: d['interval_minutes'] as int?,
      ),
    );
  }

  MedicationApplication _application(Object? value) {
    final d = _map(value);
    return MedicationApplication(
      id: d['id'] as String,
      treatmentId: d['treatment_id'] as String,
      animalId: d['animal_id'] as String,
      animalName: d['animal_name'] as String,
      medicationName: d['medication_name'] as String,
      instructions: d['instructions'] as String,
      revision: d['revision'] as int,
      version: d['version'] as int,
      scheduledAt: _instant(d['scheduled_at']),
      scheduledLocalDate: d['scheduled_local_date'] as String,
      scheduledLocalTime: d['scheduled_local_time'] as String,
      state: MedicationApplicationState.values.byName(d['state'] as String),
      performedBy: d['performed_by'] as String?,
      actorLabel: d['actor_label'] as String?,
      performedAt: d['performed_at'] == null
          ? null
          : _instant(d['performed_at']),
      performedLocalDate: d['performed_local_date'] as String?,
      performedLocalTime: d['performed_local_time'] as String?,
    );
  }

  MedicationApplicationEvent _event(Object? value) {
    final d = _map(value);
    return MedicationApplicationEvent(
      id: d['id'] as String,
      applicationId: d['application_id'] as String,
      type: d['event_type'] == 'completion_reversed'
          ? MedicationEventType.completionReversed
          : MedicationEventType.values.byName(d['event_type'] as String),
      actorId: d['actor_id'] as String,
      actorLabel: d['actor_label'] as String,
      occurredAt: _instant(d['occurred_at']),
      occurredLocalDate: d['occurred_local_date'] as String,
      occurredLocalTime: d['occurred_local_time'] as String,
      applicationVersion: d['application_version'] as int,
      reason: d['reason'] as String?,
    );
  }

  MedicationCommandResult _command(
    Object? value,
    String key, {
    String? animalId,
    String? applicationId,
    String? treatmentId,
  }) {
    final d = _map(value), r = _map(d['result']);
    if (d['operation_key'] != key) {
      throw const FormatException('Operation mismatch');
    }
    final treatment = r['treatment'] == null
        ? null
        : _treatment(r['treatment']);
    final application = r['application'] == null
        ? null
        : _application(r['application']);
    if ((animalId != null && treatment?.animalId != animalId) ||
        (treatmentId != null && treatment?.id != treatmentId) ||
        (applicationId != null && application?.id != applicationId)) {
      throw const FormatException('Target mismatch');
    }
    return MedicationCommandResult(
      operationKey: key,
      serverNow: _instant(d['server_now']),
      treatment: treatment,
      application: application,
      event: r['event'] == null ? null : _event(r['event']),
      cancelledCount: r['cancelled_count'] as int,
    );
  }

  @override
  Future<Result<MedicationTreatmentPage>> listTreatments(
    String animalId, {
    String? cursor,
  }) async {
    if (!isMedicationIdentifier(animalId) || !_cursor(cursor)) {
      return _invalid();
    }
    return mapRepositoryResult(
      () => service.listTreatments(animalId, cursor: cursor),
      (dto) {
        final items = (dto.values['items'] as List).map(_treatment).toList();
        if (items.any((item) => item.animalId != animalId)) {
          throw const FormatException('Target mismatch');
        }
        return MedicationTreatmentPage(
          items: items,
          cursor: dto.values['next_cursor'] as String?,
        );
      },
    );
  }

  @override
  Future<Result<MedicationCommandResult>> saveTreatment(
    MedicationTreatmentDraft draft,
    String operationKey,
  ) async {
    if (draft.validate().isNotEmpty || !_key(operationKey)) return _invalid();
    final times = draft.schedule.fixedTimes.toList()..sort();
    return mapRepositoryResult(
      () => service.saveTreatment({
        'treatment_id': draft.treatmentId,
        'animal_id': draft.animalId,
        'expected_revision': draft.expectedRevision,
        'expected_treatment_version': draft.expectedVersion,
        'medication_name': draft.medicationName.trim(),
        'instructions': draft.instructions,
        'schedule_mode':
            draft.schedule.mode == MedicationScheduleMode.fixedTimes
            ? 'fixed_times'
            : 'interval',
        'starts_on': draft.schedule.startsOn,
        'starts_time': draft.schedule.startsTime,
        'ends_on': draft.schedule.endsOn,
        'ends_time': draft.schedule.endsTime,
        'fixed_times': times,
        'interval_minutes': draft.schedule.intervalMinutes,
      }, operationKey),
      (dto) => _command(
        dto.values,
        operationKey,
        animalId: draft.animalId,
        treatmentId: draft.treatmentId,
      ),
    );
  }

  @override
  Future<Result<MedicationCommandResult>> stopTreatment(
    MedicationTreatment treatment,
    String operationKey,
  ) async {
    if (!isMedicationIdentifier(treatment.id) ||
        treatment.revision < 1 ||
        treatment.version < 1 ||
        !_key(operationKey)) {
      return _invalid();
    }
    return mapRepositoryResult(
      () => service.stopTreatment(
        treatment.id,
        treatment.revision,
        treatment.version,
        operationKey,
      ),
      (dto) => _command(dto.values, operationKey, treatmentId: treatment.id),
    );
  }

  @override
  Future<Result<MedicationMonth>> loadMonth(String month) async {
    if (!RegExp(r'^\d{4}-\d{2}$').hasMatch(month) ||
        !MedicationSchedule.validDate('$month-01')) {
      return _invalid();
    }
    return mapRepositoryResult(() => service.loadMonth(month), (dto) {
      final d = dto.values;
      if (d['month'] != month) throw const FormatException('Month mismatch');
      return MedicationMonth(
        month: month,
        serverNow: _instant(d['server_now']),
        shelterToday: d['shelter_today'] as String,
        days: (d['days'] as List).map((value) {
          final day = _map(value);
          return MedicationDaySummary(
            day: day['day'] as String,
            pending: day['pending'] as int,
            completed: day['completed'] as int,
            cancelled: day['cancelled'] as int,
          );
        }).toList(),
      );
    });
  }

  @override
  Future<Result<MedicationDayPage>> loadDay(
    String day, {
    String? cursor,
  }) async {
    if (!MedicationSchedule.validDate(day) || !_cursor(cursor)) {
      return _invalid();
    }
    return mapRepositoryResult(() => service.loadDay(day, cursor: cursor), (
      dto,
    ) {
      final d = dto.values;
      if (d['day'] != day) throw const FormatException('Day mismatch');
      return MedicationDayPage(
        day: day,
        serverNow: _instant(d['server_now']),
        agendaVersion: d['agenda_version'] as int,
        items: (d['items'] as List).map(_application).toList(),
        cursor: d['next_cursor'] as String?,
      );
    });
  }

  @override
  Future<Result<MedicationHistoryPage>> loadApplicationHistory(
    String applicationId, {
    String? cursor,
  }) async {
    if (!isMedicationIdentifier(applicationId) || !_cursor(cursor)) {
      return _invalid();
    }
    return mapRepositoryResult(
      () => service.loadApplicationHistory(applicationId, cursor: cursor),
      (dto) {
        final d = dto.values, application = _application(d['application']);
        if (application.id != applicationId) {
          throw const FormatException('Application mismatch');
        }
        return MedicationHistoryPage(
          application: application,
          items: (d['items'] as List).map(_event).toList(),
          cursor: d['next_cursor'] as String?,
        );
      },
    );
  }

  @override
  Future<Result<MedicationCommandResult>> completeApplication(
    MedicationApplication application,
    String operationKey,
  ) async {
    if (!isMedicationIdentifier(application.id) ||
        application.version < 1 ||
        !_key(operationKey)) {
      return _invalid();
    }
    return mapRepositoryResult(
      () => service.completeApplication(
        application.id,
        application.version,
        operationKey,
      ),
      (dto) {
        final result = _command(
          dto.values,
          operationKey,
          applicationId: application.id,
        );
        final confirmed = result.application!;
        final event = result.event;
        if (confirmed.state != MedicationApplicationState.completed ||
            confirmed.version != application.version + 1 ||
            event == null ||
            event.type != MedicationEventType.completed ||
            event.applicationId != confirmed.id ||
            event.applicationVersion != confirmed.version ||
            event.actorId != confirmed.performedBy ||
            event.occurredAt != confirmed.performedAt) {
          throw const FormatException('Invalid completion confirmation');
        }
        return result;
      },
    );
  }

  @override
  Future<Result<MedicationCommandResult>> reverseCompletion(
    MedicationApplication application,
    String reason,
    String operationKey,
  ) async {
    if (!isMedicationIdentifier(application.id) ||
        application.version < 1 ||
        !_key(operationKey) ||
        reason.trim().isEmpty ||
        reason.trim().runes.length > 500) {
      return _invalid();
    }
    return mapRepositoryResult(
      () => service.reverseCompletion(
        application.id,
        application.version,
        reason.trim(),
        operationKey,
      ),
      (dto) {
        final result = _command(
          dto.values,
          operationKey,
          applicationId: application.id,
        );
        final confirmed = result.application!;
        final event = result.event;
        if (confirmed.state != MedicationApplicationState.pending ||
            confirmed.version != application.version + 1 ||
            event == null ||
            event.applicationId != confirmed.id ||
            event.applicationVersion != confirmed.version ||
            event.type != MedicationEventType.completionReversed ||
            event.reason != reason.trim()) {
          throw const FormatException('Invalid reversal confirmation');
        }
        return result;
      },
    );
  }

  @override
  Future<Result<MedicationCommandResult?>> getOperation(
    String operationKey,
  ) async {
    if (!_key(operationKey)) return _invalid();
    return mapRepositoryResult(
      () => service.getOperation(operationKey),
      (dto) => dto == null ? null : _command(dto.values, operationKey),
    );
  }
}
