import 'fake_behavior.dart';
import 'package:abrigo_dos_anjos/data/services/animals_service.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import 'package:abrigo_dos_anjos/data/models/animal_dto.dart';

class FakeAnimalsService extends FakeBehavior implements AnimalsService {
  @override
  Future<Result<AnimalsPageDto>> listPublic({
    required Map<String, String> filters,
    String? cursor,
  }) => invoke<AnimalsPageDto>('listPublic', [filters, cursor]);
  @override
  Future<Result<AnimalDto>> getPublic(String id) =>
      invoke<AnimalDto>('getPublic', [id]);
  @override
  Future<Result<List<AnimalDto>>> getVisibleByIds(Set<String> ids) =>
      invoke<List<AnimalDto>>('getVisibleByIds', [ids]);
  @override
  Future<Result<ManagedAnimalsPageDto>> listManagement({
    String? status,
    String? cursor,
  }) => invoke<ManagedAnimalsPageDto>('listManagement', [status, cursor]);
  @override
  Future<Result<ManagedAnimalDto>> getManagement(String id) =>
      invoke<ManagedAnimalDto>('getManagement', [id]);
  @override
  Future<Result<Map<String, int>>> getStatusCounts() =>
      invoke<Map<String, int>>('getStatusCounts', []);
  @override
  Future<Result<ManagedAnimalDto>> saveAnimal(
    Map<String, Object?> payload,
    String operationKey,
  ) => invoke<ManagedAnimalDto>('saveAnimal', [payload, operationKey]);
  @override
  Future<Result<AnimalDto>> setStatus(
    String id,
    String status,
    String operationKey,
  ) => invoke<AnimalDto>('setStatus', [id, status, operationKey]);
  @override
  Future<Result<AnimalDto>> setPublication(
    String id,
    bool published,
    String operationKey,
  ) => invoke<AnimalDto>('setPublication', [id, published, operationKey]);
  @override
  Future<Result<Map<String, dynamic>?>> getOperation(String operationKey) =>
      invoke<Map<String, dynamic>?>('getOperation', [operationKey]);
}
