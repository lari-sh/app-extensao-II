import 'dart:async';
import 'app_failure.dart';

sealed class Result<T> {
  const Result();
  static Future<Result<T>> guard<T>(Future<T> Function() action) async {
    try {
      return Success(await action());
    } on TimeoutException {
      return Failure(AppFailure(FailureCode.timeout, retryable: true));
    } catch (_) {
      return Failure(AppFailure(FailureCode.unknown));
    }
  }

  static Stream<Result<T>> guardStream<T>(Stream<T> source) => source.transform(
    StreamTransformer<T, Result<T>>.fromHandlers(
      handleData: (value, sink) => sink.add(Success(value)),
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
}

final class Success<T> extends Result<T> {
  const Success(this.value);
  final T value;
}

final class Failure<T> extends Result<T> {
  const Failure(this.failure);
  final AppFailure failure;
}

final class Unit {
  const Unit();
  static const value = Unit();
}
