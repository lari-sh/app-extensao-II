enum FailureCode {
  validation,
  unauthenticated,
  forbidden,
  notFound,
  network,
  timeout,
  conflict,
  cancelled,
  permissionDenied,
  configuration,
  unknown,
}

final class AppFailure {
  AppFailure(
    this.code, {
    Map<String, String> fieldErrors = const {},
    this.retryable = false,
    this.correlationId,
  }) : fieldErrors = Map.unmodifiable(fieldErrors);
  final FailureCode code;
  final Map<String, String> fieldErrors;
  final bool retryable;
  final String? correlationId;
}
