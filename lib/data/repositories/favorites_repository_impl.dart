import 'dart:async';
import '../../utils/app_failure.dart';
import 'repository_result.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../services/favorites_storage_service.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  FavoritesRepositoryImpl(this.service);
  final FavoritesStorageService service;

  Set<String> _ids = {};
  Future<void> _pending = Future.value();
  @override
  Future<Result<Set<String>>> loadIds() async {
    final result = await mapRepositoryResult(
      service.loadIds,
      (ids) => Set<String>.unmodifiable(ids.where(isAnimalId)),
    );
    if (result case Success<Set<String>>(:final value)) _ids = value;
    return result;
  }

  @override
  Future<Result<Set<String>>> setFavorite(String id, bool value) {
    if (!isAnimalId(id)) {
      return Future.value(Failure(AppFailure(FailureCode.validation)));
    }
    final completer = Completer<Result<Set<String>>>();
    _pending = _pending.then((_) async {
      final loaded = await loadIds();
      if (loaded case Failure<Set<String>>(:final failure)) {
        completer.complete(Failure(failure));
        return;
      }
      final next = Set<String>.of(_ids);
      if (value) {
        next.add(id);
      } else {
        next.remove(id);
      }
      final saved = await mapRepositoryResult(
        () => service.saveIds(next),
        (_) => Set<String>.unmodifiable(next),
      );
      if (saved case Success<Set<String>>(:final value)) _ids = value;
      completer.complete(saved);
    });
    return completer.future;
  }
}
