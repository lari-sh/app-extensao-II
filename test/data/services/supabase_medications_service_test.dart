import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:abrigo_dos_anjos/data/services/supabase_medications_service.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import 'package:abrigo_dos_anjos/utils/app_failure.dart';
import '../../support/medication_fixtures.dart';

void main() {
  test(
    'medication RPC failures preserve typed authorization, conflict, validation and transport errors',
    () async {
      var scenario = 'timeout';
      final client = SupabaseClient(
        'https://example.test',
        'public',
        httpClient: MockClient((request) async {
          if (scenario == 'timeout') throw TimeoutException('private');
          if (scenario == 'network') throw const SocketException('private');
          if (scenario == 'auth') throw const AuthException('private');
          return http.Response(
            jsonEncode({'code': scenario, 'message': 'private'}),
            scenario == 'PT409' ? 409 : 400,
            request: request,
            headers: {'content-type': 'application/json'},
          );
        }),
      );
      addTearDown(client.dispose);
      final service = SupabaseMedicationsService(client);
      for (final entry in {
        'timeout': FailureCode.timeout,
        'network': FailureCode.network,
        'auth': FailureCode.unauthenticated,
        'PT409': FailureCode.conflict,
        '22023': FailureCode.validation,
      }.entries) {
        scenario = entry.key;
        expect(
          (await service.completeApplication(
                    medicationApplicationId,
                    1,
                    'k' * 32,
                  )
                  as Failure)
              .failure
              .code,
          entry.value,
        );
      }
    },
  );
  test(
    'SDK service sends narrow command without actor or actual timestamp and sanitizes failures',
    () async {
      final calls = <http.Request>[];
      var status = 200;
      final client = SupabaseClient(
        'https://example.test',
        'public',
        httpClient: MockClient((request) async {
          calls.add(request);
          return http.Response(
            jsonEncode(
              status == 200
                  ? medicationCommandJson()
                  : {'code': '42501', 'message': 'private sql'},
            ),
            status,
            headers: {'content-type': 'application/json'},
            request: request,
          );
        }),
      );
      addTearDown(client.dispose);
      final service = SupabaseMedicationsService(client);
      expect(
        await service.completeApplication(medicationApplicationId, 1, 'k' * 32),
        isA<Success>(),
      );
      expect(
        calls.single.url.path,
        endsWith('/rpc/complete_medication_application'),
      );
      expect(jsonDecode(calls.single.body), {
        'p_application_id': medicationApplicationId,
        'p_expected_version': 1,
        'p_operation_key': 'k' * 32,
      });
      status = 403;
      final failure =
          await service.completeApplication(
                medicationApplicationId,
                1,
                'k' * 32,
              )
              as Failure;
      expect(failure.failure.code, FailureCode.forbidden);
    },
  );
  test(
    'malformed response becomes validation and missing receipt stays null',
    () async {
      Object? response = {'result': 'bad'};
      final client = SupabaseClient(
        'https://example.test',
        'public',
        httpClient: MockClient(
          (request) async => http.Response(
            jsonEncode(response),
            200,
            headers: {'content-type': 'application/json'},
            request: request,
          ),
        ),
      );
      addTearDown(client.dispose);
      final service = SupabaseMedicationsService(client);
      expect(
        (await service.loadMonth('2026-11') as Failure).failure.code,
        FailureCode.validation,
      );
      response = null;
      expect((await service.getOperation('k' * 32) as Success).value, isNull);
    },
  );
}
