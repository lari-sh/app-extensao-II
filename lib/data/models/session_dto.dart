final class SessionDto {
  const SessionDto({
    this.userId,
    this.isStaffActive = false,
    this.recoverableExpiration = false,
  });
  final String? userId;
  final bool isStaffActive;
  final bool recoverableExpiration;
}
