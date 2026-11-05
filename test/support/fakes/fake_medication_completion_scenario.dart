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
  final history = <MedicationApplicationEvent>[];
  final receipts = <String, MedicationCommandResult>{};
  MedicationApplication get application =>
      confirmed?.application ?? pendingMedication();
  late final repository = FakeMedicationsRepository()
    ..handler = (method, args) async {
      switch (method) {
        case 'loadApplicationHistory':
          return Success(
            MedicationHistoryPage(
              application: application,
              items: List.of(history),
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
                  pending:
                      application.state == MedicationApplicationState.pending
                      ? 1
                      : 0,
                  completed:
                      application.state == MedicationApplicationState.completed
                      ? 1
                      : 0,
                ),
              ],
            ),
          );
        case 'completeApplication':
          keys.add(args.last as String);
          confirmed = completedMedication(
            args.last as String,
            application: application,
          );
          history.add(confirmed!.event!);
          receipts[args.last as String] = confirmed!;
          return failure == null
              ? Success(confirmed!)
              : Failure<MedicationCommandResult>(AppFailure(failure!));
        case 'reverseCompletion':
          keys.add(args.last as String);
          confirmed = reversedMedication(
            args.last as String,
            application,
            (args[1] as String).trim(),
          );
          history.add(confirmed!.event!);
          receipts[args.last as String] = confirmed!;
          return failure == null
              ? Success(confirmed!)
              : Failure<MedicationCommandResult>(AppFailure(failure!));
        case 'getOperation':
          return Success<MedicationCommandResult?>(receipts[args.single]);
      }
      throw StateError('Unexpected scenario call');
    };
}
