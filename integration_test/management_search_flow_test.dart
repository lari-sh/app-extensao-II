import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:integration_test/integration_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:abrigo_dos_anjos/app/bootstrap.dart';
import 'package:abrigo_dos_anjos/ui/features/animals/views/dashboard_screen.dart';
import 'package:abrigo_dos_anjos/ui/features/medications/views/medication_calendar_panel.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'Android global name/code filters, preserved calendar day and editor return',
    (tester) async {
      final fixture =
          jsonDecode(
                (await http.get(
                  Uri.parse('http://10.0.2.2:58766/fixtures'),
                )).body,
              )
              as Map;
      Future<void> waitFor(Finder f) async {
        for (var i = 0; i < 100 && f.evaluate().isEmpty; i++) {
          await tester.pumpAndSettle();
          await Future<void>.delayed(const Duration(milliseconds: 100));
        }
        expect(f, findsWidgets);
      }

      await tester.pumpWidget(await bootstrapApplication());
      await tester.pumpAndSettle();
      await Supabase.instance.client.auth.signOut(scope: SignOutScope.local);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Acesso Voluntário / Funcionário'));
      await tester.pumpAndSettle();
      await waitFor(find.byKey(const ValueKey('loginEmail')));
      await tester.enterText(
        find.byKey(const ValueKey('loginEmail')),
        fixture['email'] as String,
      );
      await tester.enterText(
        find.byKey(const ValueKey('loginPassword')),
        fixture['password'] as String,
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await waitFor(find.text('Animais do abrigo'));
      await tester.tap(find.text('Animais do abrigo'));
      await waitFor(find.byType(DashboardScreen));
      await tester.pumpAndSettle();
      final field = find.byKey(const ValueKey('management-search'));
      Future<void> query(String text) async {
        final vm = tester
            .widget<DashboardScreen>(find.byType(DashboardScreen))
            .searchViewModel!;
        for (var i = 0; i < 60 && !vm.canSearch; i++) {
          await Future<void>.delayed(const Duration(milliseconds: 100));
          await tester.pumpAndSettle();
        }
        expect(vm.canSearch, true);
        await tester.tap(field);
        await tester.pumpAndSettle();
        await tester.enterText(field, text);
        await tester.testTextInput.receiveAction(TextInputAction.search);
        for (var i = 0; i < 100; i++) {
          await Future<void>.delayed(const Duration(milliseconds: 100));
          await tester.pumpAndSettle();
          if (i >= 5 &&
              !vm.state.loading &&
              vm.state.filter.query == text.trim()) {
            break;
          }
        }
        expect(vm.state.filter.query, text.trim());
        expect(vm.state.loading, false);
        expect(vm.state.message, isNull);
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pumpAndSettle();
      }

      final first = (fixture['animals'] as List).first as Map;
      await query(fixture['name'] as String);
      await waitFor(find.text('#${first['animal_code']}'));
      expect(
        tester
            .widget<DashboardScreen>(find.byType(DashboardScreen))
            .searchViewModel!
            .state
            .total,
        2,
      );
      await tester.tap(find.text('Lista'));
      await tester.pumpAndSettle();
      await query(' #${(first['animal_code'] as String).toLowerCase()} ');
      expect(
        tester
            .widget<DashboardScreen>(find.byType(DashboardScreen))
            .searchViewModel!
            .state
            .total,
        1,
      );
      await tester.tap(find.text('Filtros'));
      await tester.pumpAndSettle();
      Future<void> option(String label, String value) async {
        await tester.ensureVisible(
          find
              .ancestor(
                of: find.text(label),
                matching: find.byWidgetPredicate(
                  (w) => w is DropdownButtonFormField,
                ),
              )
              .first,
        );
        await tester.tap(
          find
              .ancestor(
                of: find.text(label),
                matching: find.byWidgetPredicate(
                  (w) => w is DropdownButtonFormField,
                ),
              )
              .first,
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text(value).last);
        await tester.pumpAndSettle();
      }

      await option('Espécie', 'Cachorro');
      await option('Sexo', 'Fêmea');
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Cor'),
        'preto',
      );
      await option('Porte', 'Pequeno');
      await option('Situação', 'Quarentena');
      await tester.ensureVisible(find.text('Aplicar filtros'));
      await tester.tap(find.text('Aplicar filtros'));
      await tester.pumpAndSettle();
      await waitFor(find.text('#${first['animal_code']}'));
      final search = tester
          .widget<DashboardScreen>(find.byType(DashboardScreen))
          .searchViewModel!;
      expect(search.chips.length, 5);
      search.clearAll();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Calendário'));
      await tester.pumpAndSettle();
      await waitFor(find.byType(MedicationCalendarPanel));
      final calendar = tester
          .widget<DashboardScreen>(find.byType(DashboardScreen))
          .calendarViewModel!;
      final day = calendar.state.selectedDay;
      await query(first['animal_code'] as String);
      await waitFor(find.text('#${first['animal_code']}'));
      expect(search.state.total, 1);
      await tester.ensureVisible(find.text('Abrir ficha ›'));
      await tester.tap(find.text('Abrir ficha ›'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Voltar').first);
      await tester.pumpAndSettle();
      await waitFor(find.byType(DashboardScreen));
      expect(search.state.filter.query, first['animal_code']);
      search.clearAll();
      await tester.pumpAndSettle();
      expect(calendar.state.selectedDay, day);
      await tester.tap(find.byTooltip('Sair da conta'));
      await tester.pumpAndSettle();
      expect(find.byType(DashboardScreen), findsNothing);
    },
  );
}
