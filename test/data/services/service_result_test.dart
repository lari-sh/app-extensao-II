import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:abrigo_dos_anjos/data/services/service_result.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import 'package:abrigo_dos_anjos/utils/app_failure.dart';

void main() {
  final cases = <Object, FailureCode>{
    TimeoutException('internal'): FailureCode.timeout,
    const SocketException('internal host'): FailureCode.network,
    ClientException('internal host'): FailureCode.network,
    const PostgrestException(message: 'SQL internal', code: '42501'):
        FailureCode.forbidden,
    const AuthException('raw auth'): FailureCode.unauthenticated,
    const StorageException('raw storage', statusCode: '403'):
        FailureCode.forbidden,
    const FunctionException(status: 401): FailureCode.unauthenticated,
    const FunctionException(status: 403): FailureCode.forbidden,
    const FunctionException(status: 404): FailureCode.notFound,
    const FunctionException(status: 0): FailureCode.network,
    const FormatException('raw DTO'): FailureCode.validation,
    PlatformException(code: 'raw plugin'): FailureCode.unknown,
    StateError('raw secret'): FailureCode.unknown,
  };
  for (final entry in cases.entries) {
    test(
      'service sanitizes ${entry.key.runtimeType} to ${entry.value.name}',
      () async {
        final result = await serviceResult<int>(() async => throw entry.key);
        expect((result as Failure<int>).failure.code, entry.value);
        expect(result.toString(), isNot(contains('raw secret')));
      },
    );
  }
}
