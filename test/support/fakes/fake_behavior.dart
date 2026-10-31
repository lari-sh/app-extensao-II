import 'package:abrigo_dos_anjos/utils/app_failure.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';

/// Test-only behavior: handlers may return controlled Completers or failures.
class FakeBehavior {
  Future<Object?> Function(String method, List<Object?> arguments)? handler;
  final calls = <({String method, List<Object?> arguments})>[];
  Future<Result<T>> invoke<T>(String method, List<Object?> arguments) async {
    calls.add((method: method, arguments: arguments));
    if (handler == null) return Failure(AppFailure(FailureCode.configuration));
    return await handler!(method, arguments) as Result<T>;
  }
}
