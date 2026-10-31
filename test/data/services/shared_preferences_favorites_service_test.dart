import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:abrigo_dos_anjos/data/services/shared_preferences_favorites_service.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';

void main() {
  setUp(
    () => SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty(),
  );
  test('only favorite IDs persist under the existing key', () async {
    final preferences = SharedPreferencesAsync();
    final service = SharedPreferencesFavoritesService(preferences);
    expect((await service.loadIds() as Success<Set<String>>).value, isEmpty);
    expect(await service.saveIds({'id-1', 'id-2'}), isA<Success>());
    expect(
      await preferences.getStringList('favorites_v1'),
      unorderedEquals(['id-1', 'id-2']),
    );
    expect(
      (await SharedPreferencesFavoritesService(preferences).loadIds()
              as Success<Set<String>>)
          .value,
      {'id-1', 'id-2'},
    );
  });
}
