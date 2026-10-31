import '../../utils/result.dart';
import 'favorites_storage_service.dart';
import 'service_result.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesFavoritesService implements FavoritesStorageService {
  SharedPreferencesFavoritesService(SharedPreferencesAsync preferences)
    : read = preferences.getStringList,
      write = preferences.setStringList;
  SharedPreferencesFavoritesService.withOperations({
    required this.read,
    required this.write,
  });
  final Future<List<String>?> Function(String) read;
  final Future<void> Function(String, List<String>) write;
  @override
  Future<Result<Set<String>>> loadIds() => serviceResult(
    () async => Set<String>.unmodifiable(await read('favorites_v1') ?? []),
  );
  @override
  Future<Result<Unit>> saveIds(Set<String> ids) => serviceResult(() async {
    await write('favorites_v1', ids.toList());
    return Unit.value;
  });
}
