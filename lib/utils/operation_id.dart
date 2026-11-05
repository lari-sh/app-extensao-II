import 'dart:convert';
import 'dart:math';

/// One key per logical submission. Timeouts do not complete an operation.
final class OperationId {
  String? _value;
  String get value => _value ??= base64Url
      .encode(List.generate(24, (_) => Random.secure().nextInt(256)))
      .replaceAll('=', '');
  void complete() => _value = null;
}
