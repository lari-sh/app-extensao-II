import 'dart:convert';
import '../utils/app_failure.dart';
import '../utils/result.dart';

final class AppConfig {
  const AppConfig({required this.url, required this.publishableKey});
  final Uri url;
  final String publishableKey;
  static Result<AppConfig> parse({
    required String url,
    required String key,
    bool allowLocalHttp = false,
  }) {
    final failure = Failure<AppConfig>(AppFailure(FailureCode.configuration));
    final uri = Uri.tryParse(url.trim());
    if (uri == null ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        uri.hasQuery ||
        uri.hasFragment ||
        (uri.path.isNotEmpty && uri.path != '/')) {
      return failure;
    }
    final localDebug =
        allowLocalHttp &&
        !const bool.fromEnvironment('dart.vm.product') &&
        ['127.0.0.1', 'localhost', '10.0.2.2'].contains(uri.host);
    if (uri.scheme != 'https' && !(uri.scheme == 'http' && localDebug)) {
      return failure;
    }
    final candidate = key.trim();
    var publicKey =
        candidate.startsWith('sb_publishable_') &&
        candidate.length > 'sb_publishable_'.length;
    if (!publicKey) {
      try {
        final parts = candidate.split('.');
        if (parts.length != 3) return failure;
        final claims = jsonDecode(
          utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
        );
        publicKey = claims is Map && claims['role'] == 'anon';
      } catch (_) {
        return failure;
      }
    }
    if (!publicKey) return failure;
    return Success(AppConfig(url: uri, publishableKey: candidate));
  }

  static Result<AppConfig> fromEnvironment() => parse(
    url: const String.fromEnvironment('SUPABASE_URL'),
    key: const String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY'),
    allowLocalHttp: const bool.fromEnvironment('ALLOW_LOCAL_HTTP'),
  );
}
