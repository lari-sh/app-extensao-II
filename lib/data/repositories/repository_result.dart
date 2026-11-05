import '../../utils/app_failure.dart';
import '../../utils/result.dart';

Future<Result<R>> mapRepositoryResult<T, R>(
  Future<Result<T>> Function() action,
  R Function(T) map,
) async {
  try {
    return switch (await action()) {
      Success<T>(:final value) => Success(map(value)),
      Failure<T>(:final failure) => Failure(failure),
    };
  } catch (_) {
    return Failure(AppFailure(FailureCode.unknown));
  }
}

bool isAnimalId(String value) => RegExp(
  r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
).hasMatch(value);
