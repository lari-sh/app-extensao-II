import 'package:abrigo_dos_anjos/domain/repositories/team_repository.dart';
import 'package:abrigo_dos_anjos/domain/models/team_access.dart';
import 'package:abrigo_dos_anjos/domain/models/session_access.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import 'fake_behavior.dart';

class FakeTeamRepository extends FakeBehavior implements TeamRepository {
  @override
  Future<Result<TeamPage>> members({required bool active, String? cursor}) =>
      invoke('members', [active, cursor]);
  @override
  Future<Result<TeamPage>> invitations({String? cursor}) =>
      invoke('invitations', [cursor]);
  @override
  Future<Result<TeamReceipt>> invite(
    String name,
    String email,
    StaffRole role,
    String key,
  ) => invoke('invite', [name, email, role, key]);
  @override
  Future<Result<TeamReceipt>> resend(TeamInvitation invitation, String key) =>
      invoke('resend', [invitation, key]);
  @override
  Future<Result<TeamReceipt>> cancel(TeamInvitation invitation, String key) =>
      invoke('cancel', [invitation, key]);
  @override
  Future<Result<TeamReceipt>> change(
    TeamMember member,
    StaffRole role,
    bool active,
    String key,
  ) => invoke('change', [member, role, active, key]);
  @override
  Future<Result<TeamReceipt>> reconcile(String key) =>
      invoke('reconcile', [key]);
  @override
  Future<Result<TeamInvitation?>> ownInvitation() =>
      invoke('ownInvitation', []);
  @override
  Future<Result<Unit>> definePassword(String password) =>
      invoke('definePassword', [password]);
  @override
  Future<Result<TeamReceipt>> accept(TeamInvitation invitation, String key) =>
      invoke('accept', [invitation, key]);
}
