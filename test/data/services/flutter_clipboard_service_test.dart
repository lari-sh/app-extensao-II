import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:abrigo_dos_anjos/data/services/flutter_clipboard_service.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';

void main() {
  test('clipboard copies exactly once and reports platform failure', () async {
    var copied = '';
    final service = FlutterClipboardService(
      write: (data) async {
        copied = data.text!;
      },
    );
    expect(await service.copy('Interesse em Luna'), isA<Success>());
    expect(copied, 'Interesse em Luna');
    final failed = FlutterClipboardService(
      write: (_) async => throw PlatformException(code: 'denied'),
    );
    expect(await failed.copy('text'), isA<Failure>());
  });
}
