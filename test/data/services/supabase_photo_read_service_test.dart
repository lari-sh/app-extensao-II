import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:abrigo_dos_anjos/data/services/supabase_photo_api_service.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import 'package:abrigo_dos_anjos/utils/app_failure.dart';

void main() {
  test(
    'function SDK preserves binary PNG and rejects non-image data',
    () async {
      for (final valid in [true, false]) {
        final client = SupabaseClient(
          'https://example.test',
          'public',
          httpClient: MockClient(
            (request) async => http.Response.bytes(
              valid ? [137, 80, 78, 71, 13, 10, 26, 10] : [1, 2],
              200,
              request: request,
              headers: {'content-type': 'application/octet-stream'},
            ),
          ),
        );
        final result = await SupabasePhotoApiService(
          client,
        ).readPrimary('animal', 'photo');
        if (valid) {
          expect(result, isA<Success>());
          expect((result as Success).value.mime, 'image/png');
        } else {
          expect(result, isA<Failure>());
        }
        await client.dispose();
      }
    },
  );
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'function SDK requests bytes and maps missing or denied photo',
    () async {
      final client = SupabaseClient(
        'https://example.test',
        'public',
        httpClient: MockClient((request) async {
          expect(request.url.path, endsWith('/animal-photo-read'));
          expect(
            request.headers['Accept'] ?? request.headers['accept'],
            'application/octet-stream',
          );
          expect(request.url.queryParameters['animal_id'], 'animal');
          return http.Response(
            '{"code":"notFound"}',
            404,
            headers: {'content-type': 'application/json'},
          );
        }),
      );
      addTearDown(client.dispose);
      expect(
        (await SupabasePhotoApiService(client).readPrimary('animal', 'photo')
                as Failure)
            .failure
            .code,
        FailureCode.notFound,
      );
    },
  );
}
