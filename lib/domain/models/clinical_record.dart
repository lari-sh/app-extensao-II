import 'package:freezed_annotation/freezed_annotation.dart';
part 'clinical_record.freezed.dart';

enum ClinicalRecordKind { vaccination, deworming, medication }

@freezed
abstract class ClinicalRecord with _$ClinicalRecord {
  const factory ClinicalRecord({
    String? id,
    required ClinicalRecordKind kind,
    required String description,
  }) = _ClinicalRecord;
}
