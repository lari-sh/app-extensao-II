import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/data/repositories/auth_repository_impl.dart';
import 'package:abrigo_dos_anjos/data/models/session_dto.dart';
import 'package:abrigo_dos_anjos/domain/models/session_access.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import 'package:abrigo_dos_anjos/utils/app_failure.dart';
import '../../support/fakes/fake_auth_service.dart';

void main() {
  test(
    'team capability requires matching server role and explicit permission',
    () async {
      final service = FakeAuthService();
      addTearDown(service.dispose);
      final repo = AuthRepositoryImpl(service);
      for (final entry in [
        (
          const SessionDto(
            userId: 'u',
            isStaffActive: true,
            staffRole: 'administrator',
            canManageTeam: true,
          ),
          true,
        ),
        (
          const SessionDto(
            userId: 'u',
            isStaffActive: true,
            staffRole: 'administrator',
          ),
          false,
        ),
        (
          const SessionDto(
            userId: 'u',
            isStaffActive: true,
            staffRole: 'employee',
            canManageTeam: true,
          ),
          false,
        ),
        (
          const SessionDto(
            userId: 'u',
            isStaffActive: true,
            staffRole: 'owner',
            canManageTeam: true,
          ),
          false,
        ),
        (
          const SessionDto(
            userId: 'u',
            staffRole: 'administrator',
            canManageTeam: true,
          ),
          false,
        ),
        (
          const SessionDto(
            userId: 'u',
            isStaffActive: true,
            staffRole: 'administrator',
            canManageTeam: true,
            recoverableExpiration: true,
          ),
          false,
        ),
      ]) {
        service.handler = (_, _) async => Success(entry.$1);
        final access =
            (await repo.restoreAccess() as Success<SessionAccess>).value;
        expect(access.canManageTeam, entry.$2);
      }
    },
  );
  test(
    'repository maps visitor, nonstaff, staff and recoverable expiration',
    () async {
      final service = FakeAuthService();
      addTearDown(service.dispose);
      final repo = AuthRepositoryImpl(service);
      for (final dto in [
        const SessionDto(),
        const SessionDto(userId: 'u'),
        const SessionDto(userId: 'u', isStaffActive: true),
        const SessionDto(userId: 'u', recoverableExpiration: true),
      ]) {
        service.handler = (_, args) async => Success(dto);
        final result =
            (await repo.restoreAccess() as Success<SessionAccess>).value;
        expect(
          result.isAuthorized,
          dto.isStaffActive && !dto.recoverableExpiration,
        );
        expect(
          result.interruption,
          dto.recoverableExpiration
              ? AccessInterruption.recoverableExpiration
              : AccessInterruption.definitiveLoss,
        );
      }
    },
  );
  test(
    'service failures and unexpected errors never escape repository',
    () async {
      final service = FakeAuthService();
      addTearDown(service.dispose);
      final repo = AuthRepositoryImpl(service);
      service.handler = (_, args) async =>
          Failure<SessionDto>(AppFailure(FailureCode.timeout));
      expect(
        (await repo.currentAccess() as Failure).failure.code,
        FailureCode.timeout,
      );
      service.handler = (_, args) async => throw StateError('secret');
      expect(
        (await repo.signIn('email', 'password') as Failure).failure.code,
        FailureCode.unknown,
      );
    },
  );
  test(
    'late login cannot revive a session after logout and remote failure stays visible',
    () async {
      final login = Completer<Object?>();
      final service = FakeAuthService()
        ..handler = (method, args) async => method == 'signIn'
            ? login.future
            : Failure<Unit>(AppFailure(FailureCode.network));
      addTearDown(service.dispose);
      final repo = AuthRepositoryImpl(service);
      final signingIn = repo.signIn('email', 'password');
      await Future<void>.delayed(Duration.zero);
      final signingOut = repo.signOut();
      login.complete(
        const Success(SessionDto(userId: 'u', isStaffActive: true)),
      );
      expect(await signingIn, isA<Failure>());
      expect(await signingOut, isA<Failure>());
      expect(
        (await repo.restoreAccess() as Success<SessionAccess>).value.level,
        AccessLevel.visitor,
      );
      expect(await repo.signOut(), isA<Failure>());
    },
  );
  test(
    'watch converts raw stream errors and ignores late authorized event after logout',
    () async {
      final service = FakeAuthService()
        ..handler = (_, args) async => const Success(Unit.value);
      addTearDown(service.dispose);
      final repo = AuthRepositoryImpl(service);
      final values = <Result<SessionAccess>>[];
      final sub = repo.watchAccess().listen(values.add);
      service.events.addError(StateError('raw'));
      service.events.add(
        const Success(SessionDto(userId: 'u', isStaffActive: true)),
      );
      await Future<void>.delayed(Duration.zero);
      expect(values.first, isA<Failure>());
      expect(
        (values.last as Success<SessionAccess>).value.isAuthorized,
        isTrue,
      );
      await repo.signOut();
      service.events.add(
        const Success(SessionDto(userId: 'u', isStaffActive: true)),
      );
      await Future<void>.delayed(Duration.zero);
      expect(
        (values.last as Success<SessionAccess>).value.isAuthorized,
        isFalse,
      );
      await sub.cancel();
    },
  );
}
