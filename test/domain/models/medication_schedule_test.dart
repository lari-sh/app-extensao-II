import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/domain/models/medication_application.dart';
import 'package:abrigo_dos_anjos/domain/models/medication_schedule.dart';
import 'package:abrigo_dos_anjos/domain/models/medication_treatment.dart';

void main() {
  test(
    'application capabilities use the supplied server clock and confirmed state',
    () {
      final clock = DateTime.utc(2026, 11, 1, 8);
      final application = MedicationApplication(
        id: 'a',
        treatmentId: 't',
        animalId: 'animal',
        animalName: 'Luna',
        medicationName: 'Exemplo',
        revision: 1,
        version: 1,
        scheduledAt: clock,
        scheduledLocalDate: '2026-11-01',
        scheduledLocalTime: '05:00',
      );
      expect(application.isDue(clock), true);
      expect(application.isOverdue(clock), false);
      expect(
        application.isOverdue(clock.add(const Duration(seconds: 1))),
        true,
      );
      expect(
        application.isDue(clock.subtract(const Duration(seconds: 1))),
        false,
      );
      for (final state in [
        MedicationApplicationState.completed,
        MedicationApplicationState.cancelled,
      ]) {
        expect(application.copyWith(state: state).isDue(clock), false);
        expect(
          application
              .copyWith(state: state)
              .isOverdue(clock.add(const Duration(days: 1))),
          false,
        );
      }
    },
  );
  const fixed = MedicationSchedule(
    startsOn: '2026-11-01',
    startsTime: '08:00',
    endsOn: '2026-11-02',
    endsTime: '20:00',
    fixedTimes: ['08:00', '20:00'],
  );
  test('fixed and interval schedules validate independently', () {
    expect(fixed.validate(), isEmpty);
    expect(
      fixed
          .copyWith(
            mode: MedicationScheduleMode.interval,
            fixedTimes: [],
            intervalMinutes: 480,
          )
          .validate(),
      isEmpty,
    );
    expect(
      fixed.copyWith(intervalMinutes: 480).validate(),
      contains('intervalMinutes'),
    );
    expect(
      fixed.copyWith(fixedTimes: ['08:00', '08:00']).validate(),
      contains('fixedTimes'),
    );
    expect(fixed.copyWith(fixedTimes: []).validate(), contains('fixedTimes'));
    expect(
      fixed.copyWith(fixedTimes: ['24:00']).validate(),
      contains('fixedTimes'),
    );
  });
  test(
    'invalid civil dates, order, years and inclusive period limits are rejected',
    () {
      expect(
        fixed.copyWith(startsOn: '2026-02-31').validate(),
        contains('startsOn'),
      );
      expect(
        fixed.copyWith(startsOn: '1999-11-01').validate(),
        contains('startsOn'),
      );
      expect(
        fixed.copyWith(endsOn: '2101-01-01').validate(),
        contains('endsOn'),
      );
      expect(
        fixed.copyWith(endsOn: '2026-11-01', endsTime: '08:00').validate(),
        contains('period'),
      );
      expect(
        fixed.copyWith(startsOn: '2024-01-01', endsOn: '2024-12-31').validate(),
        isEmpty,
      );
      expect(
        fixed.copyWith(startsOn: '2024-01-01', endsOn: '2025-01-01').validate(),
        contains('period'),
      );
      expect(fixed.validate(resolvedApplicationCount: 10000), isEmpty);
      expect(
        fixed.validate(resolvedApplicationCount: 10001),
        contains('applicationCount'),
      );
    },
  );
  test('interval and text limits count unicode code points', () {
    final interval = fixed.copyWith(
      mode: MedicationScheduleMode.interval,
      fixedTimes: [],
    );
    for (final value in [null, 0, 10081]) {
      expect(
        interval.copyWith(intervalMinutes: value).validate(),
        contains('intervalMinutes'),
      );
    }
    expect(interval.copyWith(intervalMinutes: 1).validate(), isEmpty);
    expect(interval.copyWith(intervalMinutes: 10080).validate(), isEmpty);
    final draft = MedicationTreatmentDraft(
      animalId: 'd7d3bd6f-d5a2-4374-b616-7c7ee74cfb13',
      medicationName: 'ç' * 120,
      instructions: 'ç' * 1000,
      schedule: fixed,
    );
    expect(draft.validate(), isEmpty);
    expect(
      draft.copyWith(medicationName: 'ç' * 121).validate(),
      contains('medicationName'),
    );
    expect(
      draft.copyWith(instructions: 'ç' * 1001).validate(),
      contains('instructions'),
    );
    expect(draft.copyWith(animalId: '').validate(), contains('animalId'));
    expect(
      draft.copyWith(medicationName: ' ').validate(),
      contains('medicationName'),
    );
    expect(draft.copyWith(expectedVersion: 1).validate(), contains('version'));
    expect(
      draft
          .copyWith(
            treatmentId: 'invalid',
            expectedVersion: 1,
            expectedRevision: 1,
          )
          .validate(),
      contains('version'),
    );
    expect(
      draft
          .copyWith(
            treatmentId: draft.animalId,
            expectedVersion: 1,
            expectedRevision: 1,
          )
          .validate(),
      isEmpty,
    );
    expect(
      draft
          .copyWith(treatmentId: 'd7d3bd6f-d5a2-4374-b616-7c7ee74cfb13')
          .validate(),
      contains('version'),
    );
  });
}
