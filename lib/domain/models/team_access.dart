import 'package:freezed_annotation/freezed_annotation.dart';
import 'session_access.dart';
part 'team_access.freezed.dart';

@freezed
abstract class TeamMember with _$TeamMember {
  const factory TeamMember({
    required String id,
    required String name,
    required String email,
    required StaffRole role,
    required bool active,
    required int version,
  }) = _TeamMember;
}

@freezed
abstract class TeamInvitation with _$TeamInvitation {
  const TeamInvitation._();
  const factory TeamInvitation({
    required String id,
    required String name,
    required String email,
    required StaffRole role,
    required String status,
    required int generation,
    required int version,
    required DateTime expiresAt,
    required String deliveryState,
    @Default(0) int retryAfter,
    @Default(false) bool passwordReady,
  }) = _TeamInvitation;
  bool get canAccept => status == 'pending';
  bool get canCancel =>
      const ['preparing', 'pending', 'expired', 'failed'].contains(status);
  bool get canResend => canCancel && retryAfter == 0;
}

@freezed
abstract class TeamPage with _$TeamPage {
  const factory TeamPage({
    @Default([]) List<TeamMember> members,
    @Default([]) List<TeamInvitation> invitations,
    String? nextCursor,
  }) = _TeamPage;
}

@freezed
abstract class TeamReceipt with _$TeamReceipt {
  const factory TeamReceipt({
    required String state,
    String? code,
    TeamInvitation? invitation,
    TeamMember? member,
  }) = _TeamReceipt;
}
