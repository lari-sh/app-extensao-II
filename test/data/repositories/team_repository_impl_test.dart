import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/data/services/team_service.dart';
import 'package:abrigo_dos_anjos/data/repositories/team_repository_impl.dart';
import 'package:abrigo_dos_anjos/domain/models/team_access.dart';
import 'package:abrigo_dos_anjos/domain/models/session_access.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import 'package:abrigo_dos_anjos/utils/app_failure.dart';

class TeamFakeService implements TeamService {
  Object? response = {'items': [], 'next_cursor': null};
  Map<String, Object?> parameters = {};
  String? method;
  bool fail = false;
  @override
  Future<Result<Map<String, Object?>?>> rpc(
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
void main() {
  late TeamFakeService service;
  late TeamRepositoryImpl repository;
  setUp(() {
    service = TeamFakeService();
    repository = TeamRepositoryImpl(service);
  });
  test('member mapping and cursor are immutable and preserved', () async {
    service.response = {
      'items': [memberJson()],
      'next_cursor': 'next',
    };
    final page =
        (await repository.members(active: true, cursor: 'previous')
                as Success<TeamPage>)
            .value;
    expect(page.members.single.role, StaffRole.employee);
    expect(page.nextCursor, 'next');
    expect(service.parameters['p_cursor'], 'previous');
    expect(() => page.members.clear(), throwsUnsupportedError);
  });
  test('unknown role fails closed', () async {
    service.response = {
      'items': [
        {...memberJson(), 'role': 'owner'},
      ],
    };
    expect(await repository.members(active: true), isA<Failure<TeamPage>>());
  });
  test(
    'invitations parse only approved fields and preserve password proof',
    () async {
      service.response = {
        'items': [invitationJson()],
      };
      final page = (await repository.invitations() as Success<TeamPage>).value;
      expect(page.invitations.single.passwordReady, isFalse);
      expect(page.invitations.single.canResend, isTrue);
    },
  );
  test(
    'null recipient invitation is an unavailable result rather than exception',
    () async {
      service.response = null;
      expect(
        (await repository.ownInvitation() as Success<TeamInvitation?>).value,
        isNull,
      );
    },
  );
  test('invite normalizes identity and never sends actor', () async {
    service.response = {'state': 'pending'};
    await repository.invite(
      ' Pessoa ',
      ' P@EXAMPLE.TEST ',
      StaffRole.employee,
      'operation',
    );
    expect(service.parameters, {
      'action': 'invite',
      'operation_key': 'operation',
      'name': 'Pessoa',
      'email': 'p@example.test',
      'role': 'employee',
    });
  });
  test(
    'member change uses optimistic version and receipt envelope compatibility',
    () async {
      service.response = {'member': memberJson()};
      final member = TeamMember(
        id: 'person',
        name: 'Pessoa',
        email: 'p@example.test',
        role: StaffRole.employee,
        active: true,
        version: 3,
      );
      final receipt =
          (await repository.change(member, StaffRole.administrator, true, 'key')
                  as Success<TeamReceipt>)
              .value;
      expect(receipt.state, 'confirmed');
      expect(service.parameters['p_expected_version'], 3);
    },
  );
  test('invalid receipt state and oversized pages fail safely', () async {
    service.response = {'state': 'success'};
    expect(
      await repository.invite(
        'Pessoa',
        'p@example.test',
        StaffRole.employee,
        'key',
      ),
      isA<Failure<TeamReceipt>>(),
    );
    service.response = {'items': List.generate(51, (_) => memberJson())};
    expect(await repository.members(active: true), isA<Failure<TeamPage>>());
  });
  test('service denial is preserved', () async {
    service.fail = true;
    expect(
      (await repository.members(active: true) as Failure<TeamPage>)
          .failure
          .code,
      FailureCode.forbidden,
    );
  });
}
