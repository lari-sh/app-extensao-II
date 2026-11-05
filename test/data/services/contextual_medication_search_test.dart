import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:abrigo_dos_anjos/data/services/supabase_medications_service.dart';
import 'package:abrigo_dos_anjos/data/repositories/medications_repository_impl.dart';
import 'package:abrigo_dos_anjos/domain/models/managed_animal_search_filter.dart';
import 'package:abrigo_dos_anjos/domain/models/animal.dart';
import 'package:abrigo_dos_anjos/domain/models/medication_agenda.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'repository and SDK send all filters with selected day/cursor through additive RPC',
    () async {
      final calls = <http.Request>[];
      final client = SupabaseClient(
        'https://example.test',
        'public',
        httpClient: MockClient((r) async {
          calls.add(r);
          return http.Response(
            jsonEncode({
              'day': '2026-11-03',
              'server_now': '2026-11-03T12:00:00Z',
              'agenda_version': 1,
              'items': [],
              'next_cursor': null,
            }),
            200,
            request: r,
            headers: {'content-type': 'application/json'},
          );
        }),
      );
      addTearDown(client.dispose);
      final repo = MedicationsRepositoryImpl(
        SupabaseMedicationsService(client),
      );
      final result = await repo.loadDay(
        '2026-11-03',
        filter: const ManagedAnimalSearchFilter(
          query: ' #a0067 ',
          species: AnimalSpecies.dog,
          sex: AnimalSex.female,
          size: AnimalSize.small,
          status: AnimalStatus.quarantine,
          color: ' preto ',
        ),
      );
      expect(result, isA<Success<MedicationDayPage>>());
      expect(calls.single.url.path, endsWith('/search_medication_day'));
      expect(jsonDecode(calls.single.body), {
        'p_day': '2026-11-03',
        'p_cursor': null,
        'p_filter': {
          'query': '#a0067',
          'species': 'dog',
          'sex': 'female',
          'size': 'small',
          'status': 'quarantine',
          'color': 'preto',
        },
      });
      await repo.loadDay('2026-11-03');
      expect(calls.last.url.path, endsWith('/list_medication_day'));
      expect(
        (jsonDecode(calls.last.body) as Map).containsKey('p_filter'),
        false,
      );
      final before = calls.length;
      expect(
        await repo.loadDay(
          '2026-11-03',
          filter: ManagedAnimalSearchFilter(query: 'x' * 81),
        ),
        isA<Failure>(),
      );
      expect(calls.length, before);
    },
  );
}
