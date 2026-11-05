import 'dart:convert';
import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:abrigo_dos_anjos/data/services/supabase_animals_service.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import 'package:abrigo_dos_anjos/utils/app_failure.dart';
import 'supabase_animals_service_test.dart' show animalJson;

Map<String, dynamic> managedJson() => {
  'animal': animalJson(1),
  'clinical_notes': 'Privado',
  'care_records': <Object>[],
};
void main() {
  test(
    'private read, list, save and reconcile use narrow RPCs and preserve operation key',
    () async {
      final requests = <http.Request>[];
      final client = SupabaseClient(
        'https://example.test',
        'public',
        httpClient: MockClient((request) async {
          requests.add(request);
          final data = request.url.path.endsWith('list_managed_animals')
              ? {
                  'items': [managedJson()],
                  'total': 1,
                  'cursor': null,
                }
              : managedJson();
          return http.Response(
            jsonEncode(data),
            200,
            request: request,
            headers: {'content-type': 'application/json'},
          );
        }),
      );
      addTearDown(client.dispose);
      final service = SupabaseAnimalsService(client);
      expect(await service.getManagement('id'), isA<Success>());
      expect(await service.listManagement(status: 'available'), isA<Success>());
      expect(
        await service.saveAnimal({'name': 'Luna'}, 'a' * 32),
        isA<Success>(),
      );
      final save = requests.last;
      expect(save.url.path, endsWith('/rpc/save_animal'));
      expect(jsonDecode(save.body)['p_operation_key'], 'a' * 32);
      expect(await service.getOperation('a' * 32), isA<Success>());
      expect(requests.every((r) => r.url.path.contains('/rpc/')), isTrue);
    },
  );
  for (final pair in [
    ('42501', FailureCode.forbidden),
    ('PT409', FailureCode.conflict),
    ('22023', FailureCode.validation),
    ('PT404', FailureCode.notFound),
  ]) {
    test('write error ${pair.$1} is sanitized', () async {
      final client = SupabaseClient(
        'https://example.test',
        'public',
        httpClient: MockClient(
          (request) async => http.Response(
            jsonEncode({'code': pair.$1, 'message': 'sensitive sql detail'}),
            400,
            request: request,
          ),
        ),
      );
      addTearDown(client.dispose);
      final result = await SupabaseAnimalsService(
        client,
      ).saveAnimal({}, 'a' * 32);
      expect((result as Failure).failure.code, pair.$2);
    });
  }
  test('transport timeout is retryable and never escapes', () async {
    final client = SupabaseClient(
      'https://example.test',
      'public',
      httpClient: MockClient((_) async => throw TimeoutException('private')),
    );
    addTearDown(client.dispose);
    expect(
      (await SupabaseAnimalsService(client).getManagement('id') as Failure)
          .failure
          .code,
      FailureCode.timeout,
    );
  });
}
