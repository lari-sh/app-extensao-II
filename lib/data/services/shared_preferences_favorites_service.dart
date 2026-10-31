import '../../utils/result.dart';
import 'favorites_storage_service.dart';
import 'service_result.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesFavoritesService implements FavoritesStorageService {
  SharedPreferencesFavoritesService(this.preferences);
  final SharedPreferencesAsync preferences;
  @override
  Future<Result<Set<String>>> loadIds() => serviceResult(
    () async => Set<String>.unmodifiable(
      await preferences.getStringList('favorites_v1') ?? [],
    ),
  );
  @override
  Future<Result<Unit>> saveIds(Set<String> ids) => serviceResult(() async {
    await preferences.setStringList('favorites_v1', ids.toList());
    return Unit.value;
  });
}
