import '../../utils/result.dart';
import '../models/team_access.dart';
import '../models/session_access.dart';

abstract interface class TeamRepository {
  Future<Result<TeamPage>> members({required bool active, String? cursor});
  Future<Result<TeamPage>> invitations({String? cursor});
  Future<Result<TeamReceipt>> invite(
    String name,
    String email,
    StaffRole role,
    String key,
  );
  Future<Result<TeamReceipt>> resend(TeamInvitation invitation, String key);
  Future<Result<TeamReceipt>> cancel(TeamInvitation invitation, String key);
  Future<Result<TeamReceipt>> change(
    TeamMember member,
    StaffRole role,
    bool active,
    String key,
  );
  Future<Result<TeamReceipt>> reconcile(String key);
  Future<Result<TeamInvitation?>> ownInvitation();
  Future<Result<Unit>> definePassword(String password);
  Future<Result<TeamReceipt>> accept(TeamInvitation invitation, String key);
}
