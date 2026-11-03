import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/domain/models/session_access.dart';
import 'package:abrigo_dos_anjos/ui/features/auth/views/protected_scope.dart';
import 'package:abrigo_dos_anjos/ui/features/auth/view_models/session_view_model.dart';
import 'package:abrigo_dos_anjos/ui/features/auth/view_models/login_view_model.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import '../../../../support/fakes/fake_auth_repository.dart';

void main() {
  testWidgets(
    'replacing session rebuilds private scope and detaches previous account',
    (tester) async {
      final firstRepo = FakeAuthRepository()
        ..handler = (_, _) async => const Success(
          SessionAccess(level: AccessLevel.authorized, userId: 'first-owner'),
        );
      final secondRepo = FakeAuthRepository()
        ..handler = (_, _) async => const Success(
          SessionAccess(level: AccessLevel.authorized, userId: 'second-owner'),
        );
      final first = SessionViewModel(firstRepo),
          second = SessionViewModel(secondRepo);
      final firstLogin = LoginViewModel(firstRepo),
          secondLogin = LoginViewModel(secondRepo);
      addTearDown(() async {
        firstLogin.dispose();
        secondLogin.dispose();
        first.dispose();
        second.dispose();
        await firstRepo.dispose();
        await secondRepo.dispose();
      });
      await first.start();
      await second.start();
      Widget scope(
        SessionViewModel session,
        LoginViewModel login,
        String label,
      ) => MaterialApp(
        home: ProtectedScope(
          key: const ValueKey('guard'),
          session: session,
          login: login,
          privateBuilder: () => Scaffold(body: Text(label)),
        ),
      );
      await tester.pumpWidget(
        scope(first, firstLogin, 'Dados da primeira conta'),
      );
      await tester.pumpAndSettle();
      expect(find.text('Dados da primeira conta'), findsOneWidget);
      await tester.pumpWidget(
        scope(second, secondLogin, 'Dados da segunda conta'),
      );
      await tester.pumpAndSettle();
      expect(find.text('Dados da primeira conta'), findsNothing);
      expect(find.text('Dados da segunda conta'), findsOneWidget);
      firstRepo.events.add(
        const Success(SessionAccess(level: AccessLevel.visitor)),
      );
      await tester.pumpAndSettle();
      expect(find.text('Dados da segunda conta'), findsOneWidget);
      await tester.pumpWidget(
        scope(second, secondLogin, 'Dados da segunda conta'),
      );
      await tester.pumpAndSettle();
      expect(find.text('Dados da segunda conta'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
