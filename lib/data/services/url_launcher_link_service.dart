import 'package:url_launcher/url_launcher.dart';
import '../../utils/app_failure.dart';
import '../../utils/result.dart';
import 'external_link_service.dart';

class UrlLauncherLinkService implements ExternalLinkService {
  UrlLauncherLinkService({Future<bool> Function(Uri)? launch})
    : _launch = launch ?? _openExternal;
  final Future<bool> Function(Uri) _launch;
  static Future<bool> _openExternal(Uri uri) =>
      launchUrl(uri, mode: LaunchMode.externalApplication);

  @override
  Future<Result<Unit>> open(Uri uri) async {
    if (uri.scheme != 'https' || uri.host.isEmpty || uri.userInfo.isNotEmpty) {
      return Failure(AppFailure(FailureCode.validation));
    }
    try {
      return await _launch(uri)
          ? const Success(Unit.value)
          : Failure(AppFailure(FailureCode.unknown, retryable: true));
    } catch (_) {
      return Failure(AppFailure(FailureCode.unknown, retryable: true));
    }
  }
}
