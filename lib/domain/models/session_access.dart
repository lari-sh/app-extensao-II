import 'package:freezed_annotation/freezed_annotation.dart';
part 'session_access.freezed.dart';

enum AccessLevel { visitor, authenticatedWithoutStaff, authorized }

enum AccessInterruption { recoverableExpiration, definitiveLoss }

enum StaffRole { administrator, employee }

@freezed
abstract class SessionAccess with _$SessionAccess {
  const SessionAccess._();
  const factory SessionAccess({
    @Default(AccessLevel.visitor) AccessLevel level,
    String? userId,
    StaffRole? role,
    @Default(AccessInterruption.definitiveLoss) AccessInterruption interruption,
  }) = _SessionAccess;
  bool get isAuthorized => level == AccessLevel.authorized && userId != null;
  bool get canManageTeam =>
      isAuthorized &&
      interruption != AccessInterruption.recoverableExpiration &&
      role == StaffRole.administrator;
}
