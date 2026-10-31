import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:abrigo_dos_anjos/data/services/supabase_photo_api_service.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import 'package:abrigo_dos_anjos/utils/app_failure.dart';

void main() {
  test(
    'SDK sends three multipart fields and GET reconciliation preserves operation key',
    () async {
      final requests = <http.Request>[];
      final client = SupabaseClient(
        'https://example.test',
        'public',
        httpClient: MockClient((request) async {
          requests.add(request);
          return http.Response(
            jsonEncode({
              'job_id': 'job',
              'state': 'attached',
              'photo_id': 'original',
              'current_photo_id': 'current',
            }),
            200,
            request: request,
            headers: {'content-type': 'application/json'},
          );
        }),
      );
      addTearDown(client.dispose);
      final service = SupabasePhotoApiService(client);
      final upload = await service.uploadPrimary(
        'animal',
        [255, 216, 255],
        'image/jpeg',
        'a' * 32,
      );
      expect(upload, isA<Success>());
      expect((upload as Success).value.currentPhotoId, 'current');
      expect(
        requests.single.headers['content-type'],
        startsWith('multipart/form-data;'),
      );
      expect(
        utf8.decode(requests.single.bodyBytes, allowMalformed: true),
        contains('name="animal_id"'),
      );
      expect(
        utf8.decode(requests.single.bodyBytes, allowMalformed: true),
        contains('name="operation_key"'),
      );
      expect(
        utf8.decode(requests.single.bodyBytes, allowMalformed: true),
        contains('name="file"'),
      );
      expect(await service.getUpload('a' * 32), isA<Success>());
      expect(requests.last.method, 'GET');
      expect(requests.last.url.queryParameters['operation_key'], 'a' * 32);
    },
  );
  for (final pair in [
    (403, FailureCode.forbidden),
    (413, FailureCode.validation),
    (415, FailureCode.validation),
    (422, FailureCode.validation),
    (409, FailureCode.conflict),
    (503, FailureCode.unknown),
  ]) {
    test('upload HTTP ${pair.$1} becomes sanitized failure', () async {
      final client = SupabaseClient(
        'https://example.test',
        'public',
        httpClient: MockClient(
          (request) async => http.Response(
            '{"private":"details"}',
            pair.$1,
            request: request,
            headers: {'content-type': 'application/json'},
          ),
        ),
      );
      addTearDown(client.dispose);
      expect(
        (await SupabasePhotoApiService(
                  client,
                ).uploadPrimary('animal', [1], 'image/jpeg', 'a' * 32)
                as Failure)
            .failure
            .code,
        pair.$2,
      );
    });
  }
}
