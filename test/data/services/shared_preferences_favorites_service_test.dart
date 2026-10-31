import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/data/services/shared_preferences_favorites_service.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import 'package:abrigo_dos_anjos/utils/app_failure.dart';

void main() {
  test(
    'only favorite IDs persist under the existing key through controlled storage operations',
    () async {
      final values = <String, List<String>>{};
      SharedPreferencesFavoritesService service() =>
          SharedPreferencesFavoritesService.withOperations(
            read: (key) async => values[key],
            write: (key, ids) async {
              values[key] = ids;
            },
          );
      expect(
        (await service().loadIds() as Success<Set<String>>).value,
        isEmpty,
      );
      expect(await service().saveIds({'id-1', 'id-2'}), isA<Success>());
      expect(values.keys, ['favorites_v1']);
      expect((await service().loadIds() as Success<Set<String>>).value, {
        'id-1',
        'id-2',
      });
    },
  );
  test('storage read and write errors stay sanitized', () async {
    final service = SharedPreferencesFavoritesService.withOperations(
      read: (_) async => throw StateError('private'),
      write: (_, _) async => throw StateError('private'),
    );
    expect(
      (await service.loadIds() as Failure).failure.code,
      FailureCode.unknown,
    );
    expect(await service.saveIds({'id'}), isA<Failure>());
  });
}
