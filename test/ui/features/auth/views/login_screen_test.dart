import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/ui/features/auth/views/login_screen.dart';
import 'package:abrigo_dos_anjos/ui/features/auth/view_models/login_view_model.dart';
import 'package:abrigo_dos_anjos/domain/models/session_access.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import '../../../../support/fakes/fake_auth_repository.dart';

void main() {
  testWidgets(
    'compact login scrolls to visitor entry and disabled options never authenticate',
    (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repo = FakeAuthRepository();
      addTearDown(repo.dispose);
      final vm = LoginViewModel(repo);
      addTearDown(vm.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(viewModel: vm),
          routes: {
            '/catalog': (_) => const Scaffold(body: Text('Catálogo público')),
          },
        ),
      );
      await tester.scrollUntilVisible(
        find.text('Esqueci a senha'),
        150,
        scrollable: find
            .descendant(
              of: find.byType(ListView).last,
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await Scrollable.ensureVisible(
        tester.element(find.text('Esqueci a senha')),
        alignment: 0.5,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Esqueci a senha'));
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();
      expect(repo.calls, isEmpty);
      expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);
      await tester.scrollUntilVisible(
        find.text('Conhecer os animais disponíveis'),
        150,
        scrollable: find
            .descendant(
              of: find.byType(ListView).last,
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await Scrollable.ensureVisible(
        tester.element(find.text('Conhecer os animais disponíveis')),
        alignment: 0.5,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Conhecer os animais disponíveis'));
      await tester.pumpAndSettle();
      expect(find.text('Catálogo público'), findsOneWidget);
      // Flutter reports any rendering exception after this test.
    },
  );
  testWidgets(
    'authorized login navigates to protected destination without public signup',
    (tester) async {
      final repo = FakeAuthRepository()
        ..handler = (_, args) async => const Success(
          SessionAccess(level: AccessLevel.authorized, userId: 'u'),
        );
      addTearDown(repo.dispose);
      final vm = LoginViewModel(repo);
      addTearDown(vm.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(viewModel: vm),
          routes: {
            '/volunteer': (_) =>
                const Scaffold(body: Text('Destino protegido')),
          },
        ),
      );
      await tester.enterText(
        find.byKey(const ValueKey('loginEmail')),
        'staff@example.test',
      );
      await tester.enterText(
        find.byKey(const ValueKey('loginPassword')),
        'secret',
      );
      expect(find.byType(AppBar), findsNothing);
      final logo = find.byKey(const ValueKey('loginShelterLogo'));
      expect(logo, findsOneWidget);
      expect(tester.getCenter(logo).dx, closeTo(400, 1));
      expect(find.text('E-mail institucional'), findsOneWidget);
      expect(find.text('Permanecer logado'), findsOneWidget);
      expect(tester.widget<Checkbox>(find.byType(Checkbox)).onChanged, isNull);
      expect(
        tester
            .widget<TextButton>(
              find.widgetWithText(TextButton, 'Esqueci a senha'),
            )
            .onPressed,
        isNull,
      );
      await tester.ensureVisible(find.text('Entrar no painel'));
      await tester.tap(find.text('Entrar no painel'));
      await tester.pumpAndSettle();
      expect(find.text('Destino protegido'), findsOneWidget);
      expect(find.text('Criar conta'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'login return uses cancellation during reauthentication and keeps logo centered',
    (tester) async {
      final repo = FakeAuthRepository();
      addTearDown(repo.dispose);
      final vm = LoginViewModel(repo);
      addTearDown(vm.dispose);
      var cancelled = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(
            viewModel: vm,
            navigateOnSuccess: false,
            onCancel: () {
              cancelled++;
            },
          ),
        ),
      );
      await tester.tap(find.byTooltip('Voltar'));
      await tester.pumpAndSettle();
      expect(cancelled, 1);
      expect(find.byKey(const ValueKey('loginShelterLogo')), findsOneWidget);
      expect(
        tester.getCenter(find.byKey(const ValueKey('loginShelterLogo'))).dx,
        tester.view.physicalSize.width / tester.view.devicePixelRatio / 2,
      );
    },
  );
}
