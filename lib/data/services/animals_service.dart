import '../../utils/result.dart';
import '../models/animal_dto.dart';

abstract interface class AnimalsService {
  Future<Result<AnimalsPageDto>> listPublic({
    required Map<String, String> filters,
    String? cursor,
  });
  Future<Result<AnimalDto>> getPublic(String id);
  Future<Result<List<AnimalDto>>> getVisibleByIds(Set<String> ids);
  Future<Result<ManagedAnimalsPageDto>> listManagement({
    String? status,
    String? cursor,
  });
  Future<Result<ManagedAnimalsPageDto>> searchManagement({
    required Map<String, String> filters,
    String? cursor,
  });
  Future<Result<ManagedAnimalDto>> getManagement(String id);
  Future<Result<Map<String, int>>> getStatusCounts();
  Future<Result<ManagedAnimalDto>> saveAnimal(
    Map<String, Object?> payload,
    String operationKey,
  );
  Future<Result<AnimalDto>> setStatus(
    String id,
    String status,
    String operationKey,
  );
  Future<Result<AnimalDto>> setPublication(
    String id,
    bool published,
    String operationKey,
  );
  Future<Result<Map<String, dynamic>?>> getOperation(String operationKey);
}
