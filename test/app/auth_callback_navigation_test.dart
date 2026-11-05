import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/domain/models/auth_callback.dart';
import 'package:abrigo_dos_anjos/domain/models/session_access.dart';
import 'package:abrigo_dos_anjos/domain/models/team_access.dart';
import 'package:abrigo_dos_anjos/ui/features/auth/view_models/auth_callback_view_model.dart';
import 'package:abrigo_dos_anjos/ui/features/auth/view_models/session_view_model.dart';
import 'package:abrigo_dos_anjos/app/auth_application.dart';
import 'package:abrigo_dos_anjos/app/app_router.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import '../support/public_app_harness.dart';
import '../support/fakes/fake_auth_repository.dart';
import '../support/fakes/fake_team_repository.dart';

class CallbackSource implements AuthCallbackSource {
  final events = StreamController<AuthCallbackKind>.broadcast();
  @override
  Stream<AuthCallbackKind> watch() => events.stream;
}

void main() {
  test(
    'callback route is consumed once and subscription is cancelled on disposal',
    () async {
      final source = CallbackSource();
      final vm = AuthCallbackViewModel(source);
      source.events.add(AuthCallbackKind.invitation);
      await Future<void>.delayed(Duration.zero);
      expect(vm.takeRoute(), '/accept-invitation');
      expect(vm.takeRoute(), isNull);
      source.events.add(AuthCallbackKind.recovery);
      await Future<void>.delayed(Duration.zero);
      expect(vm.takeRoute(), '/reset-password');
      vm.dispose();
      expect(source.events.hasListener, isFalse);
      await source.events.close();
    },
  );
  testWidgets(
    'auth application routes an invite event to server-checked unavailable state',
    (tester) async {
      final h = PublicAppHarness();
      final source = CallbackSource();
      final callbacks = AuthCallbackViewModel(source);
      final auth = FakeAuthRepository()
        ..handler = (_, _) async => const Success(SessionAccess());
      final session = SessionViewModel(auth);
      await session.start();
      final team = FakeTeamRepository()
        ..handler = (_, _) async => const Success<TeamInvitation?>(null);
      final router = AppRouter(
        animals: h.animals,
        favorites: h.favorites,
        photos: h.photos,
        adoption: h.adoption,
        auth: auth,
        session: session,
        team: team,
      );
      await tester.pumpWidget(
        AuthApplication(session: session, router: router, callbacks: callbacks),
      );
      await tester.pumpAndSettle();
      source.events.add(AuthCallbackKind.invitation);
      await tester.pumpAndSettle();
      expect(team.calls.single.method, 'ownInvitation');
      expect(find.textContaining('expirou'), findsOneWidget);
      expect(session.state.canAccessPrivate, isFalse);
      await tester.pumpWidget(const SizedBox.shrink());
      callbacks.dispose();
      session.dispose();
      await tester.runAsync(() async {
        await source.events.close();
        await auth.dispose();
      });
    },
  );
}
