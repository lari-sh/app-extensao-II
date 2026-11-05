import '../../utils/result.dart';
import '../models/photo_dto.dart';

abstract interface class PhotoApiService {
  Future<Result<PhotoBytesDto>> readPrimary(String animalId, String photoId);
  Future<Result<PhotoJobDto>> uploadPrimary(
    String animalId,
    List<int> bytes,
    String mime,
    String operationKey,
  );
  Future<Result<PhotoJobDto>> getUpload(String operationKey);
}
