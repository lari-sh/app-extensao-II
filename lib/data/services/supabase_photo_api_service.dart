import '../../utils/app_failure.dart';
import 'service_result.dart';
import '../../utils/result.dart';
import '../models/photo_dto.dart';
import 'photo_api_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabasePhotoApiService implements PhotoApiService {
  SupabasePhotoApiService(this.client);
  final SupabaseClient client;
  @override
  Future<Result<PhotoBytesDto>> readPrimary(String animalId, String photoId) =>
      serviceResult(() async {
        final response = await client.functions.invoke(
          'animal-photo-read',
          method: HttpMethod.get,
          headers: {'Accept': 'application/octet-stream'},
          queryParameters: {'animal_id': animalId, 'photo_id': photoId},
        );
        final bytes = response.data;
        if (bytes is! List<int> || bytes.length < 3 || bytes.length > 5242880) {
          throw const ServiceFailure(FailureCode.validation);
        }
        final png =
            bytes.length >= 8 &&
            bytes[0] == 137 &&
            bytes[1] == 80 &&
            bytes[2] == 78 &&
            bytes[3] == 71;
        final jpeg = bytes[0] == 255 && bytes[1] == 216 && bytes[2] == 255;
        if (!png && !jpeg) throw const ServiceFailure(FailureCode.validation);
        return PhotoBytesDto(
          bytes: bytes,
          mime: png ? 'image/png' : 'image/jpeg',
        );
      });
  @override
  Future<Result<PhotoJobDto>> uploadPrimary(
    String animalId,
    List<int> bytes,
    String mime,
    String operationKey,
  ) async => Failure(AppFailure(FailureCode.configuration));
  @override
  Future<Result<PhotoJobDto>> getUpload(String operationKey) async =>
      Failure(AppFailure(FailureCode.configuration));
}
