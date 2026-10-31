import '../../utils/result.dart';
import '../models/animal.dart';
import '../models/animal_draft.dart';
import '../models/animal_query.dart';

abstract interface class AnimalsRepository {
  Future<Result<AnimalPage>> listPublic(AnimalQuery query, {String? cursor});
  Future<Result<PublicAnimal>> getPublic(String id);
  Future<Result<List<PublicAnimal>>> getVisibleByIds(Set<String> ids);
  Future<Result<ManagedAnimalPage>> listManagement({
    AnimalStatus? status,
    String? cursor,
  });
  Future<Result<ManagedAnimal>> getManagement(String id);
  Future<Result<Map<AnimalStatus, int>>> getStatusCounts();
  Future<Result<ManagedAnimal>> saveAnimal(
    AnimalDraft draft,
    String operationKey,
  );
  Future<Result<PublicAnimal>> setStatus(
    String id,
    AnimalStatus status,
    String operationKey,
  );
  Future<Result<PublicAnimal>> setPublication(
    String id,
    bool published,
    String operationKey,
  );
  Future<Result<ManagedAnimal?>> getOperation(String operationKey);
}
