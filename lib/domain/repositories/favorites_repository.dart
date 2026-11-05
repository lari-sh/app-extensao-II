import '../../utils/result.dart';

abstract interface class FavoritesRepository {
  Future<Result<Set<String>>> loadIds();
  Future<Result<Set<String>>> setFavorite(String id, bool value);
}
