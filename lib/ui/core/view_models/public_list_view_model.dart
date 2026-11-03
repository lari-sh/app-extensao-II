import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../domain/models/animal.dart';
import '../../../domain/models/animal_query.dart';
import '../../../domain/models/photo_content.dart';
import '../../../domain/repositories/animals_repository.dart';
import '../../../domain/repositories/favorites_repository.dart';
import '../../../domain/repositories/photo_repository.dart';
import '../../../utils/app_failure.dart';
import '../../../utils/result.dart';
part 'public_list_view_model.freezed.dart';

@freezed
abstract class AnimalCardState with _$AnimalCardState {
  const factory AnimalCardState({
    required String id,
    required String name,
    required String description,
    required String statusLabel,
    String? photoId,
    List<int>? photo,
    @Default(false) bool isFavorite,
  }) = _AnimalCardState;
}

@freezed
abstract class PublicListState with _$PublicListState {
  const factory PublicListState({
    @Default([]) List<AnimalCardState> items,
    @Default(false) bool busy,
    @Default(false) bool favoritesReady,
    @Default({}) Set<String> updatingFavorites,
    @Default(0) int total,
    String? cursor,
    String? message,
    @Default(AnimalQuery()) AnimalQuery query,
  }) = _PublicListState;
}

String failureMessage(AppFailure failure) => switch (failure.code) {
  FailureCode.network || FailureCode.timeout =>
    'Não foi possível conectar. Verifique sua conexão e tente novamente.',
  FailureCode.notFound => 'Este animal não está disponível.',
  FailureCode.configuration => 'Serviço indisponível no momento.',
  FailureCode.unauthenticated ||
  FailureCode.forbidden => 'Seu acesso não permite esta ação.',
  _ => 'Não foi possível concluir. Tente novamente.',
};
String animalStatusLabel(AnimalStatus status) => switch (status) {
  AnimalStatus.available => 'Disponível para adoção',
  AnimalStatus.treatment => 'Em tratamento',
  AnimalStatus.quarantine => 'Em quarentena',
  AnimalStatus.adopted => 'Adotado',
};
AnimalCardState animalCard(
  PublicAnimal animal,
  Set<String> ids,
) => AnimalCardState(
  id: animal.id,
  name: animal.name,
  description:
      '${animal.species == AnimalSpecies.dog ? 'Cachorro' : 'Gato'} • ${animal.approximateAge}',
  statusLabel: animalStatusLabel(animal.status),
  photoId: animal.primaryPhotoId,
  isFavorite: ids.contains(animal.id),
);

abstract class PublicListViewModel extends ChangeNotifier {
  PublicListViewModel(
    this.animals,
    this.favorites,
    this.photos, {
    this.favoritesOnly = false,
  });
  final AnimalsRepository animals;
  final FavoritesRepository favorites;
  final PhotoRepository photos;
  final bool favoritesOnly;
  PublicListState _state = const PublicListState();
  PublicListState get state => _state;
  bool _disposed = false;
  int _generation = 0;
  final speciesOptions = const {
    '': 'Todas as espécies',
    'dog': 'Cachorro',
    'cat': 'Gato',
  };
  final sexOptions = const {
    '': 'Todos os sexos',
    'female': 'Fêmea',
    'male': 'Macho',
  };
  final sizeOptions = const {
    '': 'Todos os portes',
    'small': 'Pequeno',
    'medium': 'Médio',
    'large': 'Grande',
  };
  String get speciesValue => state.query.species?.name ?? '';
  String get sexValue => state.query.sex?.name ?? '';
  String get sizeValue => state.query.size?.name ?? '';
  String detailRoute(String id) => '/detail';
  bool canToggleFavorite(String id) =>
      state.favoritesReady && !state.updatingFavorites.contains(id);
  void _publish(PublicListState next) {
    if (!_disposed) {
      _state = next;
      notifyListeners();
    }
  }

  Future<void> load({bool next = false}) async {
    if (_disposed || (next && (state.busy || state.cursor == null))) return;
    final generation = next ? _generation : ++_generation;
    final query = state.query;
    final cursor = next ? state.cursor : null;
    _publish(
      state.copyWith(
        busy: true,
        message: null,
        items: next ? state.items : [],
        cursor: next ? state.cursor : null,
      ),
    );
    try {
      final ids = await favorites.loadIds();
      if (_disposed || generation != _generation) return;
      final favoriteIds = ids is Success<Set<String>> ? ids.value : <String>{};
      final Result<AnimalPage> page;
      if (favoritesOnly) {
        if (ids case Failure<Set<String>>(:final failure)) {
          _publish(
            state.copyWith(
              message: failureMessage(failure),
              favoritesReady: false,
            ),
          );
          return;
        }
        final visible = await animals.getVisibleByIds(favoriteIds);
        page = switch (visible) {
          Success<List<PublicAnimal>>(:final value) => Success(
            AnimalPage(items: value, total: value.length),
          ),
          Failure<List<PublicAnimal>>(:final failure) => Failure(failure),
        };
      } else {
        page = await animals.listPublic(query, cursor: cursor);
      }
      if (_disposed || generation != _generation) return;
      switch (page) {
        case Failure<AnimalPage>(:final failure):
          _publish(state.copyWith(message: failureMessage(failure)));
        case Success<AnimalPage>(:final value):
          final cards = value.items
              .map((animal) => animalCard(animal, favoriteIds))
              .toList();
          final combined = [if (next) ...state.items, ...cards];
          final unique = <String, AnimalCardState>{
            for (final card in combined) card.id: card,
          };
          _publish(
            state.copyWith(
              items: List.unmodifiable(unique.values),
              total: value.total,
              cursor: value.cursor,
              favoritesReady: ids is Success<Set<String>>,
              message: ids is Failure<Set<String>>
                  ? failureMessage(ids.failure)
                  : null,
            ),
          );
          for (final card in cards) {
            if (card.photoId != null) unawaited(_loadPhoto(card, generation));
          }
      }
    } catch (_) {
      if (!_disposed && generation == _generation) {
        _publish(
          state.copyWith(
            message: 'Não foi possível carregar os animais. Tente novamente.',
          ),
        );
      }
    } finally {
      if (!_disposed && generation == _generation) {
        _publish(state.copyWith(busy: false));
      }
    }
  }

  Future<void> _loadPhoto(AnimalCardState card, int generation) async {
    final result = await photos.readPrimary(card.id, card.photoId!);
    if (_disposed || generation != _generation) return;
    if (result case Success<PhotoContent>(:final value)) {
      _publish(
        state.copyWith(
          items: state.items
              .map(
                (item) => item.id == card.id
                    ? item.copyWith(photo: value.bytes)
                    : item,
              )
              .toList(),
        ),
      );
    }
  }

  Future<void> toggleFavorite(String id) async {
    if (_disposed ||
        !state.favoritesReady ||
        state.updatingFavorites.contains(id)) {
      return;
    }
    final matching = state.items.where((item) => item.id == id);
    if (matching.isEmpty) return;
    final desired = !matching.first.isFavorite;
    _publish(
      state.copyWith(
        updatingFavorites: {...state.updatingFavorites, id},
        message: null,
      ),
    );
    try {
      final result = await favorites.setFavorite(id, desired);
      if (_disposed) return;
      switch (result) {
        case Failure<Set<String>>(:final failure):
          _publish(state.copyWith(message: failureMessage(failure)));
        case Success<Set<String>>(:final value):
          final items = state.items
              .where((item) => !favoritesOnly || value.contains(item.id))
              .map((item) => item.copyWith(isFavorite: value.contains(item.id)))
              .toList();
          _publish(
            state.copyWith(
              items: items,
              total: favoritesOnly ? items.length : state.total,
            ),
          );
      }
    } catch (_) {
      if (!_disposed) {
        _publish(
          state.copyWith(message: 'Não foi possível atualizar seus favoritos.'),
        );
      }
    } finally {
      if (!_disposed) {
        _publish(
          state.copyWith(
            updatingFavorites: {...state.updatingFavorites}..remove(id),
          ),
        );
      }
    }
  }

  Future<void> setFilters({
    String? name,
    String? species,
    String? sex,
    String? size,
  }) async {
    if ((species != null && !speciesOptions.containsKey(species)) ||
        (sex != null && !sexOptions.containsKey(sex)) ||
        (size != null && !sizeOptions.containsKey(size))) {
      _publish(state.copyWith(message: 'Filtro inválido.'));
      return;
    }
    _publish(
      state.copyWith(
        query: state.query.copyWith(
          name: name ?? state.query.name,
          species: species == null
              ? state.query.species
              : species.isEmpty
              ? null
              : AnimalSpecies.values.byName(species),
          sex: sex == null
              ? state.query.sex
              : sex.isEmpty
              ? null
              : AnimalSex.values.byName(sex),
          size: size == null
              ? state.query.size
              : size.isEmpty
              ? null
              : AnimalSize.values.byName(size),
        ),
      ),
    );
    await load();
  }

  @protected
  void rejectSearch(String message) {
    if (_disposed) return;
    ++_generation;
    _publish(state.copyWith(busy: false, message: message));
  }

  Future<void> clearFilters() async {
    _publish(state.copyWith(query: const AnimalQuery()));
    await load();
  }

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    super.dispose();
  }
}
