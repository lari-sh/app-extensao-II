import 'dart:async';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/models/session_access.dart';
import '../../utils/app_failure.dart';
import '../../utils/result.dart';
import '../models/session_dto.dart';
import '../services/auth_service.dart';
import 'repository_result.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this.service);
  final AuthService service;
  Future<void> _writes = Future.value();
  int _epoch = 0, _pendingWrites = 0;
  bool _locallySignedOut = false;
  AppFailure? _remoteLogoutFailure;
  SessionAccess _map(SessionDto dto) => SessionAccess(
    userId: dto.userId,
    level: dto.userId == null
        ? AccessLevel.visitor
        : dto.isStaffActive && !dto.recoverableExpiration
        ? AccessLevel.authorized
        : AccessLevel.authenticatedWithoutStaff,
    interruption: dto.recoverableExpiration && dto.userId != null
        ? AccessInterruption.recoverableExpiration
        : AccessInterruption.definitiveLoss,
  );
  Future<Result<T>> _enqueue<T>(Future<Result<T>> Function() action) {
    final completer = Completer<Result<T>>();
    _pendingWrites++;
    _writes = _writes.then((_) async {
      try {
        completer.complete(await action());
      } catch (_) {
        completer.complete(Failure(AppFailure(FailureCode.unknown)));
      } finally {
        _pendingWrites--;
      }
    });
    return completer.future;
  }

  @override
  Future<Result<SessionAccess>> signIn(String email, String password) {
    final epoch = ++_epoch;
    _locallySignedOut = false;
    return _enqueue(() async {
      if (epoch != _epoch) return Failure(AppFailure(FailureCode.cancelled));
      final result = await mapRepositoryResult(
        () => service.signIn(email, password),
        _map,
      );
      if (epoch != _epoch) return Failure(AppFailure(FailureCode.cancelled));
      if (result is Success<SessionAccess>) {
        _remoteLogoutFailure = null;
      } else {
        _locallySignedOut = true;
      }
      return result;
    });
  }

  @override
  Future<Result<SessionAccess>> currentAccess() async {
    if (_locallySignedOut) return const Success(SessionAccess());
    if (_pendingWrites > 0) return Failure(AppFailure(FailureCode.cancelled));
    final epoch = _epoch;
    final result = await mapRepositoryResult(service.currentAccess, _map);
    return epoch == _epoch
        ? result
        : Failure(AppFailure(FailureCode.cancelled));
  }

  @override
  Future<Result<SessionAccess>> restoreAccess() => currentAccess();
  @override
  Stream<Result<SessionAccess>>
  watchAccess() => service.watchAccess().transform(
    StreamTransformer<Result<SessionDto>, Result<SessionAccess>>.fromHandlers(
      handleData: (result, sink) {
        if (_locallySignedOut || _pendingWrites > 0) {
          sink.add(const Success(SessionAccess()));
          return;
        }
        try {
          sink.add(switch (result) {
            Success<SessionDto>(:final value) => Success(_map(value)),
            Failure<SessionDto>(:final failure) => Failure(failure),
          });
        } catch (_) {
          sink.add(Failure(AppFailure(FailureCode.unknown)));
        }
      },
      handleError: (Object error, StackTrace stack, sink) => sink.add(
        Failure(
          AppFailure(
            error is TimeoutException
                ? FailureCode.timeout
                : FailureCode.unknown,
          ),
        ),
      ),
    ),
  );
  @override
  Future<Result<Unit>> signOut() {
    ++_epoch;
    _locallySignedOut = true;
    if (_remoteLogoutFailure != null) {
      return Future.value(Failure(_remoteLogoutFailure!));
    }
    return _enqueue(() async {
      final result = await mapRepositoryResult(service.signOut, (unit) => unit);
      if (result case Failure<Unit>(:final failure)) {
        _remoteLogoutFailure = failure;
      }
      return result;
    });
  }
}
