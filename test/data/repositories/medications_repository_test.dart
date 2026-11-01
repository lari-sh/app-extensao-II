import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/data/repositories/medications_repository_impl.dart';
import 'package:abrigo_dos_anjos/data/models/medication_dto.dart';
import 'package:abrigo_dos_anjos/domain/models/medication_treatment.dart';
import 'package:abrigo_dos_anjos/domain/models/medication_schedule.dart';
import 'package:abrigo_dos_anjos/domain/models/medication_application.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import 'package:abrigo_dos_anjos/utils/app_failure.dart';
import '../../support/medication_fixtures.dart';
import '../../support/fakes/fake_medications_service.dart';

void main() {
  test(
    'month, day, application history and commands map confirmed private data',
    () async {
      final application = {
        ...medicationApplicationJson(),
        'state': 'completed',
        'version': 2,
        'performed_by': medicationAnimalId,
        'actor_label': 'Equipe A',
        'performed_at': '2026-11-01T12:00:00Z',
        'performed_local_date': '2026-11-01',
        'performed_local_time': '09:00',
      };
      final event = {
        'id': medicationApplicationId,
        'application_id': medicationApplicationId,
        'event_type': 'completed',
        'actor_id': medicationAnimalId,
        'actor_label': 'Equipe A',
        'occurred_at': '2026-11-01T12:00:00Z',
        'occurred_local_date': '2026-11-01',
        'occurred_local_time': '09:00',
        'application_version': 2,
        'reason': null,
      };
      final service = FakeMedicationsService()
        ..handler = (method, _) async {
          if (method == 'loadMonth') {
            return Success(
              MedicationDto.parse(MedicationResponseType.month, {
                'month': '2026-11',
                'server_now': '2026-11-01T12:00:00Z',
                'shelter_today': '2026-11-01',
                'timezone': 'America/Sao_Paulo',
                'days': [
                  {
                    'day': '2026-11-01',
                    'pending': 1,
                    'completed': 1,
                    'cancelled': 0,
                  },
                ],
              }),
            );
          }
          if (method == 'loadApplicationHistory') {
            return Success(
              MedicationDto.parse(MedicationResponseType.history, {
                'application': application,
                'items': [event],
                'next_cursor': null,
              }),
            );
          }
          if (method == 'reverseCompletion') {
            return Success(
              MedicationDto.parse(MedicationResponseType.command, {
                'operation_key': 'k' * 32,
                'server_now': '2026-11-01T12:00:00Z',
                'result': {
                  'application': {
                    ...application,
                    'version': 3,
                    'state': 'pending',
                    'performed_by': null,
                    'performed_at': null,
                    'actor_label': null,
                    'performed_local_date': null,
                    'performed_local_time': null,
                  },
                  'event': {
                    ...event,
                    'event_type': 'completion_reversed',
                    'application_version': 3,
                    'reason': 'Engano',
                  },
                  'cancelled_count': 2,
                },
              }),
            );
          }
          return Success(
            MedicationDto.parse(MedicationResponseType.command, {
              'operation_key': 'k' * 32,
              'server_now': '2026-11-01T12:00:00Z',
              'result': {
                'application': application,
                'event': event,
                'treatment': medicationTreatmentJson(),
                'cancelled_count': 2,
              },
            }),
          );
        };
      final repository = MedicationsRepositoryImpl(service);
      final month = await repository.loadMonth('2026-11') as Success;
      expect(month.value.days.single.pending, 1);
      final history =
          (await repository.loadApplicationHistory(medicationApplicationId)
                  as Success)
              .value;
      expect(history.application.performedAt, DateTime.utc(2026, 11, 1, 12));
      expect(history.items.single.actorLabel, 'Equipe A');
      expect(
        (await repository.completeApplication(
                  history.application.copyWith(version: 1),
                  'k' * 32,
                )
                as Success)
            .value
            .event
            .actorId,
        medicationAnimalId,
      );
      expect(
        (await repository.reverseCompletion(
                  history.application,
                  ' Engano ',
                  'k' * 32,
                )
                as Success)
            .value
            .cancelledCount,
        2,
      );
      expect(service.calls.last.arguments[2], 'Engano');
    },
  );
  test('invalid targets, versions and reasons never reach service', () async {
    final service = FakeMedicationsService();
    final repository = MedicationsRepositoryImpl(service);
    final app = MedicationApplication(
      id: 'invalid',
      treatmentId: medicationTreatmentId,
      animalId: medicationAnimalId,
      animalName: 'Teste',
      medicationName: 'Teste',
      revision: 1,
      version: 1,
      scheduledAt: DateTime.utc(2026),
      scheduledLocalDate: '2026-01-01',
      scheduledLocalTime: '00:00',
    );
    expect(await repository.completeApplication(app, 'k' * 32), isA<Failure>());
    expect(
      await repository.reverseCompletion(
        app.copyWith(id: medicationApplicationId),
        ' ',
        'k' * 32,
      ),
      isA<Failure>(),
    );
    expect(
      await repository.reverseCompletion(
        app.copyWith(id: medicationApplicationId),
        'ç' * 501,
        'k' * 32,
      ),
      isA<Failure>(),
    );
    expect(await repository.loadApplicationHistory('invalid'), isA<Failure>());
    expect(
      await repository.loadDay('2026-11-01', cursor: 'ç' * 1024),
      isA<Failure>(),
    );
    expect(service.calls, isEmpty);
  });
  test(
    'mismatched operation confirmations cannot be treated as success',
    () async {
      final service = FakeMedicationsService()
        ..handler = (_, _) async => Success(
          MedicationDto.parse(MedicationResponseType.command, {
            ...medicationCommandJson(),
            'operation_key': 'z' * 32,
          }),
        );
      final repository = MedicationsRepositoryImpl(service);
      const schedule = MedicationSchedule(
        startsOn: '2026-11-01',
        endsOn: '2026-11-02',
      );
      expect(
        await repository.saveTreatment(
          const MedicationTreatmentDraft(
            animalId: medicationAnimalId,
            medicationName: 'Teste',
            schedule: schedule,
          ),
          'k' * 32,
        ),
        isA<Failure>(),
      );
    },
  );
  const schedule = MedicationSchedule(
    startsOn: '2026-11-01',
    startsTime: '08:00',
    endsOn: '2026-11-02',
    endsTime: '20:00',
    fixedTimes: ['20:00', '08:00'],
  );
  final draft = MedicationTreatmentDraft(
    animalId: medicationAnimalId,
    medicationName: ' Exemplo ',
    schedule: schedule,
  );
  test(
    'real repository normalizes editable data and maps confirmation without SDK types',
    () async {
      final service = FakeMedicationsService()
        ..handler = (_, _) async => Success(
          MedicationDto.parse(
            MedicationResponseType.command,
            medicationCommandJson(),
          ),
        );
      final repository = MedicationsRepositoryImpl(service);
      final result =
          await repository.saveTreatment(draft, 'k' * 32)
              as Success<MedicationCommandResult>;
      expect(result.value.treatment!.id, medicationTreatmentId);
      expect(result.value.serverNow, DateTime.utc(2026, 11, 1, 12));
      final payload = service.calls.single.arguments.first as Map;
      expect(payload['medication_name'], 'Exemplo');
      expect(payload['fixed_times'], ['08:00', '20:00']);
      expect(payload.containsKey('created_by'), false);
      expect(payload.containsKey('performed_at'), false);
      expect(service.calls.single.arguments.last, 'k' * 32);
    },
  );
  test(
    'invalid data never reaches service and typed failures and unexpected throws stay sanitized',
    () async {
      final service = FakeMedicationsService();
      final repository = MedicationsRepositoryImpl(service);
      expect(
        await repository.saveTreatment(
          draft.copyWith(medicationName: ''),
          'k' * 32,
        ),
        isA<Failure>(),
      );
      expect(await repository.saveTreatment(draft, 'bad'), isA<Failure>());
      expect(await repository.loadDay('2026-02-31'), isA<Failure>());
      expect(await repository.loadMonth('2026-13'), isA<Failure>());
      expect(service.calls, isEmpty);
      service.handler = (_, _) async =>
          Failure<MedicationDto>(AppFailure(FailureCode.forbidden));
      expect(
        (await repository.saveTreatment(draft, 'k' * 32) as Failure)
            .failure
            .code,
        FailureCode.forbidden,
      );
      service.handler = (_, _) async => throw StateError('private');
      expect(
        (await repository.saveTreatment(draft, 'k' * 32) as Failure)
            .failure
            .code,
        FailureCode.unknown,
      );
    },
  );
  test(
    'pagination and reconciliation preserve server civil fields and the original operation key',
    () async {
      final service = FakeMedicationsService()
        ..handler = (method, _) async {
          if (method == 'getOperation') {
            return Success<MedicationDto?>(
              MedicationDto.parse(
                MedicationResponseType.command,
                medicationCommandJson(),
              ),
            );
          }
          if (method == 'listTreatments') {
            return Success(
              MedicationDto.parse(MedicationResponseType.treatments, {
                'items': [medicationTreatmentJson()],
                'next_cursor': 'opaque',
              }),
            );
          }
          return Success(
            MedicationDto.parse(MedicationResponseType.day, {
              'day': '2026-11-01',
              'server_now': '2026-11-01T12:00:00Z',
              'agenda_version': 1,
              'items': [medicationApplicationJson()],
              'next_cursor': null,
            }),
          );
        };
      final repository = MedicationsRepositoryImpl(service);
      expect(
        (await repository.listTreatments(medicationAnimalId) as Success)
            .value
            .cursor,
        'opaque',
      );
      final day = (await repository.loadDay('2026-11-01') as Success).value;
      expect(day.items.single.scheduledLocalTime, '08:00');
      expect(
        (await repository.getOperation('k' * 32) as Success).value.treatment.id,
        medicationTreatmentId,
      );
      expect(service.calls.last.arguments, ['k' * 32]);
    },
  );
  test(
    'day pages retain cursor/version/civil date and cursor errors stay typed',
    () async {
      final service = FakeMedicationsService()
        ..handler = (_, _) async => Success(
          MedicationDto.parse(MedicationResponseType.day, {
            'day': '2026-11-01',
            'server_now': '2026-11-02T02:00:00Z',
            'agenda_version': 99,
            'items': [
              {
                ...medicationApplicationJson(),
                'scheduled_at': '2026-11-02T02:30:00Z',
                'scheduled_local_date': '2026-11-01',
                'scheduled_local_time': '23:30',
              },
            ],
            'next_cursor': 'next',
          }),
        );
      final repository = MedicationsRepositoryImpl(service);
      final page =
          (await repository.loadDay('2026-11-01', cursor: 'first') as Success)
              .value;
      expect(page.cursor, 'next');
      expect(page.agendaVersion, 99);
      expect(page.items.single.scheduledLocalDate, '2026-11-01');
      expect(page.items.single.scheduledAt, DateTime.utc(2026, 11, 2, 2, 30));
      expect(service.calls.last.arguments, ['2026-11-01', 'first']);
      service.handler = (_, _) async =>
          Failure<MedicationDto>(AppFailure(FailureCode.conflict));
      expect(
        (await repository.loadDay('2026-11-01', cursor: 'first') as Failure)
            .failure
            .code,
        FailureCode.conflict,
      );
      final count = service.calls.length;
      expect(
        await repository.loadDay('2026-11-01', cursor: 'x' * 1025),
        isA<Failure>(),
      );
      expect(service.calls.length, count);
    },
  );
  test(
    'completion keeps server receipt values and rejects mismatched audit event',
    () async {
      var wrong = false;
      final app = {
        ...medicationApplicationJson(),
        'state': 'completed',
        'version': 2,
        'performed_by': medicationAnimalId,
        'actor_label': 'Equipe original',
        'performed_at': '2026-11-01T12:06:00Z',
        'performed_local_date': '2026-11-01',
        'performed_local_time': '09:06',
      };
      final service = FakeMedicationsService()
        ..handler = (_, _) async => Success(
          MedicationDto.parse(MedicationResponseType.command, {
            'operation_key': 'k' * 32,
            'server_now': '2026-11-01T12:06:00Z',
            'result': {
              'application': app,
              'event': {
                'id': medicationApplicationId,
                'application_id': medicationApplicationId,
                'event_type': 'completed',
                'actor_id': wrong ? medicationTreatmentId : medicationAnimalId,
                'actor_label': 'Equipe original',
                'occurred_at': '2026-11-01T12:06:00Z',
                'occurred_local_date': '2026-11-01',
                'occurred_local_time': '09:06',
                'application_version': 2,
              },
            },
          }),
        );
      final repository = MedicationsRepositoryImpl(service);
      final pending = MedicationApplication(
        id: medicationApplicationId,
        treatmentId: medicationTreatmentId,
        animalId: medicationAnimalId,
        animalName: 'Atena',
        medicationName: 'Exemplo',
        revision: 1,
        version: 1,
        scheduledAt: DateTime.utc(2026, 11, 1, 11),
        scheduledLocalDate: '2026-11-01',
        scheduledLocalTime: '08:00',
      );
      final result =
          (await repository.completeApplication(pending, 'k' * 32) as Success)
              .value;
      expect(result.application.actorLabel, 'Equipe original');
      expect(result.application.performedAt, DateTime.utc(2026, 11, 1, 12, 6));
      expect(service.calls.last.arguments, [
        medicationApplicationId,
        1,
        'k' * 32,
      ]);
      wrong = true;
      expect(
        await repository.completeApplication(pending, 'k' * 32),
        isA<Failure>(),
      );
    },
  );
}
