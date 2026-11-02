import 'package:abrigo_dos_anjos/data/services/team_service.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import 'package:abrigo_dos_anjos/utils/app_failure.dart';

class TeamFakeService implements TeamService {
  Object? response = {'items': [], 'next_cursor': null};
  Map<String, Object?> parameters = {};
  String? method;
  bool fail = false;
  @override
  Future<Result<Map<String, Object?>?>> request(
    String name,
    Map<String, Object?> values,
  ) async {
    method = name;
    parameters = values;
    if (fail) return Failure(AppFailure(FailureCode.forbidden));
    return Success(response as Map<String, Object?>?);
  }

  @override
  Future<Result<Map<String, Object?>>> send(Map<String, Object?> values) async {
    parameters = values;
    return Success(response as Map<String, Object?>);
  }

  @override
  Future<Result<Map<String, Object?>>> reconcile(String key) =>
      send({'operation_key': key});
  @override
  Future<Result<Unit>> definePassword(String password) async =>
      const Success(Unit.value);
}

Map<String, Object?> memberJson() => {
  'user_id': 'person',
  'display_name': 'Pessoa',
  'email': 'p@example.test',
  'role': 'employee',
  'active': true,
  'version': 3,
};
Map<String, Object?> invitationJson() => {
  'id': 'invite',
  'name': 'Pessoa',
  'email': 'p@example.test',
  'role': 'employee',
  'status': 'pending',
  'version': 2,
  'generation': 1,
  'expires_at': '2026-11-03T12:00:00Z',
  'delivery_state': 'sent',
  'retry_after': 0,
};
