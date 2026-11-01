import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/data/services/url_launcher_link_service.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';

void main() {
  test(
    'accepts HTTPS opening and translates rejection and exceptions',
    () async {
      final uri = Uri.parse('https://wa.me/5534991378936');
      final opened = <Uri>[];
      final service = UrlLauncherLinkService(
        launch: (value) async {
          opened.add(value);
          return true;
        },
      );
      expect(await service.open(uri), isA<Success<Unit>>());
      expect(opened.single, uri);
      expect(
        await UrlLauncherLinkService(launch: (_) async => false).open(uri),
        isA<Failure<Unit>>(),
      );
      expect(
        await UrlLauncherLinkService(
          launch: (_) async => throw StateError('private platform error'),
        ).open(uri),
        isA<Failure<Unit>>(),
      );
      expect(
        await service.open(Uri.parse('javascript:alert(1)')),
        isA<Failure<Unit>>(),
      );
      expect(opened.length, 1);
    },
  );
}
