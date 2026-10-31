import '../../utils/result.dart';

abstract interface class ClipboardService {
  Future<Result<Unit>> copy(String message);
}
