import 'package:freezed_annotation/freezed_annotation.dart';
part 'photo_candidate.freezed.dart';

@freezed
abstract class PhotoCandidate with _$PhotoCandidate {
  const factory PhotoCandidate({
    required List<int> bytes,
    required String mime,
  }) = _PhotoCandidate;
}
