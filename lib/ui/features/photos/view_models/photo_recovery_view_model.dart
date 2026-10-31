import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../domain/models/photo_candidate.dart';
import '../../../../domain/repositories/photo_repository.dart';
import '../../../../utils/result.dart';
import '../../../../utils/app_failure.dart';
part 'photo_recovery_view_model.freezed.dart';

@freezed
abstract class PhotoRecoveryState with _$PhotoRecoveryState {
  const factory PhotoRecoveryState({
    PhotoCandidate? candidate,
    @Default(false) bool busy,
    String? message,
  }) = _PhotoRecoveryState;
}

class PhotoRecoveryViewModel extends ChangeNotifier {
  PhotoRecoveryViewModel(
    this.repository, {
    required this.isAuthorized,
    required this.userId,
    this.authorize,
    this.retainPrivate,
    this.onDispose,
  });
  final PhotoRepository repository;
  final bool Function() isAuthorized;
  final String? Function() userId;
  final Future<bool> Function()? authorize;
  final bool Function()? retainPrivate;
  final VoidCallback? onDispose;
  PhotoRecoveryState _state = const PhotoRecoveryState();
  PhotoRecoveryState get state => _state;
  bool _disposed = false;
  String? _owner;
  int _revision = 0;
  bool get canOffer =>
      !_disposed &&
      isAuthorized() &&
      _owner != null &&
      userId() == _owner &&
      state.candidate != null;
  void _publish(PhotoRecoveryState value) {
    if (!_disposed) {
      _state = value;
      notifyListeners();
    }
  }

  void accessChanged() {
    if (_disposed) return;
    if (_owner != null &&
        ((isAuthorized() && userId() != _owner) ||
            (!isAuthorized() && !(retainPrivate?.call() ?? false)))) {
      ++_revision;
      _owner = null;
      _publish(const PhotoRecoveryState());
    } else {
      notifyListeners();
    }
  }

  Future<void> recover() async {
    if (_disposed || state.busy) return;
    final revision = ++_revision;
    _publish(state.copyWith(busy: true));
    try {
      final result = await repository.recoverLostSelection();
      if (_disposed || revision != _revision) return;
      if (!isAuthorized() || userId() == null) {
        _owner = null;
        _publish(const PhotoRecoveryState());
        return;
      }
      if (result case Success<PhotoCandidate?>(:final value)) {
        _owner = userId();
        _publish(
          PhotoRecoveryState(
            candidate: value,
            message: value == null
                ? null
                : 'Há uma foto recuperada. Confirme o animal antes de enviar.',
          ),
        );
      } else {
        _publish(
          const PhotoRecoveryState(
            message: 'Não foi possível recuperar a foto. Selecione novamente.',
          ),
        );
      }
    } catch (_) {
      _publish(
        const PhotoRecoveryState(message: 'Não foi possível recuperar a foto.'),
      );
    } finally {
      if (!_disposed && revision == _revision) {
        _publish(state.copyWith(busy: false));
      }
    }
  }

  Future<Result<PhotoCandidate?>> confirmForAnimal(String animalId) async {
    if (!RegExp(r'^[0-9a-fA-F-]{36}$').hasMatch(animalId) || !canOffer) {
      return Failure(AppFailure(FailureCode.validation));
    }
    final owner = _owner;
    final revision = _revision;
    if (authorize != null && !await authorize!()) {
      return Failure(AppFailure(FailureCode.forbidden));
    }
    if (_disposed ||
        revision != _revision ||
        !isAuthorized() ||
        userId() != owner) {
      _owner = null;
      _publish(const PhotoRecoveryState());
      return Failure(AppFailure(FailureCode.forbidden));
    }
    final candidate = state.candidate;
    _owner = null;
    _publish(const PhotoRecoveryState());
    return Success(candidate);
  }

  @override
  void dispose() {
    _disposed = true;
    ++_revision;
    _owner = null;
    _state = const PhotoRecoveryState();
    onDispose?.call();
    super.dispose();
  }
}
