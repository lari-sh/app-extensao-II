import 'package:abrigo_dos_anjos/ui/features/animals/views/animal_detail_screen.dart';
import 'package:abrigo_dos_anjos/ui/features/animals/view_models/animal_detail_view_model.dart';
import 'package:abrigo_dos_anjos/domain/models/animal.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import '../../../../support/public_fixtures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../../support/public_app_harness.dart';

void main() {
  testWidgets('detail copies interest without sending adoption request', (
    tester,
  ) async {
    final harness = PublicAppHarness();
    await tester.pumpWidget(harness.app());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Quero Adotar (Visitante)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Luna 1'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('publicAnimalSheet')), findsOneWidget);
    expect(find.text('Porte M'), findsOneWidget);
    expect(find.text('Fêmea'), findsOneWidget);
    expect(find.text('Vacinas'), findsOneWidget);
    expect(find.text('Castrado'), findsOneWidget);
    expect(find.text('Cadastro em planejamento'), findsNWidgets(2));
    expect(find.byType(AppBar), findsNothing);
    await tester.tap(find.text('Entrar em contato para adoção'));
    await tester.pumpAndSettle();
    expect(
      find.text('Mensagem copiada. Nenhum pedido foi enviado.'),
      findsOneWidget,
    );
    expect(harness.adoption.calls.length, 1);
    await tester.tap(find.byTooltip('Fechar detalhes'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('publicAnimalSheet')), findsNothing);
    expect(find.text('Conheça nossos anjos'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'compact public sheet keeps action visible without layout overflow',
    (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final harness = PublicAppHarness();
      final vm = AnimalDetailViewModel(
        harness.animals,
        harness.favorites,
        harness.photos,
        harness.adoption,
      );
      addTearDown(vm.dispose);
      await vm.load(fixtureId(1));
      await tester.pumpWidget(
        MaterialApp(home: AnimalDetailScreen(viewModel: vm)),
      );
      await tester.pumpAndSettle();
      expect(
        find.text('Entrar em contato para adoção').hitTestable(),
        findsOneWidget,
      );
      expect(find.byTooltip('Fechar detalhes').hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('treatment public animal keeps prototype contact area disabled', (
    tester,
  ) async {
    final harness = PublicAppHarness();
    await tester.pumpWidget(harness.app());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Quero Adotar (Visitante)'));
    await tester.pumpAndSettle();
    harness.animals.handler = (_, _) async =>
        Success(fixtureAnimal(1).copyWith(status: AnimalStatus.treatment));
    await tester.tap(find.text('Luna 1'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Entrar em contato para adoção'),
          )
          .onPressed,
      isNull,
    );
    expect(
      find.text('Este animal não está disponível para adoção no momento.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'authorized heart changes favorite and public favorites reflect confirmed selection',
    (tester) async {
      final harness = PublicAppHarness();
      harness.ids.clear();
      await tester.pumpWidget(harness.app());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Quero Adotar (Visitante)'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Luna 1'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Favoritar Luna 1'));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Remover Luna 1 dos favoritos'), findsOneWidget);
      expect(harness.ids, contains(fixtureId(1)));
      await tester.tap(find.byTooltip('Fechar detalhes'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Favoritos'));
      await tester.pumpAndSettle();
      expect(find.text('Luna 1'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
