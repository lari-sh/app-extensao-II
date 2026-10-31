import 'fake_behavior.dart';
import 'package:abrigo_dos_anjos/data/services/favorites_storage_service.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';

class FakeFavoritesStorageService extends FakeBehavior
    implements FavoritesStorageService {
  @override
  Future<Result<Set<String>>> loadIds() => invoke<Set<String>>('loadIds', []);
  @override
  Future<Result<Unit>> saveIds(Set<String> ids) =>
      invoke<Unit>('saveIds', [ids]);
}
