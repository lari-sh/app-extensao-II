import '../../utils/result.dart';

abstract interface class ExternalLinkService {
  Future<Result<Unit>> open(Uri uri);
}
