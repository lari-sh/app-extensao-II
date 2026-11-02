import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/data/repositories/team_repository_impl.dart';
import 'package:abrigo_dos_anjos/domain/models/team_access.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import '../../support/team_fixtures.dart';

void main() {
  test(
    'cancel, resend and acceptance transmit versions and never caller identity or role',
    () async {
      final service = TeamFakeService()
        ..response = {'state': 'confirmed', 'invitation': invitationJson()};
      final repository = TeamRepositoryImpl(service);
      await repository.cancel(invitation(), 'cancel-key');
      expect(service.method, 'cancel_team_invitation');
      expect(service.parameters, {
        'p_invitation_id': 'invite',
        'p_expected_version': 2,
        'p_operation_key': 'cancel-key',
      });
      await repository.resend(invitation(), 'resend-key');
      expect(service.parameters, {
        'action': 'resend',
        'operation_key': 'resend-key',
        'invitation_id': 'invite',
        'expected_version': 2,
      });
      await repository.accept(invitation(), 'accept-key');
      expect(service.parameters, {
        'p_expected_generation': 1,
        'p_expected_version': 2,
        'p_operation_key': 'accept-key',
      });
      service.response = {...invitationJson(), 'password_ready': true};
      expect(
        (await repository.ownInvitation() as Success<TeamInvitation?>)
            .value!
            .passwordReady,
        isTrue,
      );
    },
  );
  for (final change in <Map<String, Object?>>[
    {'name': ''},
    {'generation': 0},
    {'status': 'unrecognized'},
    {'expires_at': 'not-a-date'},
    {'role': 'owner'},
  ]) {
    test('malformed invitation $change fails safely', () async {
      final service = TeamFakeService()
        ..response = {...invitationJson(), ...change};
      expect(
        await TeamRepositoryImpl(service).ownInvitation(),
        isA<Failure<TeamInvitation?>>(),
      );
    });
  }
  test(
    'invalid member active flag and missing page or receipt are rejected',
    () async {
      final service = TeamFakeService();
      final repo = TeamRepositoryImpl(service);
      service.response = {
        'items': [
          {...memberJson(), 'active': 'yes'},
        ],
      };
      expect(await repo.members(active: false), isA<Failure<TeamPage>>());
      service.response = null;
      expect(await repo.invitations(), isA<Failure<TeamPage>>());
      expect(
        await repo.cancel(invitation(), 'key'),
        isA<Failure<TeamReceipt>>(),
      );
    },
  );
}
