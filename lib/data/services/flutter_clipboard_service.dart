import '../../utils/result.dart';
import 'clipboard_service.dart';
import 'service_result.dart';
import 'package:flutter/services.dart';

class FlutterClipboardService implements ClipboardService {
  FlutterClipboardService({Future<void> Function(ClipboardData)? write})
    : write = write ?? Clipboard.setData;
  final Future<void> Function(ClipboardData) write;
  @override
  Future<Result<Unit>> copy(String message) => serviceResult(() async {
    await write(ClipboardData(text: message));
    return Unit.value;
  });
}
