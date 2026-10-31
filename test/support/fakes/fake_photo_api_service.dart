import 'fake_behavior.dart';
import 'package:abrigo_dos_anjos/data/services/photo_api_service.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import 'package:abrigo_dos_anjos/data/models/photo_dto.dart';

class FakePhotoApiService extends FakeBehavior implements PhotoApiService {
  @override
  Future<Result<PhotoBytesDto>> readPrimary(String animalId, String photoId) =>
      invoke<PhotoBytesDto>('readPrimary', [animalId, photoId]);
  @override
  Future<Result<PhotoJobDto>> uploadPrimary(
    String animalId,
    List<int> bytes,
    String mime,
    String operationKey,
  ) => invoke<PhotoJobDto>('uploadPrimary', [
    animalId,
    bytes,
    mime,
    operationKey,
  ]);
  @override
  Future<Result<PhotoJobDto>> getUpload(String operationKey) =>
      invoke<PhotoJobDto>('getUpload', [operationKey]);
}
