import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/auth_callback.dart';

/// Captures only a redacted intent; SDK verifies and consumes the credentials.
final class SupabaseAuthCallbackService implements AuthCallbackSource {
  static final instance = SupabaseAuthCallbackService();
  final _events = StreamController<AuthCallbackKind>.broadcast();
  AuthCallbackKind? _pending, _last;
  StreamSubscription<AuthState>? _subscription;
  Timer? _fallback;
  SupabaseClient? _client;
  bool capture(Uri uri) {
    if (uri.scheme != 'br.org.abrigodosanjos.app' ||
        uri.host != 'auth' ||
        uri.userInfo.isNotEmpty ||
        uri.hasPort) {
      return false;
    }
    final kind = switch (uri.path) {
      '/invite' => AuthCallbackKind.invitation,
      _ => null,
    };
    if (kind == null) return false;
    _pending = kind;
    _fallback?.cancel();
    // Invalid links can fail before emitting an Auth event. They still open a
    // server-checked unavailable state, never the management area.
    _fallback = Timer(const Duration(seconds: 3), _complete);
    return true;
  }

  void start(SupabaseClient client) {
    if (identical(_client, client)) return;
    _client = client;
    _subscription?.cancel();
    _subscription = client.auth.onAuthStateChange.listen(
      (state) {
        if (_pending != null &&
            const [
              AuthChangeEvent.signedIn,
              AuthChangeEvent.passwordRecovery,
              AuthChangeEvent.tokenRefreshed,
            ].contains(state.event)) {
          _complete();
        }
      },
      onError: (Object _, StackTrace _) {
        _complete();
      },
    );
  }

  void _complete() {
    final value = _pending;
    if (value == null) return;
    _pending = null;
    _last = value;
    _fallback?.cancel();
    _events.add(value);
  }

  @override
  Stream<AuthCallbackKind> watch() => Stream.multi((sink) {
    final initial = _last;
    if (initial != null) {
      _last = null;
      sink.add(initial);
    }
    final subscription = _events.stream.listen(
      (value) {
        _last = null;
        sink.add(value);
      },
      onError: sink.addError,
      onDone: sink.close,
    );
    sink.onCancel = subscription.cancel;
  });

  Future<void> dispose() async {
    _fallback?.cancel();
    await _subscription?.cancel();
    await _events.close();
  }
}
