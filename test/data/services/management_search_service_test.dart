import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:abrigo_dos_anjos/data/services/supabase_animals_service.dart';
import 'package:abrigo_dos_anjos/data/models/animal_dto.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import 'package:abrigo_dos_anjos/utils/app_failure.dart';
import '../../support/public_fixtures.dart';

Map<String, Object?> row(int value, {Object? code = 'A0001'}) => {
  'animal': {...fixtureDto(value).values, 'animal_code': code},
  'clinical_notes': 'Interno',
  'care_records': <Object>[],
};
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'SDK serializes query and all five filters, cursor and immutable identifiers',
    () async {
      final requests = <http.Request>[];
      final client = SupabaseClient(
        'https://example.test',
        'public',
        httpClient: MockClient((r) async {
          requests.add(r);
          return http.Response(
            jsonEncode({
              'items': [row(1)],
              'total': 30,
              'cursor': ['Luna 1', fixtureId(1)],
            }),
            200,
            request: r,
            headers: {'content-type': 'application/json'},
          );
        }),
      );
      addTearDown(client.dispose);
      final service = SupabaseAnimalsService(client);
      final result = await service.searchManagement(
        filters: {
          'query': ' #a0001 ',
          'species': 'dog',
          'sex': 'female',
          'color': ' preto ',
          'size': 'small',
          'status': 'quarantine',
        },
      );
      expect(result, isA<Success<ManagedAnimalsPageDto>>());
      final page = (result as Success<ManagedAnimalsPageDto>).value;
      expect(page.total, 30);
      expect(page.items.single.animal.values['animal_code'], 'A0001');
      expect(page.cursor, isNotNull);
      final params = jsonDecode(requests.single.body) as Map;
      expect(requests.single.url.path, endsWith('/rpc/search_managed_animals'));
      expect(params, {
        'p_query': '#a0001',
        'p_species': 'dog',
        'p_sex': 'female',
        'p_color': 'preto',
        'p_size': 'small',
        'p_status': 'quarantine',
        'p_cursor': null,
      });
      await service.searchManagement(filters: {}, cursor: page.cursor);
      expect((jsonDecode(requests.last.body) as Map)['p_cursor'], [
        'Luna 1',
        fixtureId(1),
      ]);
    },
  );
  test('invalid criteria and cursor fail before network', () async {
    var calls = 0;
    final client = SupabaseClient(
      'https://example.test',
      'public',
      httpClient: MockClient((r) async {
        calls++;
        return http.Response('{}', 200);
      }),
    );
    addTearDown(client.dispose);
    final service = SupabaseAnimalsService(client);
    for (final filters in [
      {'mode': 'calendar'},
      {'query': 'x' * 81},
      {'color': 'x' * 81},
      {'species': 'bird'},
      {'sex': 'x'},
      {'size': 'x'},
      {'status': 'x'},
    ]) {
      expect(
        (await service.searchManagement(filters: filters) as Failure)
            .failure
            .code,
        FailureCode.validation,
      );
    }
    for (final cursor in [
      'x' * 2049,
      'not-base64',
      base64Url.encode(utf8.encode('{}')),
      base64Url.encode(utf8.encode('[1,"x"]')),
    ]) {
      expect(
        await service.searchManagement(filters: {}, cursor: cursor),
        isA<Failure>(),
      );
    }
    expect(calls, 0);
  });
  test(
    'malformed pages and missing or forged identities are sanitized',
    () async {
      for (final body in [
        [],
        {'items': [], 'total': -1},
        {
          'items': [row(1, code: null)],
          'total': 1,
        },
        {
          'items': [row(1, code: 'A0000')],
          'total': 1,
        },
        {
          'items': [row(1), row(1)],
          'total': 2,
        },
        {'items': List.generate(26, (i) => row(i + 1)), 'total': 26},
        {'items': [], 'total': 0, 'cursor': {}},
        {
          'items': [42],
          'total': 1,
        },
      ]) {
        final client = SupabaseClient(
          'https://example.test',
          'public',
          httpClient: MockClient(
            (r) async => http.Response(
              jsonEncode(body),
              200,
              request: r,
              headers: {'content-type': 'application/json'},
            ),
          ),
        );
        addTearDown(client.dispose);
        expect(
          await SupabaseAnimalsService(client).searchManagement(filters: {}),
          isA<Failure>(),
        );
      }
    },
  );
  test('empty result and server authorization failure stay typed', () async {
    var deny = false;
    final client = SupabaseClient(
      'https://example.test',
      'public',
      httpClient: MockClient(
        (r) async => http.Response(
          jsonEncode(
            deny
                ? {'code': '42501', 'message': 'private provider detail'}
                : {'items': [], 'total': 0, 'cursor': null},
          ),
          deny ? 403 : 200,
          request: r,
          headers: {'content-type': 'application/json'},
        ),
      ),
    );
    addTearDown(client.dispose);
    final service = SupabaseAnimalsService(client);
    expect(
      (await service.searchManagement(filters: {'query': 'missing'})
              as Success<ManagedAnimalsPageDto>)
          .value
          .items,
      isEmpty,
    );
    deny = true;
    expect(
      (await service.searchManagement(filters: {}) as Failure).failure.code,
      FailureCode.forbidden,
    );
  });
  test('legacy DTO may omit code; present code must be canonical', () {
    final json = {...fixtureDto(1).values};
    expect(AnimalDto.fromJson(json).values['animal_code'], isNull);
    expect(
      AnimalDto.fromJson({
        ...json,
        'animal_code': 'A10000',
      }).values['animal_code'],
      'A10000',
    );
    for (final code in ['bad', 'a0001', 'A0001 ', 7]) {
      expect(
        () => AnimalDto.fromJson({...json, 'animal_code': code}),
        throwsFormatException,
      );
    }
  });
}
