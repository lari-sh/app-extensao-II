import '../../domain/models/medication_schedule.dart';
import '../../domain/models/medication_treatment.dart';

enum MedicationResponseType {
  treatment,
  application,
  command,
  treatments,
  month,
  day,
  history,
}

final class MedicationDto {
  MedicationDto._(this.values);
  final Map<String, Object?> values;
  factory MedicationDto.parse(MedicationResponseType type, Object? response) {
    final data = _object(response);
    final parsed = switch (type) {
      MedicationResponseType.treatment => _treatment(data),
      MedicationResponseType.application => _application(data),
      MedicationResponseType.command => _command(data),
      MedicationResponseType.treatments => {
        'items': _items(data, 'items', 50, _treatment),
        'next_cursor': _cursor(data),
      },
      MedicationResponseType.month => _month(data),
      MedicationResponseType.day => _day(data),
      MedicationResponseType.history => {
        'application': _application(_object(data['application'])),
        'items': _items(data, 'items', 100, _event),
        'next_cursor': _cursor(data),
      },
    };
    return MedicationDto._(_freeze(parsed) as Map<String, Object?>);
  }
}

Never _invalid() => throw const FormatException('Invalid medication response');
Map<String, dynamic> _object(Object? value) {
  if (value is! Map || value.keys.any((key) => key is! String)) _invalid();
  return value.cast<String, dynamic>();
}

Object? _freeze(Object? value) {
  if (value is Map) {
    return Map<String, Object?>.unmodifiable(
      value.map((key, item) => MapEntry(key as String, _freeze(item))),
    );
  }
  if (value is List) return List<Object?>.unmodifiable(value.map(_freeze));
  if (value == null || value is String || value is bool || value is num) {
    return value;
  }
  return _invalid();
}

String _text(
  Map<String, dynamic> data,
  String key, {
  int minimum = 1,
  int maximum = 1000,
}) {
  final value = data[key];
  if (value is! String ||
      value.trim().runes.length < minimum ||
      value.runes.length > maximum) {
    _invalid();
  }
  return value;
}

String _id(Map<String, dynamic> data, String key) {
  final value = _text(data, key, maximum: 36);
  if (!isMedicationIdentifier(value)) _invalid();
  return value;
}

int _integer(Map<String, dynamic> data, String key, {int minimum = 1}) {
  final value = data[key];
  if (value is! int || value < minimum) _invalid();
  return value;
}

String _date(Map<String, dynamic> data, String key) {
  final value = _text(data, key, maximum: 10);
  if (!MedicationSchedule.validDate(value)) _invalid();
  return value;
}

String _time(Map<String, dynamic> data, String key) {
  final value = _text(data, key, maximum: 5);
  if (!MedicationSchedule.validTime(value)) _invalid();
  return value;
}

String _timestamp(Map<String, dynamic> data, String key) {
  final value = _text(data, key, maximum: 40);
  if (!RegExp(
        r'^\d{4}-\d{2}-\d{2}T(?:[01]\d|2[0-3]):[0-5]\d:[0-5]\d(?:\.\d+)?(?:Z|[+-](?:0\d|1[0-4]):[0-5]\d)$',
      ).hasMatch(value) ||
      DateTime.tryParse(value) == null) {
    _invalid();
  }
  if (!MedicationSchedule.validDate(value.substring(0, 10))) _invalid();
  return value;
}

String? _cursor(Map<String, dynamic> data) {
  if (data['next_cursor'] == null) return null;
  return _text(data, 'next_cursor', maximum: 1024);
}

List<Object?> _items(
  Map<String, dynamic> data,
  String key,
  int limit,
  Map<String, Object?> Function(Map<String, dynamic>) read,
) {
  final value = data[key];
  if (value is! List || value.length > limit) _invalid();
  return value.map((item) => read(_object(item))).toList();
}

Map<String, Object?> _treatment(Map<String, dynamic> data) {
  final mode = _text(data, 'schedule_mode');
  if (mode != 'fixed_times' && mode != 'interval') _invalid();
  final times = data['fixed_times'];
  if (times is! List || times.any((item) => item is! String)) _invalid();
  final interval = data['interval_minutes'];
  if (interval != null && interval is! int) _invalid();
  final start = _date(data, 'starts_on'),
      end = _date(data, 'ends_on'),
      from = _time(data, 'starts_time'),
      until = _time(data, 'ends_time');
  final schedule = MedicationSchedule(
    mode: mode == 'fixed_times'
        ? MedicationScheduleMode.fixedTimes
        : MedicationScheduleMode.interval,
    startsOn: start,
    startsTime: from,
    endsOn: end,
    endsTime: until,
    fixedTimes: times.cast<String>(),
    intervalMinutes: interval as int?,
  );
  if (schedule.validate().isNotEmpty ||
      data['timezone'] != MedicationSchedule.timezone) {
    _invalid();
  }
  final status = _text(data, 'status');
  if (status != 'active' && status != 'stopped') _invalid();
  return {
    'id': _id(data, 'id'),
    'animal_id': _id(data, 'animal_id'),
    'revision': _integer(data, 'revision'),
    'version': _integer(data, 'version'),
    'medication_name': _text(data, 'medication_name', maximum: 120),
    'instructions': _text(data, 'instructions', minimum: 0, maximum: 1000),
    'status': status,
    'schedule_mode': mode,
    'starts_on': start,
    'starts_time': from,
    'ends_on': end,
    'ends_time': until,
    'fixed_times': times,
    'interval_minutes': interval,
    'timezone': MedicationSchedule.timezone,
  };
}

Map<String, Object?> _application(Map<String, dynamic> data) {
  final state = _text(data, 'state');
  if (!['pending', 'completed', 'cancelled'].contains(state)) _invalid();
  final values = <String, Object?>{
    'id': _id(data, 'id'),
    'treatment_id': _id(data, 'treatment_id'),
    'animal_id': _id(data, 'animal_id'),
    'animal_name': _text(data, 'animal_name', maximum: 80),
    'medication_name': _text(data, 'medication_name', maximum: 120),
    'instructions': _text(data, 'instructions', minimum: 0, maximum: 1000),
    'revision': _integer(data, 'revision'),
    'version': _integer(data, 'version'),
    'state': state,
    'scheduled_at': _timestamp(data, 'scheduled_at'),
    'scheduled_local_date': _date(data, 'scheduled_local_date'),
    'scheduled_local_time': _time(data, 'scheduled_local_time'),
  };
  if (state == 'completed') {
    values.addAll({
      'performed_by': _id(data, 'performed_by'),
      'performed_at': _timestamp(data, 'performed_at'),
      'actor_label': _text(data, 'actor_label', maximum: 160),
      'performed_local_date': _date(data, 'performed_local_date'),
      'performed_local_time': _time(data, 'performed_local_time'),
    });
  } else {
    for (final key in [
      'performed_by',
      'performed_at',
      'actor_label',
      'performed_local_date',
      'performed_local_time',
    ]) {
      if (data[key] != null) _invalid();
      values[key] = null;
    }
  }
  return values;
}

Map<String, Object?> _event(Map<String, dynamic> data) {
  final type = _text(data, 'event_type');
  if (!['completed', 'completion_reversed', 'cancelled'].contains(type)) {
    _invalid();
  }
  final reason = data['reason'];
  if (reason != null) _text(data, 'reason', maximum: 500);
  if (type == 'completion_reversed' &&
      (reason is! String || reason.trim().isEmpty)) {
    _invalid();
  }
  return {
    'id': _id(data, 'id'),
    'application_id': _id(data, 'application_id'),
    'event_type': type,
    'actor_id': _id(data, 'actor_id'),
    'actor_label': _text(data, 'actor_label', maximum: 160),
    'occurred_at': _timestamp(data, 'occurred_at'),
    'occurred_local_date': _date(data, 'occurred_local_date'),
    'occurred_local_time': _time(data, 'occurred_local_time'),
    'application_version': _integer(data, 'application_version'),
    'reason': reason,
  };
}

Map<String, Object?> _command(Map<String, dynamic> data) {
  final key = _text(data, 'operation_key', maximum: 32);
  if (!RegExp(r'^[A-Za-z0-9_-]{32}$').hasMatch(key)) _invalid();
  final result = _object(data['result']);
  if (result['treatment'] == null && result['application'] == null) _invalid();
  return {
    'operation_key': key,
    'server_now': _timestamp(data, 'server_now'),
    'result': {
      'treatment': result['treatment'] == null
          ? null
          : _treatment(_object(result['treatment'])),
      'application': result['application'] == null
          ? null
          : _application(_object(result['application'])),
      'event': result['event'] == null
          ? null
          : _event(_object(result['event'])),
      'cancelled_count': result['cancelled_count'] == null
          ? 0
          : _integer(result, 'cancelled_count', minimum: 0),
    },
  };
}

Map<String, Object?> _month(Map<String, dynamic> data) {
  final month = _text(data, 'month', maximum: 7);
  if (!MedicationSchedule.validDate('$month-01') ||
      data['timezone'] != MedicationSchedule.timezone) {
    _invalid();
  }
  final days = _items(
    data,
    'days',
    31,
    (day) => {
      'day': _date(day, 'day'),
      'pending': _integer(day, 'pending', minimum: 0),
      'completed': _integer(day, 'completed', minimum: 0),
      'cancelled': _integer(day, 'cancelled', minimum: 0),
    },
  );
  final names = days.map((day) => (day as Map)['day'] as String).toList();
  if (names.toSet().length != names.length ||
      names.any((day) => !day.startsWith('$month-'))) {
    _invalid();
  }
  return {
    'month': month,
    'server_now': _timestamp(data, 'server_now'),
    'shelter_today': _date(data, 'shelter_today'),
    'days': days,
  };
}

Map<String, Object?> _day(Map<String, dynamic> data) {
  final day = _date(data, 'day'),
      items = _items(data, 'items', 100, _application);
  if (items.any((item) => (item as Map)['scheduled_local_date'] != day)) {
    _invalid();
  }
  return {
    'day': day,
    'server_now': _timestamp(data, 'server_now'),
    'agenda_version': _integer(data, 'agenda_version', minimum: 0),
    'items': items,
    'next_cursor': _cursor(data),
  };
}
