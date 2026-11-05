import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:abrigo_dos_anjos/data/services/supabase_animals_service.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import 'package:abrigo_dos_anjos/utils/app_failure.dart';

Map<String, dynamic> animalJson(int i) => {
  'id': '00000000-0000-4000-8000-${i.toString().padLeft(12, '0')}',
  'name': 'Animal $i',
  'species': 'dog',
  'sex': 'female',
  'size': 'medium',
  'approximate_age': '2 anos',
  'public_description': 'Publico',
  'status': 'available',
  'is_published': true,
  'is_vaccinated': false,
  'is_neutered': false,
};
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'public detail and favorite batches enforce visibility and deterministic order',
    () async {
      final requests = <http.Request>[];
      final client = SupabaseClient(
        'https://example.test',
        'public',
        httpClient: MockClient((request) async {
          requests.add(request);
          return http.Response(
            jsonEncode(
              request.url.queryParameters.containsKey('id') &&
                      request.url.queryParameters['id']!.startsWith('eq.')
                  ? animalJson(1)
                  : [animalJson(1), animalJson(2)],
            ),
            200,
            request: request,
            headers: {'content-type': 'application/json'},
          );
        }),
      );
      addTearDown(client.dispose);
      final service = SupabaseAnimalsService(client);
      final empty = await service.getVisibleByIds({});
      expect((empty as Success).value, isEmpty);
      expect(requests, isEmpty);
      expect(
        await service.getPublic(animalJson(1)['id'] as String),
        isA<Success>(),
      );
      final batch = await service.getVisibleByIds({
        animalJson(2)['id'] as String,
        animalJson(1)['id'] as String,
      });
      expect((batch as Success).value.length, 2);
      final query = requests.last.url.queryParameters;
      expect(query['id'], startsWith('in.'));
      expect(query['is_published'], 'eq.true');
      expect(query['status'], 'neq.adopted');
      expect(query['order'], contains('name.asc'));
    },
  );

  test(
    'SDK receives combined public filters, ordered cursor and 50 item pages',
    () async {
      final requests = <http.Request>[];
      final client = SupabaseClient(
        'https://example.test',
        'public',
        httpClient: MockClient((request) async {
          requests.add(request);
          return http.Response(
            jsonEncode(List.generate(50, (i) => animalJson(i + 1))),
            200,
            request: request,
            headers: {
              'content-type': 'application/json',
              'content-range': '0-49/55',
            },
          );
        }),
      );
      addTearDown(client.dispose);
      final service = SupabaseAnimalsService(client);
      final result = await service.listPublic(
        filters: {
          'name': 'Luna%',
          'species': 'dog',
          'sex': 'female',
          'size': 'medium',
        },
      );
      expect(result, isA<Success>());
      final page = (result as Success).value;
      expect(page.items.length, 50);
      expect(page.total, 55);
      expect(page.cursor, isNotNull);
      final query = requests.last.url.queryParameters;
      expect(query['is_published'], 'eq.true');
      expect(query['status'], 'neq.adopted');
      expect(query['species'], 'eq.dog');
      expect(query['sex'], 'eq.female');
      expect(query['size'], 'eq.medium');
      expect(
        query['order'],
        matches(
          r'^name\.asc(?:\.nulls(?:first|last))?,id\.asc(?:\.nulls(?:first|last))?$',
        ),
      );
      expect(query['limit'], '50');
      expect(query['name'], contains(r'\%'));
      await service.listPublic(filters: {}, cursor: page.cursor);
      expect(requests.last.url.queryParameters['or'], contains('id.gt.'));
    },
  );
  test(
    'hidden detail is notFound and malformed cursor never sends a request',
    () async {
      var calls = 0;
      final client = SupabaseClient(
        'https://example.test',
        'public',
        httpClient: MockClient((request) async {
          calls++;
          return http.Response(
            '[]',
            200,
            request: request,
            headers: {'content-type': 'application/json'},
          );
        }),
      );
      addTearDown(client.dispose);
      final service = SupabaseAnimalsService(client);
      final detail = await service.getPublic(
        '00000000-0000-4000-8000-000000000001',
      );
      expect((detail as Failure).failure.code, FailureCode.notFound);
      final before = calls;
      final bad = await service.listPublic(filters: {}, cursor: 'not-a-cursor');
      expect((bad as Failure).failure.code, FailureCode.validation);
      expect(calls, before);
    },
  );
  test(
    'SDK authorization and transport errors become sanitized failures',
    () async {
      for (final code in [403, 0]) {
        final client = SupabaseClient(
          'https://example.test',
          'public',
          httpClient: MockClient((request) async {
            if (code == 0) throw http.ClientException('secret host');
            return http.Response(
              '{"code":"42501","message":"internal SQL"}',
              403,
              request: request,
              headers: {'content-type': 'application/json'},
            );
          }),
        );
        final result = await SupabaseAnimalsService(
          client,
        ).getPublic('00000000-0000-4000-8000-000000000001');
        expect(
          (result as Failure).failure.code,
          code == 0 ? FailureCode.network : FailureCode.forbidden,
        );
        await client.dispose();
      }
    },
  );
}
