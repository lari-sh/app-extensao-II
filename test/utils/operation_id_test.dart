import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/utils/operation_id.dart';

void main() {
  test('submission retains 24 random bytes until confirmed completion', () {
    final operation = OperationId();
    final original = operation.value;
    expect(base64Url.decode(original).length, 24);
    expect(original, matches(RegExp(r'^[A-Za-z0-9_-]{32}$')));
    expect(operation.value, original);
    operation.complete();
    expect(operation.value, isNot(original));
    expect(List.generate(100, (_) => OperationId().value).toSet().length, 100);
  });
}
