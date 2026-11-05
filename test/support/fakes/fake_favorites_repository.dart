import 'fake_behavior.dart';
import 'package:abrigo_dos_anjos/domain/repositories/favorites_repository.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';

class FakeFavoritesRepository extends FakeBehavior
    implements FavoritesRepository {
  @override
  Future<Result<Set<String>>> loadIds() => invoke<Set<String>>('loadIds', []);
  @override
  Future<Result<Set<String>>> setFavorite(String id, bool value) =>
      invoke<Set<String>>('setFavorite', [id, value]);
}
