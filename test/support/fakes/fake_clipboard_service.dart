import 'fake_behavior.dart';
import 'package:abrigo_dos_anjos/data/services/clipboard_service.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';

class FakeClipboardService extends FakeBehavior implements ClipboardService {
  @override
  Future<Result<Unit>> copy(String message) => invoke<Unit>('copy', [message]);
}
