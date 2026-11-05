import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/data/services/url_launcher_link_service.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'default platform launcher requests external application for official contact',
    () async {
      const channel = MethodChannel('plugins.flutter.io/url_launcher');
      final calls = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            calls.add(call);
            return true;
          });
      addTearDown(
        () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, null),
      );
      expect(
        await UrlLauncherLinkService().open(
          Uri.parse('https://wa.me/5534991378936'),
        ),
        isA<Success<Unit>>(),
      );
      expect(calls.single.method, 'launch');
      expect((calls.single.arguments as Map)['useWebView'], isFalse);
    },
  );

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
