import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/data/repositories/favorites_repository_impl.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import 'package:abrigo_dos_anjos/utils/app_failure.dart';
import '../../support/fakes/fake_favorites_storage_service.dart';
import '../../support/public_fixtures.dart';

void main() {
  test(
    'favorite state changes only after successful persistence and ignores demo IDs',
    () async {
      var fail = false;
      var stored = <String>{fixtureId(1), 'A0024'};
      final service = FakeFavoritesStorageService()
        ..handler = (method, args) async {
          if (method == 'loadIds') return Success(Set<String>.of(stored));
          if (fail) return Failure<Unit>(AppFailure(FailureCode.unknown));
          stored = Set<String>.of(args.first as Set<String>);
          return const Success(Unit.value);
        };
      final repo = FavoritesRepositoryImpl(service);
      expect((await repo.loadIds() as Success<Set<String>>).value, {
        fixtureId(1),
      });
      fail = true;
      expect(await repo.setFavorite(fixtureId(1), false), isA<Failure>());
      fail = false;
      expect((await repo.loadIds() as Success<Set<String>>).value, {
        fixtureId(1),
      });
      await Future.wait([
        repo.setFavorite(fixtureId(2), true),
        repo.setFavorite(fixtureId(3), true),
      ]);
      expect(stored, {fixtureId(1), fixtureId(2), fixtureId(3)});
      final calls = service.calls.length;
      expect(await repo.setFavorite('A0024', true), isA<Failure>());
      expect(service.calls.length, calls);
    },
  );
}
