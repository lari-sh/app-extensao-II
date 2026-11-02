import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../../domain/models/auth_callback.dart';

class AuthCallbackViewModel extends ChangeNotifier {
  AuthCallbackViewModel(AuthCallbackSource source) {
    _subscription = source.watch().listen((kind) {
      route = kind == AuthCallbackKind.invitation
          ? '/accept-invitation'
          : '/reset-password';
      notifyListeners();
    });
  }
  late final StreamSubscription<AuthCallbackKind> _subscription;
  String? route;
  String? takeRoute() {
    final value = route;
    route = null;
    return value;
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
