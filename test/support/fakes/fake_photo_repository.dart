import 'fake_behavior.dart';
import 'package:abrigo_dos_anjos/domain/repositories/photo_repository.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import 'package:abrigo_dos_anjos/domain/models/photo_candidate.dart';
import 'package:abrigo_dos_anjos/domain/models/photo_content.dart';
import 'package:abrigo_dos_anjos/domain/models/photo_upload_state.dart';

class FakePhotoRepository extends FakeBehavior implements PhotoRepository {
  @override
  Future<Result<PhotoCandidate?>> pickFromGallery() =>
      invoke<PhotoCandidate?>('pickFromGallery', []);
  @override
  Future<Result<PhotoCandidate?>> recoverLostSelection() =>
      invoke<PhotoCandidate?>('recoverLostSelection', []);
  @override
  Future<Result<PhotoContent>> readPrimary(String animalId, String photoId) =>
      invoke<PhotoContent>('readPrimary', [animalId, photoId]);
  @override
  Future<Result<PhotoUploadState>> uploadPrimary(
    String animalId,
    PhotoCandidate candidate,
    String operationKey,
  ) => invoke<PhotoUploadState>('uploadPrimary', [
    animalId,
    candidate,
    operationKey,
  ]);
  @override
  Future<Result<PhotoUploadState>> getUpload(String operationKey) =>
      invoke<PhotoUploadState>('getUpload', [operationKey]);
}
