import 'package:freezed_annotation/freezed_annotation.dart';
import '../../utils/civil_date.dart';
part 'medication_schedule.freezed.dart';

enum MedicationScheduleMode { fixedTimes, interval }

@freezed
abstract class MedicationSchedule with _$MedicationSchedule {
  const MedicationSchedule._();
  const factory MedicationSchedule({
    @Default(MedicationScheduleMode.fixedTimes) MedicationScheduleMode mode,
    @Default('') String startsOn,
    @Default('08:00') String startsTime,
    @Default('') String endsOn,
    @Default('20:00') String endsTime,
    @Default(['08:00', '20:00']) List<String> fixedTimes,
    int? intervalMinutes,
  }) = _MedicationSchedule;

  static const timezone = 'America/Sao_Paulo';
  static const maximumApplications = 10000;
  static bool validTime(String value) =>
      RegExp(r'^(?:[01]\d|2[0-3]):[0-5]\d$').hasMatch(value);
  static bool validDate(String value) =>
      canonicalDate(value) == value &&
      value.compareTo('2000-01-01') >= 0 &&
      value.compareTo('2100-12-31') <= 0;

  Map<String, String> validate({int? resolvedApplicationCount}) {
    final errors = <String, String>{};
    if (!validDate(startsOn)) errors['startsOn'] = 'date';
    if (!validDate(endsOn)) errors['endsOn'] = 'date';
    if (!validTime(startsTime)) errors['startsTime'] = 'time';
    if (!validTime(endsTime)) errors['endsTime'] = 'time';
    if (errors.isEmpty) {
      // Civil comparison only. IANA resolution and actual generation belong to the server.
      final from = DateTime.parse('${startsOn}T$startsTime:00Z');
      final until = DateTime.parse('${endsOn}T$endsTime:00Z');
      final days =
          DateTime.parse(
            '${endsOn}T00:00:00Z',
          ).difference(DateTime.parse('${startsOn}T00:00:00Z')).inDays +
          1;
      if (!until.isAfter(from) || days > 366) errors['period'] = 'range';
    }
    if (mode == MedicationScheduleMode.fixedTimes) {
      if (fixedTimes.isEmpty ||
          fixedTimes.length > 24 ||
          fixedTimes.toSet().length != fixedTimes.length ||
          fixedTimes.any((time) => !validTime(time))) {
        errors['fixedTimes'] = 'times';
      }
      if (intervalMinutes != null) errors['intervalMinutes'] = 'exclusive';
    } else {
      if (fixedTimes.isNotEmpty) errors['fixedTimes'] = 'exclusive';
      if (intervalMinutes == null ||
          intervalMinutes! < 1 ||
          intervalMinutes! > 10080) {
        errors['intervalMinutes'] = 'range';
      }
    }
    // Count, when supplied, must come from a resolved server schedule, not device timezone arithmetic.
    if (resolvedApplicationCount != null &&
        (resolvedApplicationCount < 1 ||
            resolvedApplicationCount > maximumApplications)) {
      errors['applicationCount'] = 'range';
    }
    return Map.unmodifiable(errors);
  }
}
