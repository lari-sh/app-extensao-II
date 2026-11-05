import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/domain/models/session_access.dart';

void main() {
  test(
    'team management requires current authorized administrator identity',
    () {
      const admin = SessionAccess(
        level: AccessLevel.authorized,
        userId: 'admin',
        role: StaffRole.administrator,
      );
      expect(admin.canManageTeam, isTrue);
      expect(admin.copyWith(role: StaffRole.employee).canManageTeam, isFalse);
      expect(admin.copyWith(role: null).canManageTeam, isFalse);
      expect(admin.copyWith(userId: null).canManageTeam, isFalse);
      expect(admin.copyWith(level: AccessLevel.visitor).canManageTeam, isFalse);
      expect(
        admin
            .copyWith(interruption: AccessInterruption.recoverableExpiration)
            .canManageTeam,
        isFalse,
      );
    },
  );
  test('only verified staff with identity has private capabilities', () {
    expect(const SessionAccess().isAuthorized, isFalse);
    expect(
      const SessionAccess(
        level: AccessLevel.authenticatedWithoutStaff,
        userId: 'u',
      ).isAuthorized,
      isFalse,
    );
    expect(
      const SessionAccess(level: AccessLevel.authorized).isAuthorized,
      isFalse,
    );
    const access = SessionAccess(level: AccessLevel.authorized, userId: 'u');
    expect(access.isAuthorized, isTrue);
    expect(access.copyWith(), access);
    expect(access.interruption, AccessInterruption.definitiveLoss);
    expect(
      access
          .copyWith(interruption: AccessInterruption.recoverableExpiration)
          .userId,
      'u',
    );
  });
}
