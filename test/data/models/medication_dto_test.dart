import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/data/models/medication_dto.dart';
import '../../support/medication_fixtures.dart';

void main() {
  test(
    'rejects normalized invalid dates, noninteger intervals and invalid correction events',
    () {
      expect(
        () => MedicationDto.parse(MedicationResponseType.command, {
          ...medicationCommandJson(),
          'server_now': '2026-02-30T10:00:00Z',
        }),
        throwsFormatException,
      );
      expect(
        () => MedicationDto.parse(MedicationResponseType.treatment, {
          ...medicationTreatmentJson(),
          'interval_minutes': '480',
        }),
        throwsFormatException,
      );
      final event = {
        'id': medicationApplicationId,
        'application_id': medicationApplicationId,
        'event_type': 'completed',
        'actor_id': medicationAnimalId,
        'actor_label': 'Funcionário de teste',
        'occurred_at': '2026-11-01T12:00:00Z',
        'occurred_local_date': '2026-11-01',
        'occurred_local_time': '09:00',
        'application_version': 2,
      };
      for (final change in [
        {'event_type': 'unrecognized'},
        {'event_type': 'completion_reversed', 'reason': null},
      ]) {
        expect(
          () => MedicationDto.parse(MedicationResponseType.history, {
            'application': medicationApplicationJson(),
            'items': [
              {...event, ...change},
            ],
            'next_cursor': null,
          }),
          throwsFormatException,
        );
      }
    },
  );

  test(
    'complete application, audit and calendar pages are validated deeply',
    () {
      final application = {
        ...medicationApplicationJson(),
        'state': 'completed',
        'performed_by': medicationAnimalId,
        'actor_label': 'Equipe de teste A',
        'performed_at': '2026-11-01T12:00:00Z',
        'performed_local_date': '2026-11-01',
        'performed_local_time': '09:00',
      };
      expect(
        MedicationDto.parse(
          MedicationResponseType.application,
          application,
        ).values['actor_label'],
        'Equipe de teste A',
      );
      final event = {
        'id': medicationApplicationId,
        'application_id': medicationApplicationId,
        'event_type': 'completion_reversed',
        'actor_id': medicationAnimalId,
        'actor_label': 'Equipe de teste A',
        'occurred_at': '2026-11-01T12:00:00Z',
        'occurred_local_date': '2026-11-01',
        'occurred_local_time': '09:00',
        'application_version': 2,
        'reason': 'Engano no teste',
      };
      final history = {
        'application': application,
        'items': [event],
        'next_cursor': null,
      };
      expect(
        MedicationDto.parse(
          MedicationResponseType.history,
          history,
        ).values['items'],
        hasLength(1),
      );
      expect(
        () => MedicationDto.parse(MedicationResponseType.history, {
          ...history,
          'items': [
            {...event, 'reason': ''},
          ],
        }),
        throwsFormatException,
      );
      final month = {
        'month': '2026-11',
        'server_now': '2026-11-01T12:00:00Z',
        'shelter_today': '2026-11-01',
        'timezone': 'America/Sao_Paulo',
        'days': [
          {'day': '2026-11-01', 'pending': 1, 'completed': 0, 'cancelled': 0},
        ],
      };
      expect(
        MedicationDto.parse(MedicationResponseType.month, month).values['days'],
        hasLength(1),
      );
      expect(
        () => MedicationDto.parse(MedicationResponseType.month, {
          ...month,
          'timezone': 'UTC',
        }),
        throwsFormatException,
      );
      expect(
        () => MedicationDto.parse(MedicationResponseType.month, {
          ...month,
          'days': List.filled(2, (month['days'] as List).single),
        }),
        throwsFormatException,
      );
      expect(
        () => MedicationDto.parse(MedicationResponseType.day, {
          'day': '2026-11-02',
          'server_now': '2026-11-01T12:00:00Z',
          'agenda_version': 1,
          'items': [medicationApplicationJson()],
          'next_cursor': null,
        }),
        throwsFormatException,
      );
      expect(
        () => MedicationDto.parse(MedicationResponseType.treatments, {
          'items': [],
          'next_cursor': 'x' * 1025,
        }),
        throwsFormatException,
      );
      final treatments = MedicationDto.parse(
        MedicationResponseType.treatments,
        {
          'items': [medicationTreatmentJson()],
          'next_cursor': null,
        },
      );
      expect(
        () => (treatments.values['items'] as List).clear(),
        throwsUnsupportedError,
      );
    },
  );
  test(
    'treatment DTO validates schedule, identifiers and versions and removes unrelated fields',
    () {
      final dto = MedicationDto.parse(MedicationResponseType.treatment, {
        ...medicationTreatmentJson(),
        'clinical_notes': 'private',
      });
      expect(dto.values.containsKey('clinical_notes'), false);
      expect(() => dto.values.clear(), throwsUnsupportedError);
      for (final change in [
        {'version': 0},
        {'starts_on': '2026-02-31'},
        {'status': 'unknown'},
        {
          'fixed_times': ['25:00'],
        },
        {'id': 'invalid'},
      ]) {
        expect(
          () => MedicationDto.parse(MedicationResponseType.treatment, {
            ...medicationTreatmentJson(),
            ...change,
          }),
          throwsFormatException,
        );
      }
    },
  );
  test(
    'application DTO rejects inconsistent completion and malformed civil/UTC values',
    () {
      expect(
        MedicationDto.parse(
          MedicationResponseType.application,
          medicationApplicationJson(),
        ).values['state'],
        'pending',
      );
      for (final change in [
        {'state': 'completed'},
        {'scheduled_at': '2026-02-31T11:00:00Z'},
        {'performed_by': medicationAnimalId},
        {'scheduled_local_time': '25:00'},
      ]) {
        expect(
          () => MedicationDto.parse(MedicationResponseType.application, {
            ...medicationApplicationJson(),
            ...change,
          }),
          throwsFormatException,
        );
      }
    },
  );
  test('command/page envelopes are strict, immutable and bounded', () {
    final dto = MedicationDto.parse(
      MedicationResponseType.command,
      medicationCommandJson(),
    );
    expect(() => (dto.values['result'] as Map).clear(), throwsUnsupportedError);
    expect(
      () => MedicationDto.parse(MedicationResponseType.command, {
        'operation_key': 'k',
        'server_now': 'invalid',
        'result': {},
      }),
      throwsFormatException,
    );
    expect(
      () => MedicationDto.parse(MedicationResponseType.day, {
        'day': '2026-11-01',
        'server_now': '2026-11-01T12:00:00Z',
        'agenda_version': 1,
        'items': List.filled(101, medicationApplicationJson()),
        'next_cursor': null,
      }),
      throwsFormatException,
    );
  });
}
