import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/ui/core/theme/app_theme.dart';
import 'package:abrigo_dos_anjos/ui/features/animals/views/dashboard_screen.dart';
import 'package:abrigo_dos_anjos/ui/features/animals/view_models/dashboard_view_model.dart';
import 'package:abrigo_dos_anjos/ui/features/medications/view_models/medication_calendar_view_model.dart';
import 'package:abrigo_dos_anjos/domain/models/animal.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import '../../../../support/fakes/fake_animals_repository.dart';
import '../../../../support/fakes/fake_medication_completion_scenario.dart';

void main() {
  for (final admin in [true, false]) {
    for (final mode in DashboardMode.values) {
      testWidgets(
        'header menu for ${admin ? 'administrator' : 'employee'} in ${mode.name}',
        (tester) async {
          tester.view.physicalSize = const Size(320, 1000);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final repo = FakeAnimalsRepository()
            ..handler = (method, _) async => method == 'getStatusCounts'
                ? const Success<Map<AnimalStatus, int>>({})
                : const Success(ManagedAnimalPage(items: [], total: 0));
          final calendar = MedicationCalendarViewModel(
            FakeMedicationCompletionScenario().repository,
          );
          final vm = DashboardViewModel(
            repo,
            isAuthorized: () => true,
            canManageTeam: () => admin,
            onCalendarSelected: calendar.initialize,
          );
          addTearDown(vm.dispose);
          addTearDown(calendar.dispose);
          await vm.load();
          vm.setMode(mode);
          var signOuts = 0;
          await tester.pumpWidget(
            MaterialApp(
              theme: buildTheme(),
              routes: {
                '/animal-editor': (_) =>
                    const Scaffold(body: Text('Novo cadastro de teste')),
                '/team': (_) => Scaffold(
                  appBar: AppBar(),
                  body: const Text('Equipe de teste'),
                ),
              },
              home: MediaQuery(
                data: const MediaQueryData(
                  size: Size(320, 1000),
                  textScaler: TextScaler.linear(1.4),
                ),
                child: DashboardScreen(
                  viewModel: vm,
                  calendarViewModel: calendar,
                  onSignOut: () {
                    signOuts++;
                  },
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(find.text('Equipe'), findsNothing);
          expect(find.text('Equipe e acessos'), findsNothing);
          expect(find.text('Total: 0 animais'), findsOneWidget);
          expect(find.byType(FloatingActionButton), findsNothing);
          expect(find.text('Adicionar animal'), findsNothing);
          if (mode == DashboardMode.kanban) {
            final columns = find.descendant(
              of: find.byKey(const ValueKey('animal-kanban')),
              matching: find.byWidgetPredicate(
                (w) =>
                    w is Container &&
                    w.decoration is BoxDecoration &&
                    (w.decoration! as BoxDecoration).color == softBackground,
              ),
            );
            expect(columns, findsNWidgets(3));
            expect(tester.getRect(columns.first).bottom, closeTo(1000, 1));
          }
          final menu = find.byTooltip('Administração');
          final rect = tester.getRect(menu);
          expect(rect.width, greaterThanOrEqualTo(48));
          expect(rect.height, greaterThanOrEqualTo(48));
          expect(rect.top, lessThan(100));
          await tester.tap(menu);
          await tester.pumpAndSettle();
          expect(
            find.text('Equipe e acessos'),
            admin ? findsOneWidget : findsNothing,
          );
          expect(find.text('Sair da conta'), findsOneWidget);
          final add = find.byKey(const ValueKey('addAnimal'));
          expect(add, findsOneWidget);
          expect(
            tester.widget<Text>(find.text('Adicionar animal')).style!.color,
            brandRed,
          );
          expect(tester.getSize(add).height, greaterThanOrEqualTo(48));
          await tester.tap(add);
          await tester.pumpAndSettle();
          expect(find.text('Novo cadastro de teste'), findsOneWidget);
          Navigator.of(
            tester.element(find.text('Novo cadastro de teste')),
          ).pop();
          await tester.pumpAndSettle();
          expect(vm.state.mode, mode);
          await tester.tap(menu);
          await tester.pumpAndSettle();

          if (admin) {
            await tester.tap(find.text('Equipe e acessos'));
            await tester.pumpAndSettle();
            expect(find.text('Equipe de teste'), findsOneWidget);
            Navigator.of(tester.element(find.text('Equipe de teste'))).pop();
            await tester.pumpAndSettle();
            expect(vm.state.mode, mode);
            await tester.tap(menu);
            await tester.pumpAndSettle();
          }
          await tester.tap(find.text('Sair da conta'));
          await tester.pumpAndSettle();
          expect(signOuts, 1);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
