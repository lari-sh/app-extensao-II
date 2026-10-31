import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../domain/repositories/auth_repository.dart';
import '../../../../domain/models/session_access.dart';
import '../../../../utils/result.dart';
import '../../../../utils/app_failure.dart';
part 'session_view_model.freezed.dart';

enum SessionPhase {
  checking,
  visitor,
  authenticatedWithoutStaff,
  authorized,
  unavailable,
}

@freezed
abstract class SessionState with _$SessionState {
  const factory SessionState({
    @Default(SessionPhase.checking) SessionPhase phase,
    String? userId,
    @Default(false) bool canAccessPrivate,
    @Default(true) bool hidePrivate,
    @Default(false) bool retainPrivate,
    @Default(false) bool requiresReauthentication,
    @Default(false) bool signingOut,
    @Default(0) int privateGeneration,
    @Default(0) int accessEpoch,
    String? message,
  }) = _SessionState;
}

class SessionViewModel extends ChangeNotifier {
  SessionViewModel(this.repository);
  final AuthRepository repository;
  SessionState _state = const SessionState();
  SessionState get state => _state;
  StreamSubscription<Result<SessionAccess>>? _subscription;
  bool _disposed = false, _started = false, _signIn = false, _signedOut = false;
  int _revision = 0;
  String? _privateUser;
  void _publish(SessionState value) {
    if (!_disposed) {
      _state = value;
      notifyListeners();
    }
  }

  void _discard(
    SessionPhase phase, {
    String? userId,
    String? message,
    bool signingOut = false,
  }) {
    final hadPrivate = _privateUser != null || state.retainPrivate;
    _privateUser = null;
    _publish(
      SessionState(
        phase: phase,
        userId: userId,
        message: message,
        signingOut: signingOut,
        privateGeneration: state.privateGeneration + (hadPrivate ? 1 : 0),
        accessEpoch: state.accessEpoch + 1,
      ),
    );
  }

  void _consume(Result<SessionAccess> result) {
    if (_disposed) return;
    if (result case Failure<SessionAccess>(:final failure)) {
      if (failure.code == FailureCode.cancelled) return;
      _discard(
        SessionPhase.unavailable,
        message: 'Não foi possível verificar seu acesso. Entre novamente.',
      );
      return;
    }
    final access = (result as Success<SessionAccess>).value;
    if (access.interruption == AccessInterruption.recoverableExpiration &&
        access.userId != null &&
        access.userId == _privateUser) {
      _publish(
        state.copyWith(
          phase: SessionPhase.visitor,
          canAccessPrivate: false,
          hidePrivate: true,
          retainPrivate: true,
          requiresReauthentication: true,
          accessEpoch: state.accessEpoch + 1,
          message: 'Sua sessão expirou. Entre novamente.',
        ),
      );
      return;
    }
    if (access.isAuthorized) {
      final changed = _privateUser != null && _privateUser != access.userId;
      _privateUser = access.userId;
      _publish(
        SessionState(
          phase: SessionPhase.authorized,
          userId: access.userId,
          canAccessPrivate: true,
          hidePrivate: false,
          retainPrivate: true,
          privateGeneration: state.privateGeneration + (changed ? 1 : 0),
          accessEpoch: state.accessEpoch + (changed ? 1 : 0),
        ),
      );
      return;
    }
    _discard(
      access.level == AccessLevel.authenticatedWithoutStaff
          ? SessionPhase.authenticatedWithoutStaff
          : SessionPhase.visitor,
      userId: access.userId,
      message: access.level == AccessLevel.authenticatedWithoutStaff
          ? 'Sua conta não possui autorização de voluntário.'
          : null,
    );
  }

  Future<void> start() async {
    if (_started || _disposed) return;
    _started = true;
    try {
      _subscription = repository.watchAccess().listen(
        (event) {
          if (_disposed || _signIn || _signedOut || state.signingOut) return;
          ++_revision;
          _consume(event);
        },
        onError: (Object error, StackTrace stack) {
          if (!_disposed && !_signIn && !_signedOut) {
            ++_revision;
            _consume(Failure(AppFailure(FailureCode.unknown)));
          }
        },
      );
    } catch (_) {
      _discard(
        SessionPhase.unavailable,
        message: 'Não foi possível verificar seu acesso.',
      );
      return;
    }
    await revalidate(restore: true);
  }

  Future<void> revalidate({bool restore = false}) async {
    if (_disposed || _signIn || _signedOut || state.signingOut) return;
    final revision = ++_revision;
    _publish(
      state.copyWith(
        phase: SessionPhase.checking,
        canAccessPrivate: false,
        hidePrivate: true,
        retainPrivate: _privateUser != null,
        accessEpoch: state.accessEpoch + 1,
      ),
    );
    try {
      final result = await (restore
          ? repository.restoreAccess()
          : repository.currentAccess());
      if (!_disposed && revision == _revision) _consume(result);
    } catch (_) {
      if (!_disposed && revision == _revision)
        _consume(Failure(AppFailure(FailureCode.unknown)));
    }
  }

  int? beginSignIn() {
    if (_disposed || _signIn || state.signingOut) return null;
    _signIn = true;
    _signedOut = false;
    final ticket = ++_revision;
    _publish(
      state.copyWith(
        canAccessPrivate: false,
        hidePrivate: true,
        accessEpoch: state.accessEpoch + 1,
      ),
    );
    return ticket;
  }

  bool isAttemptCurrent(int ticket) =>
      !_disposed && _signIn && ticket == _revision;
  bool completeSignIn(int ticket, SessionAccess access) {
    if (!isAttemptCurrent(ticket)) return false;
    _signIn = false;
    _signedOut = false;
    _consume(Success(access));
    return true;
  }

  void failSignIn(int ticket) {
    if (!isAttemptCurrent(ticket)) return;
    _signIn = false;
    _signedOut = true;
    if (!state.requiresReauthentication) _discard(SessionPhase.visitor);
  }

  void cancelSignIn(int ticket) {
    if (!isAttemptCurrent(ticket)) return;
    _signIn = false;
    _signedOut = true;
    ++_revision;
    _discard(SessionPhase.visitor);
    unawaited(repository.signOut().then((_) {}).catchError((Object _) {}));
  }

  void cancelReauthentication() {
    if (_disposed) return;
    _signIn = false;
    _signedOut = true;
    ++_revision;
    _discard(SessionPhase.visitor);
    unawaited(repository.signOut().then((_) {}).catchError((Object _) {}));
  }

  Future<void> signOut() async {
    if (_disposed || state.signingOut) return;
    _signIn = false;
    _signedOut = true;
    final revision = ++_revision;
    _discard(SessionPhase.visitor, signingOut: true);
    try {
      final result = await repository.signOut();
      if (_disposed || revision != _revision) return;
      _publish(
        state.copyWith(
          signingOut: false,
          message: result is Success<Unit>
              ? 'Você saiu da sua conta.'
              : 'Você saiu neste dispositivo. Não foi possível confirmar a saída no servidor. Entre novamente para tentar encerrar as sessões.',
        ),
      );
    } catch (_) {
      if (!_disposed && revision == _revision)
        _publish(
          state.copyWith(
            signingOut: false,
            message:
                'Você saiu neste dispositivo. Não foi possível confirmar a saída no servidor.',
          ),
        );
    }
  }

  bool canUsePrivate(int epoch) =>
      !_disposed && state.canAccessPrivate && epoch == state.accessEpoch;
  @override
  void dispose() {
    _disposed = true;
    ++_revision;
    unawaited(_subscription?.cancel() ?? Future<void>.value());
    super.dispose();
  }
}
