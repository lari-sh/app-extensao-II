import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:abrigo_dos_anjos/app/bootstrap.dart';
import 'package:abrigo_dos_anjos/app/public_dependencies.dart';
import 'package:abrigo_dos_anjos/data/services/supabase_animals_service.dart';
import 'package:abrigo_dos_anjos/data/repositories/animals_repository_impl.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import 'package:abrigo_dos_anjos/utils/app_failure.dart';

Future<void> reveal(
  WidgetTester tester,
  Finder target, {
  bool upwards = false,
}) async {
  for (var i = 0; i < 40 && target.hitTestable().evaluate().isEmpty; i++) {
    await tester.drag(
      find.byType(Scrollable).first,
      Offset(0, upwards ? 650 : -650),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
  }
  expect(
    target.hitTestable(),
    findsOneWidget,
    reason: 'Target must be visible before tapping.',
  );
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'visitor uses real pages, filters, photo, clipboard and native favorites after recreation',
    (tester) async {
      final url = const String.fromEnvironment('SUPABASE_URL');
      expect(
        Uri.parse(url).host,
        '10.0.2.2',
        reason: 'This test targets disposable local emulator fixtures only.',
      );
      final preferences = SharedPreferencesAsync();
      await preferences.setStringList('favorites_v1', []);
      await tester.pumpWidget(await bootstrapApplication());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Quero adotar'));
      await tester.pumpAndSettle(const Duration(milliseconds: 200));
      expect(find.text('58 animais encontrados'), findsOneWidget);
      await reveal(tester, find.text('Carregar mais'));
      await tester.tap(find.text('Carregar mais'));
      await tester.pumpAndSettle(const Duration(milliseconds: 200));
      expect(find.text('Animal de teste 58'), findsOneWidget);
      expect(find.text('Carregar mais'), findsNothing);
      await reveal(
        tester,
        find.byKey(const ValueKey('catalogSearch')),
        upwards: true,
      );
      await tester.enterText(
        find.byKey(const ValueKey('catalogSearch')),
        'Animal de teste 01',
      );
      await tester.pumpAndSettle(const Duration(milliseconds: 200));
      expect(find.text('1 animais encontrados'), findsOneWidget);
      await reveal(tester, find.byTooltip('Favoritar Animal de teste 01'));
      await tester.tap(find.byTooltip('Favoritar Animal de teste 01'));
      await tester.pumpAndSettle();
      expect(
        await preferences.getStringList('favorites_v1'),
        contains('00000000-0000-4000-8000-000000000001'),
      );
      await tester.tap(
        find.descendant(
          of: find.byType(Card),
          matching: find.text('Animal de teste 01'),
        ),
      );
      await tester.pumpAndSettle(const Duration(milliseconds: 200));
      expect(
        find.byWidgetPredicate(
          (widget) => widget is Image && widget.image is MemoryImage,
        ),
        findsOneWidget,
      );
      await reveal(tester, find.text('Tenho interesse'));
      await tester.tap(find.text('Tenho interesse'));
      await tester.pumpAndSettle(const Duration(milliseconds: 200));
      expect(
        find.text('Mensagem copiada. Nenhum pedido foi enviado.'),
        findsOneWidget,
      );
      final client = Supabase.instance.client;
      final repo = AnimalsRepositoryImpl(SupabaseAnimalsService(client));
      expect(
        (await repo.getPublic('00000000-0000-4000-8000-000000000059')
                as Failure)
            .failure
            .code,
        FailureCode.notFound,
      );
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await tester.pumpWidget(createPublicApplication(client));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Favoritos'));
      await tester.pumpAndSettle(const Duration(milliseconds: 200));
      expect(find.text('Animal de teste 01'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
