import 'fake_behavior.dart';
import 'package:abrigo_dos_anjos/domain/models/managed_animal_search_filter.dart';
import 'package:abrigo_dos_anjos/domain/repositories/animals_repository.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import 'package:abrigo_dos_anjos/domain/models/animal.dart';
import 'package:abrigo_dos_anjos/domain/models/animal_draft.dart';
import 'package:abrigo_dos_anjos/domain/models/animal_query.dart';

class FakeAnimalsRepository extends FakeBehavior implements AnimalsRepository {
  @override
  Future<Result<AnimalPage>> listPublic(AnimalQuery query, {String? cursor}) =>
      invoke<AnimalPage>('listPublic', [query, cursor]);
  @override
  Future<Result<PublicAnimal>> getPublic(String id) =>
      invoke<PublicAnimal>('getPublic', [id]);
  @override
  Future<Result<List<PublicAnimal>>> getVisibleByIds(Set<String> ids) =>
      invoke<List<PublicAnimal>>('getVisibleByIds', [ids]);
  @override
  Future<Result<ManagedAnimalPage>> listManagement({
    AnimalStatus? status,
    String? cursor,
  }) => invoke<ManagedAnimalPage>('listManagement', [status, cursor]);
  @override
  Future<Result<ManagedAnimalPage>> searchManagement(
    ManagedAnimalSearchFilter filter, {
    String? cursor,
  }) => invoke<ManagedAnimalPage>('searchManagement', [filter, cursor]);
  @override
  Future<Result<ManagedAnimal>> getManagement(String id) =>
      invoke<ManagedAnimal>('getManagement', [id]);
  @override
  Future<Result<Map<AnimalStatus, int>>> getStatusCounts() =>
      invoke<Map<AnimalStatus, int>>('getStatusCounts', []);
  @override
  Future<Result<ManagedAnimal>> saveAnimal(
    AnimalDraft draft,
    String operationKey,
  ) => invoke<ManagedAnimal>('saveAnimal', [draft, operationKey]);
  @override
  Future<Result<PublicAnimal>> setStatus(
    String id,
    AnimalStatus status,
    String operationKey,
  ) => invoke<PublicAnimal>('setStatus', [id, status, operationKey]);
  @override
  Future<Result<PublicAnimal>> setPublication(
    String id,
    bool published,
    String operationKey,
  ) => invoke<PublicAnimal>('setPublication', [id, published, operationKey]);
  @override
  Future<Result<ManagedAnimal?>> getOperation(String operationKey) =>
      invoke<ManagedAnimal?>('getOperation', [operationKey]);
}
