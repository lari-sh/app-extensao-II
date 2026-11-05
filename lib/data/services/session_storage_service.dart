import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../utils/app_failure.dart';
import '../../utils/result.dart';

abstract interface class SessionPersistenceService {
  Future<Result<int>> prepareSignIn(bool remember);
  Future<Result<Unit>> confirmSignIn(int ticket, String session);
}

/// Only session storage is adapted. The SDK's separate PKCE store is untouched.
final class SessionStorageService extends LocalStorage
    implements SessionPersistenceService {
  SessionStorageService(
    this.delegate, {
    required this.readPreference,
    required this.writePreference,
  });
  factory SessionStorageService.forUrl(Uri url) {
    final preferences = SharedPreferencesAsync();
    return SessionStorageService(
      SharedPreferencesLocalStorage(
        persistSessionKey: 'sb-${url.host.split('.').first}-auth-token',
      ),
      readPreference: () => preferences.getBool('remember_session_v1'),
      writePreference: (value) =>
          preferences.setBool('remember_session_v1', value),
    );
  }
  final LocalStorage delegate;
  final Future<bool?> Function() readPreference;
  final Future<void> Function(bool) writePreference;
  Future<void>? _initializing;
  Future<void> _tail = Future.value();
  bool _remember = true, _acceptWrites = true;
  int _generation = 0;
  Future<T> _serialize<T>(Future<T> Function() action) {
    final result = Completer<T>();
    _tail = _tail.then((_) async {
      try {
        result.complete(await action());
      } catch (error, stack) {
        result.completeError(error, stack);
      }
    });
    return result.future;
  }

  @override
  Future<void> initialize() => _initializing ??= (() async {
    try {
      await delegate.initialize();
      _remember = await readPreference() ?? true;
      if (!_remember) await delegate.removePersistedSession();
    } catch (_) {
      _remember = false;
      _acceptWrites = false;
      throw StateError('Session storage unavailable');
    }
  })();
  Future<void> _close() async {
    _remember = false;
    _acceptWrites = false;
    ++_generation;
    try {
      await writePreference(false);
    } catch (_) {}
    try {
      await delegate.removePersistedSession();
    } catch (_) {}
  }

  @override
  Future<Result<int>> prepareSignIn(bool remember) {
    final ticket = ++_generation;
    _acceptWrites = false;
    return _serialize(() async {
      try {
        await initialize();
        if (ticket != _generation) {
          return Failure(AppFailure(FailureCode.cancelled));
        }
        // Erase a previous user's session even when the new choice is checked.
        await delegate.removePersistedSession();
        await writePreference(remember);
        _remember = remember;
        return Success(ticket);
      } catch (_) {
        await _close();
        return Failure(AppFailure(FailureCode.configuration));
      }
    });
  }

  @override
  Future<Result<Unit>> confirmSignIn(int ticket, String session) =>
      _serialize(() async {
        if (ticket != _generation) {
          return Failure(AppFailure(FailureCode.cancelled));
        }
        try {
          if (_remember) await delegate.persistSession(session);
          _acceptWrites = true;
          return const Success(Unit.value);
        } catch (_) {
          await _close();
          return Failure(AppFailure(FailureCode.configuration));
        }
      });
  @override
  Future<bool> hasAccessToken() => _serialize(() async {
    await initialize();
    return _remember && await delegate.hasAccessToken();
  });
  @override
  Future<String?> accessToken() => _serialize(() async {
    await initialize();
    return _remember ? await delegate.accessToken() : null;
  });
  @override
  Future<void> persistSession(String session) {
    if (!_acceptWrites) return Future.value();
    final generation = _generation;
    return _serialize(() async {
      await initialize();
      if (generation != _generation || !_remember || !_acceptWrites) return;
      try {
        await delegate.persistSession(session);
      } catch (_) {
        await _close();
        throw StateError('Session storage unavailable');
      }
    });
  }

  @override
  Future<void> removePersistedSession() {
    ++_generation;
    _acceptWrites = false;
    return _serialize(() async {
      await initialize();
      try {
        await delegate.removePersistedSession();
      } catch (_) {
        await _close();
        throw StateError('Session storage unavailable');
      }
    });
  }
}
