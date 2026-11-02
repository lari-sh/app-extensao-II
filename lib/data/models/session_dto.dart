final class SessionDto {
  const SessionDto({
    this.userId,
    this.isStaffActive = false,
    this.recoverableExpiration = false,
    this.staffRole,
    this.canManageTeam = false,
  });
  final String? userId;
  final bool isStaffActive;
  final bool recoverableExpiration;
  final String? staffRole;
  final bool canManageTeam;
}
