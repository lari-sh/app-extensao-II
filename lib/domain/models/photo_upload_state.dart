import 'package:freezed_annotation/freezed_annotation.dart';
part 'photo_upload_state.freezed.dart';

enum PhotoJobStatus {
  pending,
  validated,
  attached,
  cleanupNeeded,
  cleaned,
  failed,
}

@freezed
abstract class PhotoUploadState with _$PhotoUploadState {
  const factory PhotoUploadState({
    required String jobId,
    required PhotoJobStatus status,
    String? photoId,
    String? currentPhotoId,
  }) = _PhotoUploadState;
}
