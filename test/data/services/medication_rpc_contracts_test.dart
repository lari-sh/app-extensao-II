import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:abrigo_dos_anjos/data/services/supabase_medications_service.dart';
import 'package:abrigo_dos_anjos/data/models/medication_dto.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import '../../support/medication_fixtures.dart';

void main() {
  test(
    'treatment listing, save and history map the documented RPC contracts',
    () async {
      final requests = <http.Request>[];
      final client = SupabaseClient(
        'https://example.test',
        'public',
        httpClient: MockClient((r) async {
          requests.add(r);
          final body = r.url.path.endsWith('list_animal_medication_treatments')
              ? {
                  'items': [medicationTreatmentJson()],
                  'next_cursor': null,
                }
              : r.url.path.endsWith('get_medication_application_history')
              ? {
                  'application': medicationApplicationJson(),
                  'items': [],
                  'next_cursor': null,
                }
              : medicationCommandJson();
          return http.Response(
            jsonEncode(body),
            200,
            request: r,
            headers: {'content-type': 'application/json'},
          );
        }),
      );
      addTearDown(client.dispose);
      final service = SupabaseMedicationsService(client);
      expect(
        await service.listTreatments(medicationAnimalId, cursor: 'cursor'),
        isA<Success<MedicationDto>>(),
      );
      expect(jsonDecode(requests.last.body), {
        'p_animal_id': medicationAnimalId,
        'p_cursor': 'cursor',
      });
      expect(
        await service.saveTreatment({'name': 'Test'}, 'k' * 32),
        isA<Success<MedicationDto>>(),
      );
      expect(jsonDecode(requests.last.body), {
        'p_payload': {'name': 'Test'},
        'p_operation_key': 'k' * 32,
      });
      expect(
        await service.loadApplicationHistory(
          medicationApplicationId,
          cursor: 'history',
        ),
        isA<Success<MedicationDto>>(),
      );
      expect(jsonDecode(requests.last.body), {
        'p_application_id': medicationApplicationId,
        'p_cursor': 'history',
      });
      expect(
        await service.getOperation('k' * 32),
        isA<Success<MedicationDto?>>(),
      );
      expect(jsonDecode(requests.last.body), {'p_operation_key': 'k' * 32});
    },
  );
}
