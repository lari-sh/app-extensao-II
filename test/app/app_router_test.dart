import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/ui/features/auth/views/protected_scope.dart';
import 'package:abrigo_dos_anjos/ui/features/auth/view_models/login_view_model.dart';
import 'package:abrigo_dos_anjos/ui/features/auth/view_models/session_view_model.dart';
import 'package:abrigo_dos_anjos/domain/models/session_access.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import '../support/fakes/fake_auth_repository.dart';

const staff = SessionAccess(level: AccessLevel.authorized, userId: 'u');

class DraftProbe extends StatefulWidget {
  const DraftProbe({super.key, required this.onDispose});
  final VoidCallback onDispose;
  @override
  State<DraftProbe> createState() => _DraftProbeState();
}

class _DraftProbeState extends State<DraftProbe> {
  final controller = TextEditingController();
  @override
  void dispose() {
    widget.onDispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: TextField(
      key: const ValueKey('privateDraft'),
      controller: controller,
    ),
  );
}

void main() {
  testWidgets(
    'private subtree is not created during checking, hides without disposal on expiry and resumes same user',
    (tester) async {
      final delayed = Completer<Object?>();
      final repo = FakeAuthRepository()..handler = (_, args) => delayed.future;
      addTearDown(repo.dispose);
      final session = SessionViewModel(repo);
      addTearDown(session.dispose);
      final login = LoginViewModel(repo);
      addTearDown(login.dispose);
      var created = 0, disposed = 0;
      final initial = session.start();
      await tester.pumpWidget(
        MaterialApp(
          home: ProtectedScope(
            session: session,
            login: login,
            privateBuilder: () {
              created++;
              return DraftProbe(onDispose: () => disposed++);
            },
          ),
        ),
      );
      await tester.pump();
      expect(created, 0);
      delayed.complete(const Success(staff));
      await initial;
      await tester.pumpAndSettle();
      expect(created, 1);
      await tester.enterText(
        find.byKey(const ValueKey('privateDraft')),
        'rascunho confidencial',
      );
      repo.events.add(
        const Success(
          SessionAccess(
            userId: 'u',
            interruption: AccessInterruption.recoverableExpiration,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('privateDraft')), findsNothing);
      expect(disposed, 0);
      await tester.scrollUntilVisible(
        find.text('Cancelar reautenticação'),
        200,
        scrollable: find
            .descendant(
              of: find.byType(ListView).last,
              matching: find.byType(Scrollable),
            )
            .first,
      );
      expect(find.text('Cancelar reautenticação'), findsOneWidget);
      final ticket = session.beginSignIn()!;
      session.completeSignIn(ticket, staff);
      await tester.pumpAndSettle();
      expect(find.text('rascunho confidencial'), findsOneWidget);
      expect(created, 1);
      repo.events.add(const Success(SessionAccess()));
      await tester.pumpAndSettle();
      expect(disposed, 1);
      expect(find.text('rascunho confidencial'), findsNothing);
    },
  );
  testWidgets(
    'reauth cancel discards draft and different user gets a fresh subtree',
    (tester) async {
      final repo = FakeAuthRepository()
        ..handler = (method, args) async => method == 'signOut'
            ? const Success(Unit.value)
            : const Success(staff);
      addTearDown(repo.dispose);
      final session = SessionViewModel(repo);
      addTearDown(session.dispose);
      await session.start();
      final login = LoginViewModel(repo);
      addTearDown(login.dispose);
      var disposed = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: ProtectedScope(
            session: session,
            login: login,
            privateBuilder: () => DraftProbe(onDispose: () => disposed++),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('privateDraft')),
        'private',
      );
      repo.events.add(
        const Success(
          SessionAccess(
            userId: 'u',
            interruption: AccessInterruption.recoverableExpiration,
          ),
        ),
      );
      await tester.pumpAndSettle();
      final ticket = session.beginSignIn()!;
      session.completeSignIn(
        ticket,
        const SessionAccess(level: AccessLevel.authorized, userId: 'other'),
      );
      await tester.pumpAndSettle();
      expect(disposed, 1);
      expect(find.text('private'), findsNothing);
      repo.events.add(
        const Success(
          SessionAccess(
            userId: 'other',
            interruption: AccessInterruption.recoverableExpiration,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Cancelar reautenticação'),
        200,
        scrollable: find
            .descendant(
              of: find.byType(ListView).last,
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await Scrollable.ensureVisible(
        tester.element(find.text('Cancelar reautenticação')),
        alignment: 0.5,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancelar reautenticação'));
      await tester.pumpAndSettle();
      expect(disposed, 2);
      expect(find.byKey(const ValueKey('privateDraft')), findsNothing);
    },
  );
}
