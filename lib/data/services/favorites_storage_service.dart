import '../../utils/result.dart';

abstract interface class FavoritesStorageService {
  Future<Result<Set<String>>> loadIds();
  Future<Result<Unit>> saveIds(Set<String> ids);
}
