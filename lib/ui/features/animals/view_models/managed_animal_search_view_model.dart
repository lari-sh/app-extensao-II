import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../domain/models/animal.dart';
import '../../../../domain/models/managed_animal_search_filter.dart';
import '../../../../domain/models/photo_content.dart';
import '../../../../domain/repositories/animals_repository.dart';
import '../../../../domain/repositories/photo_repository.dart';
import '../../../../utils/result.dart';
import '../../../../utils/app_failure.dart';
import '../../../core/view_models/public_list_view_model.dart'
    show failureMessage, animalStatusLabel;
part 'managed_animal_search_view_model.freezed.dart';

@freezed
abstract class ManagedAnimalSearchState with _$ManagedAnimalSearchState {
  const factory ManagedAnimalSearchState({
    @Default(ManagedAnimalSearchFilter()) ManagedAnimalSearchFilter filter,
    @Default(ManagedAnimalSearchFilter()) ManagedAnimalSearchFilter draft,
    @Default([]) List<ManagedAnimal> items,
    @Default({}) Map<String, List<int>> photos,
    @Default(0) int total,
    @Default(false) bool loading,
    @Default(false) bool loadingMore,
    String? cursor,
    String? message,
  }) = _ManagedAnimalSearchState;
}

class ManagedAnimalSearchViewModel extends ChangeNotifier {
  ManagedAnimalSearchViewModel(
    this.repository,
    this.photos, {
    required this.isAuthorized,
    this.authorize,
    this.accessEpoch,
    this.privateGeneration,
    this.onDispose,
    this.onFilterApplied,
  }) {
    _private = privateGeneration?.call();
  }
  final AnimalsRepository repository;
  final PhotoRepository photos;
  final bool Function() isAuthorized;
  final Future<bool> Function()? authorize;
  final int Function()? accessEpoch, privateGeneration;
  final VoidCallback? onDispose;
  final Future<void> Function(ManagedAnimalSearchFilter?)? onFilterApplied;
  ManagedAnimalSearchState _state = const ManagedAnimalSearchState();
  ManagedAnimalSearchState get state => _state;
  Timer? _timer;
  int _request = 0;
  int? _private;
  bool _disposed = false;
  bool get canSearch => !_disposed && isAuthorized();
  bool get showGlobalResults => canSearch && state.filter.hasCriteria;
  bool get canLoadMore =>
      showGlobalResults &&
      !state.loading &&
      !state.loadingMore &&
      state.cursor != null;
  String get countLabel =>
      '${state.total} ${state.total == 1 ? 'animal encontrado' : 'animais encontrados'}';
  String subtitle(PublicAnimal a) =>
      '${speciesLabels[a.species]} · ${sexLabels[a.sex]} · ${sizeLabels[a.size]} · ${a.color ?? 'Cor não informada'}';
  String statusLabel(PublicAnimal a) => animalStatusLabel(a.status);
  String publicationLabel(PublicAnimal a) =>
      a.isPublished ? 'Publicado' : 'Privado';
  static const speciesLabels = {
    AnimalSpecies.dog: 'Cachorro',
    AnimalSpecies.cat: 'Gato',
  };
  static const sexLabels = {AnimalSex.female: 'Fêmea', AnimalSex.male: 'Macho'};
  static const sizeLabels = {
    AnimalSize.small: 'Pequeno',
    AnimalSize.medium: 'Médio',
    AnimalSize.large: 'Grande',
  };
  static const statusLabels = {
    AnimalStatus.available: 'Disponível',
    AnimalStatus.treatment: 'Em tratamento',
    AnimalStatus.quarantine: 'Quarentena',
    AnimalStatus.adopted: 'Adotado',
  };
  Map<String, String> get chips => {
    if (state.filter.species != null)
      'species': speciesLabels[state.filter.species]!,
    if (state.filter.sex != null) 'sex': sexLabels[state.filter.sex]!,
    if (state.filter.size != null) 'size': sizeLabels[state.filter.size]!,
    if (state.filter.status != null)
      'status': statusLabels[state.filter.status]!,
    if (state.filter.color.isNotEmpty) 'color': state.filter.color,
  };
  void _publish(ManagedAnimalSearchState next) {
    if (!_disposed) {
      _state = next;
      notifyListeners();
    }
  }

  void refreshAccess() {
    if (_disposed) return;
    if ((privateGeneration == null && !isAuthorized()) ||
        _private != privateGeneration?.call()) {
      _private = privateGeneration?.call();
      _timer?.cancel();
      ++_request;
      _publish(const ManagedAnimalSearchState());
    } else {
      // Access checks can temporarily disable the fixed toolbar without changing
      // its criteria. Repaint capabilities when that check finishes as well.
      notifyListeners();
    }
  }

  void setQuery(String value) {
    if (!canSearch) return;
    _timer?.cancel();
    ++_request;
    _publish(
      state.copyWith(
        filter: state.filter.copyWith(query: value),
        items: [],
        photos: {},
        total: 0,
        cursor: null,
        loading: false,
        loadingMore: false,
        message: null,
      ),
    );
    if (state.filter.hasCriteria) {
      _timer = Timer(const Duration(milliseconds: 300), () {
        unawaited(search());
      });
    }
  }

  Future<void> submitQuery(String value) {
    setQuery(value);
    return search();
  }

  Future<void> clearText() {
    setQuery('');
    return search();
  }

  void clearAll() {
    _timer?.cancel();
    ++_request;
    _publish(const ManagedAnimalSearchState());
    if (onFilterApplied != null) unawaited(onFilterApplied!(null));
  }

  void beginFilters() => _publish(state.copyWith(draft: state.filter));
  void updateDraft(ManagedAnimalSearchFilter value) =>
      _publish(state.copyWith(draft: value));
  void cancelFilters() => _publish(state.copyWith(draft: state.filter));
  Future<void> applyFilters() {
    _publish(
      state.copyWith(
        filter: state.draft.copyWith(query: state.filter.query).normalized,
      ),
    );
    return search();
  }

  Future<void> clearFilters() {
    _publish(
      state.copyWith(
        filter: ManagedAnimalSearchFilter(query: state.filter.query),
        draft: ManagedAnimalSearchFilter(query: state.filter.query),
      ),
    );
    return search();
  }

  Future<void> removeFilter(String key) {
    final f = state.filter;
    _publish(
      state.copyWith(
        filter: switch (key) {
          'species' => f.copyWith(species: null),
          'sex' => f.copyWith(sex: null),
          'size' => f.copyWith(size: null),
          'status' => f.copyWith(status: null),
          'color' => f.copyWith(color: ''),
          _ => f,
        },
      ),
    );
    return search();
  }

  bool _current(int request, int? epoch, int? generation) =>
      !_disposed &&
      isAuthorized() &&
      request == _request &&
      epoch == accessEpoch?.call() &&
      generation == privateGeneration?.call();
  Future<void> search({bool next = false}) async {
    _timer?.cancel();
    if (!canSearch) {
      refreshAccess();
      return;
    }
    if (!state.filter.hasCriteria) {
      clearAll();
      return;
    }
    if (next && !canLoadMore) return;
    final request = next ? _request : ++_request;
    var epoch = accessEpoch?.call();
    final generation = privateGeneration?.call();
    final filter = state.filter.normalized;
    final cursor = next ? state.cursor : null;
    if (filter.validate().isNotEmpty) {
      _publish(
        state.copyWith(
          message: 'Use no máximo 80 caracteres por campo.',
          loading: false,
          loadingMore: false,
          items: [],
          photos: {},
          total: 0,
          cursor: null,
        ),
      );
      return;
    }
    _publish(
      state.copyWith(
        filter: filter,
        loading: !next,
        loadingMore: next,
        message: null,
        items: next ? state.items : [],
        photos: next ? state.photos : {},
        total: next ? state.total : 0,
        cursor: cursor,
      ),
    );
    try {
      if (authorize != null && !await authorize!()) {
        refreshAccess();
        if (_current(request, epoch, generation)) {
          clearAll();
        }
        return;
      }
      if (!next && onFilterApplied != null) await onFilterApplied!(filter);
      // Revalidation intentionally advances accessEpoch while retaining this owner.
      // Capture the confirmed epoch only after that check; generation/request still
      // reject a changed account or a newer query.
      epoch = accessEpoch?.call();
      if (!_current(request, epoch, generation)) return;
      final result = await repository.searchManagement(filter, cursor: cursor);
      if (!_current(request, epoch, generation)) return;
      if (result case Success<ManagedAnimalPage>(:final value)) {
        final old = next ? state.items : <ManagedAnimal>[];
        if (value.cursor != null && value.cursor == cursor ||
            value.items.any(
              (a) => old.any((b) => a.animal.id == b.animal.id),
            )) {
          _publish(
            state.copyWith(
              message:
                  'Não foi possível carregar a próxima página. Atualize a busca.',
              cursor: null,
            ),
          );
          return;
        }
        _publish(
          state.copyWith(
            items: [...old, ...value.items],
            total: value.total,
            cursor: value.cursor,
          ),
        );
        for (final item in value.items) {
          unawaited(_loadPhoto(item.animal, request, epoch, generation));
        }
      } else {
        await _failure((result as Failure<ManagedAnimalPage>).failure);
      }
    } catch (_) {
      if (_current(request, epoch, generation)) {
        _publish(
          state.copyWith(message: 'Não foi possível buscar. Tente novamente.'),
        );
      }
    } finally {
      if (_current(request, epoch, generation)) {
        _publish(state.copyWith(loading: false, loadingMore: false));
      }
    }
  }

  Future<void> _failure(AppFailure failure) async {
    if (failure.code == FailureCode.forbidden ||
        failure.code == FailureCode.unauthenticated) {
      clearAll();
      if (authorize != null) await authorize!();
      _publish(state.copyWith(message: failureMessage(failure)));
      return;
    }
    _publish(state.copyWith(message: failureMessage(failure)));
  }

  Future<void> _loadPhoto(
    PublicAnimal animal,
    int request,
    int? epoch,
    int? generation,
  ) async {
    if (animal.primaryPhotoId == null) return;
    try {
      final result = await photos.readPrimary(
        animal.id,
        animal.primaryPhotoId!,
      );
      if (!_current(request, epoch, generation)) return;
      if (result case Success<PhotoContent>(:final value)) {
        _publish(
          state.copyWith(photos: {...state.photos, animal.id: value.bytes}),
        );
      } else if (result case Failure<PhotoContent>(:final failure)) {
        if (failure.code == FailureCode.forbidden ||
            failure.code == FailureCode.unauthenticated) {
          await _failure(failure);
        }
      }
    } catch (_) {
      /* A failed optional image leaves the approved placeholder. */
    }
  }

  @override
  void dispose() {
    _disposed = true;
    ++_request;
    _timer?.cancel();
    _state = const ManagedAnimalSearchState();
    onDispose?.call();
    super.dispose();
  }
}
