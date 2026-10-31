import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../domain/models/animal.dart';
import '../../../../domain/models/photo_content.dart';
import '../../../../domain/repositories/animals_repository.dart';
import '../../../../domain/repositories/favorites_repository.dart';
import '../../../../domain/repositories/photo_repository.dart';
import '../../../../domain/repositories/adoption_message_repository.dart';
import '../../../../utils/result.dart';
import '../../../core/view_models/public_list_view_model.dart';
part 'animal_detail_view_model.freezed.dart';

@freezed
abstract class AnimalDetailState with _$AnimalDetailState {
  const factory AnimalDetailState({
    @Default('Detalhes do animal') String title,
    @Default('') String description,
    @Default('') String characteristics,
    @Default('') String statusLabel,
    @Default(false) bool busy,
    @Default(false) bool copying,
    @Default(false) bool canAdopt,
    List<int>? photo,
    String? message,
  }) = _AnimalDetailState;
}

class AnimalDetailViewModel extends ChangeNotifier {
  AnimalDetailViewModel(
    this.animals,
    this.favorites,
    this.photos,
    this.adoption,
  );
  final AnimalsRepository animals;
  final FavoritesRepository favorites;
  final PhotoRepository photos;
  final AdoptionMessageRepository adoption;
  AnimalDetailState _state = const AnimalDetailState();
  AnimalDetailState get state => _state;
  PublicAnimal? _animal;
  int _generation = 0;
  bool _disposed = false;
  void _publish(AnimalDetailState value) {
    if (!_disposed) {
      _state = value;
      notifyListeners();
    }
  }

  Future<void> load(String id) async {
    final generation = ++_generation;
    _animal = null;
    _publish(const AnimalDetailState(busy: true));
    try {
      final result = await animals.getPublic(id);
      if (_disposed || generation != _generation) return;
      switch (result) {
        case Failure<PublicAnimal>(:final failure):
          _publish(state.copyWith(message: failureMessage(failure)));
        case Success<PublicAnimal>(:final value):
          _animal = value;
          _publish(
            state.copyWith(
              title: value.name,
              description: value.publicDescription,
              characteristics:
                  '${value.species == AnimalSpecies.dog ? 'Cachorro' : 'Gato'} • ${value.approximateAge}',
              statusLabel: animalStatusLabel(value.status),
              canAdopt:
                  value.isPublished && value.status == AnimalStatus.available,
            ),
          );
          if (value.primaryPhotoId != null) {
            final photo = await photos.readPrimary(
              value.id,
              value.primaryPhotoId!,
            );
            if (!_disposed &&
                generation == _generation &&
                photo is Success<PhotoContent>) {
              _publish(state.copyWith(photo: photo.value.bytes));
            }
          }
      }
    } catch (_) {
      if (!_disposed && generation == _generation) {
        _publish(
          state.copyWith(message: 'Não foi possível carregar este animal.'),
        );
      }
    } finally {
      if (!_disposed && generation == _generation) {
        _publish(state.copyWith(busy: false));
      }
    }
  }

  Future<void> copyInterest() async {
    if (_disposed || !state.canAdopt || state.copying || _animal == null) {
      return;
    }
    final generation = _generation;
    _publish(state.copyWith(copying: true, message: null));
    try {
      final current = await animals.getPublic(_animal!.id);
      if (_disposed || generation != _generation) return;
      if (current case Failure<PublicAnimal>(:final failure)) {
        _publish(
          state.copyWith(message: failureMessage(failure), canAdopt: false),
        );
        return;
      }
      final value = (current as Success<PublicAnimal>).value;
      if (!value.isPublished || value.status != AnimalStatus.available) {
        _publish(
          state.copyWith(
            canAdopt: false,
            message: 'Este animal não está disponível para adoção.',
          ),
        );
        return;
      }
      final result = await adoption.copyInterestMessage(value);
      if (_disposed || generation != _generation) return;
      _publish(
        state.copyWith(
          message: result is Success<Unit>
              ? 'Mensagem copiada. Nenhum pedido foi enviado.'
              : failureMessage((result as Failure<Unit>).failure),
        ),
      );
    } catch (_) {
      if (!_disposed) {
        _publish(
          state.copyWith(message: 'Não foi possível copiar a mensagem.'),
        );
      }
    } finally {
      if (!_disposed && generation == _generation) {
        _publish(state.copyWith(copying: false));
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    _animal = null;
    super.dispose();
  }
}
