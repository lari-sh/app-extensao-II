import 'package:freezed_annotation/freezed_annotation.dart';
part 'photo_selection_request.freezed.dart';

@freezed
abstract class PhotoSelectionRequest with _$PhotoSelectionRequest {
  const factory PhotoSelectionRequest({
    required String animalId,
    required String userId,
  }) = _PhotoSelectionRequest;
}
