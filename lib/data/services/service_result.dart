import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' show ClientException;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../utils/app_failure.dart';
import '../../utils/result.dart';

final class ServiceFailure implements Exception {
  const ServiceFailure(this.code);
  final FailureCode code;
}

Future<Result<T>> serviceResult<T>(Future<T> Function() action) async {
  try {
    return Success(await action().timeout(const Duration(seconds: 20)));
  } on ServiceFailure catch (error) {
    return Failure(AppFailure(error.code));
  } on TimeoutException {
    return Failure(AppFailure(FailureCode.timeout, retryable: true));
  } on SocketException {
    return Failure(AppFailure(FailureCode.network, retryable: true));
  } on ClientException {
    return Failure(AppFailure(FailureCode.network, retryable: true));
  } on PostgrestException catch (error) {
    final code = switch (error.code) {
      '42501' || '403' => FailureCode.forbidden,
      'PGRST116' || 'PT404' || '404' => FailureCode.notFound,
      'PT409' || '23505' => FailureCode.conflict,
      '22023' || '23514' || '22P02' => FailureCode.validation,
      '401' => FailureCode.unauthenticated,
      _ => FailureCode.unknown,
    };
    return Failure(AppFailure(code));
  } on AuthException {
    return Failure(AppFailure(FailureCode.unauthenticated));
  } on FunctionException catch (error) {
    final code = switch (error.status) {
      0 => FailureCode.network,
      401 => FailureCode.unauthenticated,
      403 => FailureCode.forbidden,
      404 => FailureCode.notFound,
      _ => FailureCode.unknown,
    };
    return Failure(
      AppFailure(code, retryable: error.status == 0 || error.status >= 500),
    );
  } on StorageException catch (error) {
    return Failure(
      AppFailure(
        error.statusCode == '403' ? FailureCode.forbidden : FailureCode.unknown,
      ),
    );
  } on FormatException {
    return Failure(AppFailure(FailureCode.validation));
  } catch (_) {
    return Failure(AppFailure(FailureCode.unknown));
  }
}
