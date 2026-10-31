import '../../utils/result.dart';
import '../models/photo_candidate.dart';
import '../models/photo_content.dart';
import '../models/photo_upload_state.dart';

abstract interface class PhotoRepository {
  Future<Result<PhotoCandidate?>> pickFromGallery();
  Future<Result<PhotoCandidate?>> recoverLostSelection();
  Future<Result<PhotoContent>> readPrimary(String animalId, String photoId);
  Future<Result<PhotoUploadState>> uploadPrimary(
    String animalId,
    PhotoCandidate candidate,
    String operationKey,
  );
  Future<Result<PhotoUploadState>> getUpload(String operationKey);
}
