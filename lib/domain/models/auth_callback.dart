enum AuthCallbackKind { invitation, recovery }

/// No URI, credential, or token may cross the Service boundary.
abstract interface class AuthCallbackSource {
  Stream<AuthCallbackKind> watch();
}
