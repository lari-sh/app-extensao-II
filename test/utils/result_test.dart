import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/utils/app_failure.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';

void main() {
  test('guard maps timeout to retryable friendly failure', () async {
    final result = await Result.guard<int>(
      () async => throw TimeoutException('private transport details'),
    );
    expect((result as Failure<int>).failure.code, FailureCode.timeout);
    expect(result.failure.retryable, isTrue);
  });

  test('guard returns typed value and sanitizes asynchronous errors', () async {
    expect((await Result.guard(() async => 7) as Success<int>).value, 7);
    final result = await Result.guard<int>(
      () async => throw StateError('secret-token'),
    );
    expect((result as Failure<int>).failure.code, FailureCode.unknown);
    expect(result.toString(), isNot(contains('secret-token')));
  });
  test(
    'stream converts errors and continues without exposing exception',
    () async {
      Stream<int> source() async* {
        yield 1;
        throw StateError('raw auth error');
      }

      final values = await Result.guardStream(source()).toList();
      expect((values.first as Success<int>).value, 1);
      expect((values.last as Failure<int>).failure.code, FailureCode.unknown);
    },
  );
  test('field error snapshot cannot be mutated through input or output', () {
    final fields = {'name': 'required'};
    final failure = AppFailure(FailureCode.validation, fieldErrors: fields);
    fields.clear();
    expect(failure.fieldErrors, {'name': 'required'});
    expect(() => failure.fieldErrors.clear(), throwsUnsupportedError);
  });
}
