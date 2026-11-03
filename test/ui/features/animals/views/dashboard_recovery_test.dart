import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/domain/models/animal.dart';
import 'package:abrigo_dos_anjos/ui/features/animals/views/dashboard_screen.dart';
import 'package:abrigo_dos_anjos/ui/features/animals/view_models/dashboard_view_model.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import 'package:abrigo_dos_anjos/utils/app_failure.dart';
import '../../../../support/management_scenarios.dart';
import '../../../../support/presentation_fixtures.dart';

void main() {
  testWidgets(
    'dashboard displays pending load, pagination in both modes, edit menu and resume refresh',
    (tester) async {
      final repo = managementScenario();
      final gate = Completer<Result<Map<AnimalStatus, int>>>();
      var slow = true;
      repo.handler = (m, a) => slow && m == 'getStatusCounts'
          ? gate.future
          : managementResponse(m, a);
      final vm = DashboardViewModel(repo, isAuthorized: () => true);
      addTearDown(vm.dispose);
      final loading = vm.load();
      await tester.pump();
      await tester.pumpWidget(
        MaterialApp(
          home: DashboardScreen(viewModel: vm),
          onGenerateRoute: (settings) => MaterialPageRoute<void>(
            settings: settings,
            builder: (context) =>
                Scaffold(appBar: AppBar(), body: const Text('Editor de Bento')),
          ),
        ),
      );
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      slow = false;
      gate.complete(const Success({AnimalStatus.available: 2}));
      await loading;
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mais').first);
      await tester.pumpAndSettle();
      expect(
        repo.calls.where(
          (c) => c.method == 'listManagement' && c.arguments.last == 'next',
        ),
        isNotEmpty,
      );
      await vm.load();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lista'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Carregar mais Disponíveis'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Carregar mais Disponíveis'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byTooltip('Ações de Bento'));
      await tester.tap(find.byTooltip('Ações de Bento'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Editar cadastro'));
      await tester.pumpAndSettle();
      expect(find.text('Editor de Bento'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      final count = repo.calls.length;
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(repo.calls.length, greaterThan(count));
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'uncertain command exposes reconciliation and same-operation retry',
    (tester) async {
      final repo = managementScenario();
      final vm = DashboardViewModel(
        repo,
        isAuthorized: () => true,
        delay: (_) async {},
      );
      addTearDown(vm.dispose);
      await vm.load();
      var sent = 0;
      repo.handler = (m, a) async {
        if (m == 'setStatus') {
          sent++;
          return sent == 1
              ? Failure<PublicAnimal>(AppFailure(FailureCode.timeout))
              : Success(presentationAnimal('bento'));
        }
        if (m == 'getOperation') return const Success<ManagedAnimal?>(null);
        return await managementResponse(m, a);
      };
      await vm.setStatus(
        presentationAnimal('bento').id,
        AnimalStatus.treatment,
      );
      await tester.pumpWidget(
        MaterialApp(home: DashboardScreen(viewModel: vm)),
      );
      await tester.tap(find.text('Consultar resultado'));
      await tester.pumpAndSettle();
      expect(vm.state.canRetry, isTrue);
      await tester.tap(find.text('Tentar novamente'));
      await tester.pumpAndSettle();
      expect(sent, 2);
      expect(vm.state.uncertain, isFalse);
      expect(tester.takeException(), isNull);
    },
  );
}
