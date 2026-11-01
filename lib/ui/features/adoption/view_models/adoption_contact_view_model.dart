import 'package:flutter/foundation.dart';
import '../../../../domain/models/adoption_contact_state.dart';
import '../../../../domain/models/animal.dart';
import '../../../../domain/repositories/adoption_contact_repository.dart';
import '../../../../domain/repositories/animals_repository.dart';
import '../../../../utils/result.dart';

class AdoptionContactViewModel extends ChangeNotifier {
  AdoptionContactViewModel(this._animals, this._contacts);
  final AnimalsRepository _animals;
  final AdoptionContactRepository _contacts;
  AdoptionContactState _state = const AdoptionContactState();
  AdoptionContactState get state => _state;
  String? _id;
  int _generation = 0;
  bool _disposed = false;
  void _publish(AdoptionContactState value) {
    if (!_disposed) {
      _state = value;
      notifyListeners();
    }
  }

  bool _available(PublicAnimal animal) =>
      animal.isPublished && animal.status == AnimalStatus.available;
  Future<void> load(String id) async {
    if (_disposed || state.opening) return;
    _id = id;
    final generation = ++_generation;
    _publish(
      state.copyWith(
        loading: true,
        canContact: false,
        animalName: '',
        message: null,
      ),
    );
    try {
      final result = await _animals.getPublic(id);
      if (_disposed || generation != _generation) return;
      if (result case Success<PublicAnimal>(:final value)) {
        _publish(
          state.copyWith(
            loading: false,
            animalName: value.name,
            canContact: _available(value),
            message: _available(value)
                ? null
                : 'Este animal não está disponível para adoção.',
          ),
        );
      } else {
        _publish(
          state.copyWith(
            loading: false,
            message:
                'Não foi possível carregar os dados do animal. Tente novamente.',
          ),
        );
      }
    } catch (_) {
      if (generation == _generation)
        _publish(
          state.copyWith(
            loading: false,
            message:
                'Não foi possível carregar os dados do animal. Tente novamente.',
          ),
        );
    }
  }

  Future<void> retry() async {
    if (_id != null) await load(_id!);
  }

  Future<void> open(AdoptionChannel channel) async {
    if (_disposed ||
        !state.canContact ||
        state.opening ||
        state.loading ||
        _id == null)
      return;
    final generation = _generation;
    _publish(state.copyWith(opening: true, message: null));
    try {
      final current = await _animals.getPublic(_id!);
      if (_disposed || generation != _generation) return;
      if (current case Success<PublicAnimal>(:final value)) {
        if (!_available(value)) {
          _publish(
            state.copyWith(
              canContact: false,
              message: 'Este animal não está disponível para adoção.',
            ),
          );
          return;
        }
        _publish(state.copyWith(animalName: value.name));
        final opened = await _contacts.open(channel, value);
        if (_disposed || generation != _generation) return;
        if (opened is Failure<Unit>)
          _publish(
            state.copyWith(
              message: 'Não foi possível abrir o contato. Tente novamente.',
            ),
          );
      } else {
        _publish(
          state.copyWith(
            message:
                'Não foi possível confirmar os dados do animal. Tente novamente.',
          ),
        );
      }
    } catch (_) {
      if (generation == _generation)
        _publish(
          state.copyWith(
            message: 'Não foi possível abrir o contato. Tente novamente.',
          ),
        );
    } finally {
      if (!_disposed && generation == _generation)
        _publish(state.copyWith(opening: false));
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    super.dispose();
  }
}
