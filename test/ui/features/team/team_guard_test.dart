import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/data/services/supabase_auth_callback_service.dart';
import 'package:abrigo_dos_anjos/domain/models/auth_callback.dart';
import 'package:abrigo_dos_anjos/domain/models/session_access.dart';
import 'package:abrigo_dos_anjos/ui/features/auth/views/protected_scope.dart';
import 'package:abrigo_dos_anjos/ui/features/auth/view_models/login_view_model.dart';
import 'package:abrigo_dos_anjos/ui/features/auth/view_models/session_view_model.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import '../../../support/fakes/fake_auth_repository.dart';

void main() {
  testWidgets(
    'callback allowlist rejects unrelated hosts and credentials remain inside Service',
    (tester) async {
      final service = SupabaseAuthCallbackService();
      final received = <AuthCallbackKind>[];
      final sub = service.watch().listen(received.add);
      await tester.pump();
      expect(
        service.capture(Uri.parse('https://evil.test/auth/invite')),
        isFalse,
      );
      expect(
        service.capture(Uri.parse('br.org.abrigodosanjos.app://other/invite')),
        isFalse,
      );
      expect(
        service.capture(Uri.parse('br.org.abrigodosanjos.app://auth/unknown')),
        isFalse,
      );
      expect(
        service.capture(
          Uri.parse('br.org.abrigodosanjos.app://auth/invite#error=expired'),
        ),
        isTrue,
      );
      await tester.pump(const Duration(seconds: 3));
      await tester.pump();
      expect(received, [AuthCallbackKind.invitation]);
      await tester.runAsync(() async {
        await sub.cancel();
        await service.dispose();
      });
    },
  );
  testWidgets(
    'employee direct team scope never constructs private content; administrator demotion discards it',
    (tester) async {
      var access = const SessionAccess(
        level: AccessLevel.authorized,
        userId: 'person',
        role: StaffRole.employee,
      );
      final auth = FakeAuthRepository()
        ..handler = (_, _) async => Success(access);
      addTearDown(auth.dispose);
      final session = SessionViewModel(auth);
      addTearDown(session.dispose);
      await session.start();
      final login = LoginViewModel(auth);
      addTearDown(login.dispose);
      var built = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: ProtectedScope(
            session: session,
            login: login,
            requireTeamAdministrator: true,
            privateBuilder: () {
              built++;
              return const Scaffold(body: Text('Sensitive team'));
            },
          ),
        ),
      );
      expect(built, 0);
      expect(find.textContaining('Somente administradores'), findsOneWidget);
      access = access.copyWith(role: StaffRole.administrator);
      auth.events.add(Success(access));
      await tester.pumpAndSettle();
      expect(built, 1);
      expect(find.text('Sensitive team'), findsOneWidget);
      access = access.copyWith(role: StaffRole.employee);
      auth.events.add(Success(access));
      await tester.pumpAndSettle();
      expect(find.text('Sensitive team'), findsNothing);
      expect(find.textContaining('Somente administradores'), findsOneWidget);
    },
  );
}
