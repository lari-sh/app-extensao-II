import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:abrigo_dos_anjos/data/services/supabase_team_service.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';

void main() {
  test('SDK exceptions become safe Result with Portuguese message', () async {
    final client = SupabaseClient(
      'https://example.test',
      'public',
      httpClient: MockClient(
        (r) async => http.Response(
          jsonEncode({
            'code': 'PT409',
            'message': 'existing_account',
            'details': 'sensitive',
          }),
          409,
          request: r,
          headers: {'content-type': 'application/json'},
        ),
      ),
    );
    addTearDown(client.dispose);
    final result = await SupabaseTeamService(
      client,
    ).rpc('list_team_members', {});
    expect(result, isA<Failure<Map<String, Object?>?>>());
    final failure = (result as Failure<Map<String, Object?>?>).failure;
    expect(failure.fieldErrors['team'], contains('já possui'));
    expect(failure.fieldErrors.toString(), isNot(contains('sensitive')));
  });
  test('non-object response is rejected without raw exception', () async {
    final client = SupabaseClient(
      'https://example.test',
      'public',
      httpClient: MockClient(
        (r) async => http.Response(
          '[]',
          200,
          request: r,
          headers: {'content-type': 'application/json'},
        ),
      ),
    );
    addTearDown(client.dispose);
    expect(
      await SupabaseTeamService(client).rpc('list_team_members', {}),
      isA<Failure<Map<String, Object?>?>>(),
    );
  });
}
