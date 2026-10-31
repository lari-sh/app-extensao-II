import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../domain/models/animal.dart';
import '../../../../domain/repositories/animals_repository.dart';
import '../../../../utils/result.dart';
part 'managed_animals_view_model.freezed.dart';

@freezed
abstract class ManagedAnimalsState with _$ManagedAnimalsState {
  const factory ManagedAnimalsState({
    @Default([]) List<ManagedAnimal> items,
    @Default(0) int total,
    String? cursor,
    @Default(false) bool loading,
    String? message,
  }) = _ManagedAnimalsState;
}

class ManagedAnimalsViewModel extends ChangeNotifier {
  ManagedAnimalsViewModel(
    this.repository, {
    required this.isAuthorized,
    this.authorize,
    this.accessEpoch,
  });
  final AnimalsRepository repository;
  final bool Function() isAuthorized;
  final Future<bool> Function()? authorize;
  final int Function()? accessEpoch;
  ManagedAnimalsState _state = const ManagedAnimalsState();
  ManagedAnimalsState get state => _state;
  bool _disposed = false;
  void _publish(ManagedAnimalsState state) {
    if (!_disposed) {
      _state = state;
      notifyListeners();
    }
  }

  Future<void> load({bool more = false}) async {
    if (_disposed ||
        state.loading ||
        !isAuthorized() ||
        (more && state.cursor == null)) {
      return;
    }
    _publish(state.copyWith(loading: true, message: null));
    try {
      if (authorize != null && !await authorize!()) return;
      if (_disposed || !isAuthorized()) return;
      final epoch = accessEpoch?.call();
      final result = await repository.listManagement(
        cursor: more ? state.cursor : null,
      );
      if (_disposed || !isAuthorized() || epoch != accessEpoch?.call()) return;
      switch (result) {
        case Success<ManagedAnimalPage>(:final value):
          final items = {
            for (final item in [
              ...(more ? state.items : <ManagedAnimal>[]),
              ...value.items,
            ])
              item.animal.id: item,
          };
          _publish(
            state.copyWith(
              items: items.values.toList(),
              total: value.total,
              cursor: value.cursor,
            ),
          );
        case Failure<ManagedAnimalPage>():
          _publish(
            state.copyWith(
              message: 'Não foi possível carregar os animais. Tente novamente.',
            ),
          );
          await authorize?.call();
      }
    } catch (_) {
      _publish(
        state.copyWith(message: 'Não foi possível carregar os animais.'),
      );
    } finally {
      _publish(state.copyWith(loading: false));
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _state = const ManagedAnimalsState();
    super.dispose();
  }
}
