import 'package:freezed_annotation/freezed_annotation.dart';
import 'medication_application.dart';
import 'medication_treatment.dart';
part 'medication_agenda.freezed.dart';

@freezed
abstract class MedicationDaySummary with _$MedicationDaySummary {
  const factory MedicationDaySummary({
    required String day,
    @Default(0) int pending,
    @Default(0) int completed,
    @Default(0) int cancelled,
  }) = _MedicationDaySummary;
}

@freezed
abstract class MedicationMonth with _$MedicationMonth {
  const factory MedicationMonth({
    required String month,
    required DateTime serverNow,
    required String shelterToday,
    @Default([]) List<MedicationDaySummary> days,
  }) = _MedicationMonth;
}

@freezed
abstract class MedicationDayPage with _$MedicationDayPage {
  const factory MedicationDayPage({
    required String day,
    required DateTime serverNow,
    required int agendaVersion,
    @Default([]) List<MedicationApplication> items,
    String? cursor,
  }) = _MedicationDayPage;
}

@freezed
abstract class MedicationTreatmentPage with _$MedicationTreatmentPage {
  const factory MedicationTreatmentPage({
    @Default([]) List<MedicationTreatment> items,
    String? cursor,
  }) = _MedicationTreatmentPage;
}

@freezed
abstract class MedicationHistoryPage with _$MedicationHistoryPage {
  const factory MedicationHistoryPage({
    required MedicationApplication application,
    @Default([]) List<MedicationApplicationEvent> items,
    String? cursor,
  }) = _MedicationHistoryPage;
}
