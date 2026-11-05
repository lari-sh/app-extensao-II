import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../domain/models/photo_candidate.dart';
import '../../../../domain/models/photo_content.dart';
import '../../../../domain/models/photo_upload_state.dart';
import '../../../../domain/repositories/photo_repository.dart';
import '../../../../utils/operation_id.dart';
import '../../../../utils/result.dart';
import '../../../../utils/app_failure.dart';
part 'photo_upload_view_model.freezed.dart';

@freezed
abstract class PhotoPanelState with _$PhotoPanelState {
  const factory PhotoPanelState({
    String? animalId,
    String? photoId,
    PhotoContent? image,
    PhotoCandidate? candidate,
    @Default(false) bool busy,
    @Default(false) bool uncertain,
    @Default(false) bool canRetry,
    @Default(false) bool hasRecovery,
    String? message,
  }) = _PhotoPanelState;
}

class PhotoUploadViewModel extends ChangeNotifier {
  PhotoUploadViewModel(
    this.repository, {
    bool Function()? isAuthorized,
    int Function()? accessEpoch,
    int Function()? privateGeneration,
    Future<bool> Function()? authorize,
    Future<void> Function(Duration)? delay,
    this.recoverCandidate,
    this.recoveryAvailable,
    this.onDispose,
  }) : _isAuthorized = isAuthorized ?? _yes,
       _epoch = accessEpoch ?? _zero,
       _privateGeneration = privateGeneration ?? _zero,
       _authorize = authorize,
       _delay = delay ?? Future<void>.delayed;
  final PhotoRepository repository;
  final bool Function() _isAuthorized;
  final int Function() _epoch, _privateGeneration;
  final Future<bool> Function()? _authorize;
  final Future<void> Function(Duration) _delay;
  final Future<Result<PhotoCandidate?>> Function(String)? recoverCandidate;
  final bool Function()? recoveryAvailable;
  final VoidCallback? onDispose;
  static bool _yes() => true;
  static int _zero() => 0;
  PhotoPanelState _state = const PhotoPanelState();
  PhotoPanelState get state => _state;
  final _operation = OperationId();
  int _revision = 0;
  bool _disposed = false;
  bool get canSelect =>
      !_disposed &&
      _isAuthorized() &&
      state.animalId != null &&
      !state.busy &&
      !state.uncertain;
  String get guidance => state.animalId == null
      ? 'Salve o animal antes de adicionar uma foto.'
      : 'Selecione um JPEG ou PNG de até 5 MB e confirme o envio.';
  bool get canRecover => canSelect && state.hasRecovery;
  bool get canUpload => canSelect && state.candidate != null;
  void _publish(PhotoPanelState value) {
    if (!_disposed) {
      _state = value;
      notifyListeners();
    }
  }

  void refreshRecovery() =>
      _publish(state.copyWith(hasRecovery: recoveryAvailable?.call() ?? false));
  Future<bool> _check() async =>
      !_disposed &&
      (_authorize == null ? _isAuthorized() : await _authorize()) &&
      !_disposed &&
      _isAuthorized();
  bool _current(int revision, int epoch) =>
      !_disposed &&
      revision == _revision &&
      epoch == _epoch() &&
      _isAuthorized();
  Future<void> bindAnimal(String? animalId, String? photoId) async {
    if (_disposed) return;
    if (state.animalId == animalId &&
        (state.photoId == photoId || state.busy || state.uncertain)) {
      return;
    }
    final changed = state.animalId != animalId;
    ++_revision;
    if (changed) _operation.complete();
    _publish(
      state.copyWith(
        animalId: animalId,
        photoId: photoId,
        image: null,
        candidate: changed ? null : state.candidate,
        busy: changed ? false : state.busy,
        canRetry: changed ? false : state.canRetry,
        uncertain: changed ? false : state.uncertain,
        message: null,
        hasRecovery: recoveryAvailable?.call() ?? false,
      ),
    );
    if (animalId != null && photoId != null) await _readImage(verify: true);
  }

  Future<void> _readImage({bool verify = false}) async {
    if (state.animalId == null || state.photoId == null) return;
    final revision = _revision;
    if (verify && !await _check()) return;
    final epoch = _epoch();
    final result = await repository.readPrimary(
      state.animalId!,
      state.photoId!,
    );
    if (!_current(revision, epoch)) return;
    if (result case Success<PhotoContent>(:final value)) {
      _publish(state.copyWith(image: value));
    } else {
      _publish(
        state.copyWith(
          image: null,
          message:
              'Não foi possível carregar a foto. Atualize a tela para tentar novamente.',
        ),
      );
    }
  }

  Future<void> pick() async {
    if (!canSelect) return;
    final revision = ++_revision;
    final generation = _privateGeneration();
    _publish(state.copyWith(busy: true, message: null));
    try {
      if (!await _check()) return;
      final result = await repository.pickFromGallery();
      // Returning from Android's picker changes the access epoch on resume. Verify
      // again, rather than dropping a valid choice solely because of that resume.
      if (_disposed ||
          revision != _revision ||
          generation != _privateGeneration() ||
          !await _check()) {
        return;
      }
      switch (result) {
        case Success<PhotoCandidate?>(:final value):
          if (value != null) {
            _operation.complete();
            _publish(state.copyWith(candidate: value));
          }
        case Failure<PhotoCandidate?>(:final failure):
          _publish(state.copyWith(message: _message(failure)));
      }
    } catch (_) {
      _publish(
        state.copyWith(
          message: 'Não foi possível selecionar a foto. Tente novamente.',
        ),
      );
    } finally {
      if (!_disposed && revision == _revision) {
        _publish(state.copyWith(busy: false));
      }
    }
  }

  String _message(AppFailure failure) => switch (failure.code) {
    FailureCode.permissionDenied =>
      'A permissão para acessar as fotos foi negada. Autorize o acesso nas configurações e tente novamente.',
    FailureCode.validation => 'Escolha uma imagem JPEG ou PNG de até 5 MB.',
    FailureCode.forbidden || FailureCode.unauthenticated =>
      'Seu acesso precisa ser verificado. Entre novamente.',
    _ => 'Não foi possível enviar a foto. A foto anterior foi preservada.',
  };
  Future<void> useRecovered() async {
    if (!canSelect || recoverCandidate == null) return;
    final revision = ++_revision;
    _publish(state.copyWith(busy: true));
    try {
      final result = await recoverCandidate!(state.animalId!);
      if (_disposed || revision != _revision || !_isAuthorized()) return;
      switch (result) {
        case Success<PhotoCandidate?>(:final value):
          _operation.complete();
          _publish(
            state.copyWith(
              candidate: value,
              hasRecovery: false,
              message: 'Confira a foto e confirme o envio para este animal.',
            ),
          );
        case Failure<PhotoCandidate?>(:final failure):
          _publish(state.copyWith(message: _message(failure)));
      }
    } catch (_) {
      _publish(
        state.copyWith(
          message: 'Não foi possível recuperar a foto. Selecione novamente.',
        ),
      );
    } finally {
      if (!_disposed && revision == _revision) {
        _publish(state.copyWith(busy: false));
      }
    }
  }

  Future<void> _confirmed(PhotoUploadState job) async {
    final id = job.currentPhotoId ?? job.photoId;
    _operation.complete();
    _publish(
      state.copyWith(
        photoId: id,
        image: null,
        candidate: null,
        uncertain: false,
        canRetry: false,
        message: 'Foto enviada com sucesso.',
      ),
    );
    if (id != null) await _readImage();
  }

  Future<bool> _consume(PhotoUploadState job) async {
    if (job.status == PhotoJobStatus.attached) {
      await _confirmed(job);
      return true;
    }
    if ([
      PhotoJobStatus.failed,
      PhotoJobStatus.cleaned,
      PhotoJobStatus.cleanupNeeded,
    ].contains(job.status)) {
      _operation.complete();
      _publish(
        state.copyWith(
          uncertain: false,
          canRetry: false,
          message:
              'O envio não foi concluído. A foto anterior foi preservada. Tente novamente.',
        ),
      );
      return true;
    }
    return false;
  }

  Future<void> upload() async {
    if (!canUpload) return;
    final revision = ++_revision;
    _publish(state.copyWith(busy: true, message: null));
    try {
      if (!await _check()) return;
      final epoch = _epoch();
      final id = state.animalId!;
      final candidate = state.candidate!;
      _publish(state.copyWith(uncertain: true, canRetry: false));
      final result = await repository.uploadPrimary(
        id,
        candidate,
        _operation.value,
      );
      if (!_current(revision, epoch)) return;
      if (result case Success<PhotoUploadState>(:final value)) {
        if (await _consume(value)) return;
      } else if (result case Failure<PhotoUploadState>(:final failure)) {
        if ([
          FailureCode.validation,
          FailureCode.permissionDenied,
          FailureCode.forbidden,
          FailureCode.unauthenticated,
        ].contains(failure.code)) {
          _operation.complete();
          _publish(
            state.copyWith(uncertain: false, message: _message(failure)),
          );
          if ([
            FailureCode.forbidden,
            FailureCode.unauthenticated,
          ].contains(failure.code)) {
            ++_revision;
            _operation.complete();
            // Keep only the editor binding. Candidate/image/job bytes are erased;
            // the protected scope still disposes this VM on logout/revocation.
            _publish(
              PhotoPanelState(
                animalId: state.animalId,
                message: _message(failure),
              ),
            );
            await _authorize?.call();
          }
          return;
        }
      }
      await _reconcile(revision);
    } catch (_) {
      _publish(
        state.copyWith(
          uncertain: true,
          message: 'Não foi possível confirmar o envio. Verifique o resultado.',
        ),
      );
    } finally {
      if (!_disposed && revision == _revision) {
        _publish(state.copyWith(busy: false));
      }
    }
  }

  Future<void> _reconcile(int revision) async {
    var missing = false;
    for (final seconds in [1, 2, 4]) {
      await _delay(Duration(seconds: seconds));
      if (_disposed || revision != _revision || !await _check()) return;
      final epoch = _epoch();
      final result = await repository.getUpload(_operation.value);
      if (!_current(revision, epoch)) return;
      if (result case Success<PhotoUploadState>(:final value)) {
        missing = false;
        if (await _consume(value)) return;
      } else if (result case Failure<PhotoUploadState>(:final failure)) {
        missing = failure.code == FailureCode.notFound;
        if ([
          FailureCode.forbidden,
          FailureCode.unauthenticated,
        ].contains(failure.code)) {
          await _authorize?.call();
          break;
        }
      }
    }
    _publish(
      state.copyWith(
        uncertain: true,
        canRetry: missing,
        message:
            'O envio ainda não foi confirmado. Verifique novamente antes de escolher outra foto.',
      ),
    );
  }

  Future<void> reconcile() async {
    if (_disposed || state.busy || !state.uncertain || !_isAuthorized()) return;
    final revision = ++_revision;
    _publish(state.copyWith(busy: true));
    try {
      await _reconcile(revision);
    } catch (_) {
      _publish(
        state.copyWith(
          message: 'Não foi possível verificar o envio. Tente novamente.',
        ),
      );
    } finally {
      if (!_disposed && revision == _revision) {
        _publish(state.copyWith(busy: false));
      }
    }
  }

  Future<void> retry() async {
    if (_disposed || state.busy || !state.canRetry || !_isAuthorized()) return;
    _publish(state.copyWith(uncertain: false, canRetry: false));
    await upload();
  }

  @override
  void dispose() {
    _disposed = true;
    ++_revision;
    _state = const PhotoPanelState();
    _operation.complete();
    onDispose?.call();
    super.dispose();
  }
}
