import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:abrigo_dos_anjos/data/services/supabase_animals_service.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import 'package:abrigo_dos_anjos/utils/app_failure.dart';
import '../../support/public_fixtures.dart';

void main() {
  test(
    'management uses narrow RPCs, global counts and stable operation key',
    () async {
      final requests = <http.Request>[];
      final client = SupabaseClient(
        'https://example.test',
        'public',
        httpClient: MockClient((r) async {
          requests.add(r);
          return http.Response(
            jsonEncode(
              r.url.path.endsWith('get_animal_status_counts')
                  ? {
                      'available': 75,
                      'treatment': 2,
                      'quarantine': 0,
                      'adopted': 1,
                    }
                  : fixtureDto(1).values,
            ),
            200,
            request: r,
            headers: {'content-type': 'application/json'},
          );
        }),
      );
      addTearDown(client.dispose);
      final service = SupabaseAnimalsService(client);
      expect(
        (await service.getStatusCounts() as Success<Map<String, int>>)
            .value['available'],
        75,
      );
      expect(
        await service.setStatus(fixtureId(1), 'treatment', 'a' * 32),
        isA<Success>(),
      );
      expect(requests.last.url.path, endsWith('/rpc/set_animal_status'));
      expect(jsonDecode(requests.last.body), {
        'p_animal_id': fixtureId(1),
        'p_status': 'treatment',
        'p_operation_key': 'a' * 32,
      });
      expect(
        await service.setPublication(fixtureId(1), true, 'b' * 32),
        isA<Success>(),
      );
      expect(requests.last.url.path, endsWith('/rpc/set_animal_publication'));
      expect(jsonDecode(requests.last.body)['p_is_published'], true);
    },
  );
  for (final code in ['42501', '401', 'PT409']) {
    test('every management operation sanitizes $code', () async {
      final client = SupabaseClient(
        'https://example.test',
        'public',
        httpClient: MockClient(
          (r) async => http.Response(
            jsonEncode({'code': code, 'message': 'private sql'}),
            400,
            request: r,
          ),
        ),
      );
      addTearDown(client.dispose);
      final service = SupabaseAnimalsService(client);
      final expected = code == '42501'
          ? FailureCode.forbidden
          : code == '401'
          ? FailureCode.unauthenticated
          : FailureCode.conflict;
      for (final result in [
        await service.getStatusCounts(),
        await service.setStatus(fixtureId(1), 'adopted', 'a' * 32),
        await service.setPublication(fixtureId(1), true, 'b' * 32),
      ]) {
        expect((result as Failure).failure.code, expected);
      }
    });
  }
}
