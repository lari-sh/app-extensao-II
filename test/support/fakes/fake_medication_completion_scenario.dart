import 'package:abrigo_dos_anjos/domain/models/medication_agenda.dart';
import 'package:abrigo_dos_anjos/domain/models/medication_application.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import 'package:abrigo_dos_anjos/utils/app_failure.dart';
import 'fake_medications_repository.dart';
import '../medication_completion_fixtures.dart';

class FakeMedicationCompletionScenario {
  FakeMedicationCompletionScenario({this.failure});
  FailureCode? failure;
  MedicationCommandResult? confirmed;
  final keys = <String>[];
  MedicationApplication get application =>
      confirmed?.application ?? pendingMedication();
  late final repository = FakeMedicationsRepository()
    ..handler = (method, args) async {
      switch (method) {
        case 'loadApplicationHistory':
          return Success(
            MedicationHistoryPage(
              application: application,
              items: [if (confirmed != null) confirmed!.event!],
            ),
          );
        case 'loadDay':
          return Success(
            MedicationDayPage(
              day: args.first as String,
              serverNow: DateTime.utc(2026, 11, 1, 12, 6),
              agendaVersion: confirmed == null ? 1 : 2,
              items: [application],
            ),
          );
        case 'listTreatments':
          return const Success(MedicationTreatmentPage());
        case 'loadMonth':
          return Success(
            MedicationMonth(
              month: args.first as String,
              serverNow: DateTime.utc(2026, 11, 1, 12, 6),
              shelterToday: '2026-11-01',
              days: [
                MedicationDaySummary(
                  day: '2026-11-01',
                  pending: confirmed == null ? 1 : 0,
                  completed: confirmed == null ? 0 : 1,
                ),
              ],
            ),
          );
        case 'completeApplication':
          keys.add(args.last as String);
          confirmed = completedMedication(args.last as String);
          return failure == null
              ? Success(confirmed!)
              : Failure<MedicationCommandResult>(AppFailure(failure!));
        case 'getOperation':
          return Success<MedicationCommandResult?>(confirmed);
      }
      throw StateError('Unexpected scenario call');
    };
}
