import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/data/repositories/favorites_repository_impl.dart';
import 'package:abrigo_dos_anjos/data/services/shared_preferences_favorites_service.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import '../support/public_app_harness.dart';
import '../support/public_fixtures.dart';

void main() {
  test(
    'upgrade ignores demonstration animals and preserves valid favorite IDs including unavailable IDs',
    () async {
      final values = <String, Object>{
        'demo_animals_v1': '[{"id":"demo","clinicalNotes":"legacy"}]',
        'favorites_v1': ['demo', 'invalid', fixtureId(1), fixtureId(999)],
      };
      final reads = <String>[];
      final writes = <String>[];
      final service = SharedPreferencesFavoritesService.withOperations(
        read: (key) async {
          reads.add(key);
          return values[key] as List<String>?;
        },
        write: (key, ids) async {
          writes.add(key);
          values[key] = ids;
        },
      );
      final repo = FavoritesRepositoryImpl(service);
      expect((await repo.loadIds() as Success<Set<String>>).value, {
        fixtureId(1),
        fixtureId(999),
      });
      await repo.setFavorite(fixtureId(2), true);
      expect(reads.every((key) => key == 'favorites_v1'), true);
      expect(writes, ['favorites_v1']);
      expect(
        values['demo_animals_v1'],
        '[{"id":"demo","clinicalNotes":"legacy"}]',
      );
      expect(
        values['favorites_v1'],
        unorderedEquals([fixtureId(1), fixtureId(999), fixtureId(2)]),
      );
    },
  );
  testWidgets(
    'old demonstration route is unavailable and opening public app never writes animals',
    (tester) async {
      final harness = PublicAppHarness();
      await tester.pumpWidget(harness.app());
      await tester.pumpAndSettle();
      final context = tester.element(find.text('Quero Adotar (Visitante)'));
      Navigator.pushNamed(context, '/demo');
      await tester.pumpAndSettle();
      expect(find.text('Página não encontrada.'), findsOneWidget);
      expect(
        harness.animals.calls.where((call) => call.method == 'saveAnimal'),
        isEmpty,
      );
    },
  );
}
