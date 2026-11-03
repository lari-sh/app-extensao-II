import 'package:abrigo_dos_anjos/ui/features/animals/views/animal_editor_screen.dart';
import 'package:abrigo_dos_anjos/domain/models/animal.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:abrigo_dos_anjos/ui/features/animals/views/catalog_screen.dart';
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
                  Uri.parse(
                    '${const String.fromEnvironment('SEARCH_CONTROL_URL', defaultValue: 'http://10.0.2.2:58766')}/fixtures',
                  ),
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
      final add = find.byKey(const ValueKey('addAnimal'));
      await waitFor(add);
      await tester.tap(add);
      await waitFor(find.byType(AnimalEditorScreen));
      expect(find.text('Cadastrar animal'), findsOneWidget);
      await tester.tap(find.byTooltip('Voltar').first);
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
        final previousQuery = vm.state.filter.query;
        await tester.enterText(field, text);
        await tester.pump(const Duration(milliseconds: 800));
        expect(vm.state.filter.query, previousQuery);
        expect(tester.widget<TextField>(field).enabled, isTrue);
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
      await tester.pumpAndSettle();
      expect(find.byType(MedicationCalendarPanel), findsOneWidget);
      expect(find.text('#${first['animal_code']}'), findsNothing);
      expect(calendar.state.selectedDay, day);
      for (var i = 0; i < 80 && calendar.state.loadingDay; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
        await tester.pumpAndSettle();
      }
      expect(calendar.state.items, isNotEmpty);
      expect(
        calendar.state.items.every((a) => a.animalId == first['id']),
        true,
      );
      expect(find.text('Ilustrativa A'), findsWidgets);
      expect(find.text('Ilustrativa B'), findsNothing);
      search.clearAll();
      await tester.pumpAndSettle();
      expect(calendar.state.selectedDay, day);
      await tester.tap(find.text('Kanban'));
      await tester.pumpAndSettle();
      await query(first['animal_code'] as String);
      await waitFor(find.byKey(ValueKey('clinicalSummary-${first['id']}')));
      await tester.tap(find.byKey(ValueKey('clinicalSummary-${first['id']}')));
      await tester.pumpAndSettle();
      await waitFor(find.byType(AnimalEditorScreen));
      final editor = tester.widget<AnimalEditorScreen>(
        find.byType(AnimalEditorScreen),
      );
      for (
        var i = 0;
        i < 100 && !editor.managementViewModel!.canManageFocused;
        i++
      ) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
        await tester.pumpAndSettle();
      }
      expect(editor.managementViewModel!.canManageFocused, true);
      final status = find.byWidgetPredicate(
        (w) => w is DropdownButtonFormField<AnimalStatus>,
      );
      await tester.ensureVisible(status);
      await tester.tap(status);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Em tratamento').last);
      await tester.pumpAndSettle();
      for (
        var i = 0;
        i < 100 &&
            editor.managementViewModel!.focusedStatus != AnimalStatus.treatment;
        i++
      ) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
        await tester.pumpAndSettle();
      }
      expect(editor.managementViewModel!.focusedStatus, AnimalStatus.treatment);
      final verification =
          await Supabase.instance.client.rpc(
                'get_managed_animal',
                params: {'p_animal_id': first['id']},
              )
              as Map;
      expect((verification['animal'] as Map)['status'], 'treatment');
      await tester.tap(find.byTooltip('Voltar').first);
      await tester.pumpAndSettle();
      await waitFor(find.byType(DashboardScreen));
      expect(search.state.filter.query, first['animal_code']);
      search.clearAll();
      await tester.pumpAndSettle();
      // Publish only this controller's disposable animals for the public checks.
      for (final animal in fixture['animals'] as List) {
        await Supabase.instance.client.rpc(
          'set_animal_publication',
          params: {
            'p_animal_id': (animal as Map)['id'],
            'p_is_published': true,
            'p_operation_key': 'public${DateTime.now().microsecondsSinceEpoch}'
                .padRight(32, '_'),
          },
        );
      }
      await tester.tap(find.byTooltip('Administração'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sair da conta'));
      await tester.pumpAndSettle();
      expect(find.byType(DashboardScreen), findsNothing);
      await waitFor(find.text('Quero Adotar (Visitante)'));
      await tester.tap(find.text('Quero Adotar (Visitante)'));
      await waitFor(find.byType(CatalogScreen));
      final catalog = tester
          .widget<CatalogScreen>(find.byType(CatalogScreen))
          .viewModel;
      for (var i = 0; i < 100 && catalog.state.busy; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
        await tester.pumpAndSettle();
      }
      final publicField = find.byKey(const ValueKey('catalogSearch'));
      for (final scenario in [
        ('gato macho', AnimalSpecies.cat, AnimalSex.male, 1),
        ('gata femea', AnimalSpecies.cat, AnimalSex.female, 0),
        ('gato femea', AnimalSpecies.cat, AnimalSex.female, 0),
        ('cachorro femea', AnimalSpecies.dog, AnimalSex.female, 1),
      ]) {
        final previous = catalog.state.query;
        await tester.ensureVisible(publicField);
        await tester.tap(publicField);
        await tester.pumpAndSettle();
        await tester.enterText(
          publicField,
          '${fixture['name']} ${scenario.$1}',
        );
        await Future<void>.delayed(const Duration(milliseconds: 800));
        await tester.pumpAndSettle();
        expect(catalog.state.query, previous);
        expect(catalog.searchInput, '${fixture['name']} ${scenario.$1}');
        expect(
          tester.widget<TextField>(publicField).controller!.text,
          catalog.searchInput,
        );
        await tester.testTextInput.receiveAction(TextInputAction.search);
        for (var i = 0; i < 100; i++) {
          await Future<void>.delayed(const Duration(milliseconds: 100));
          await tester.pumpAndSettle();
          if (!catalog.state.busy &&
              catalog.state.query.species == scenario.$2 &&
              catalog.state.query.sex == scenario.$3) {
            break;
          }
        }
        expect(catalog.state.message, isNull);
        expect(catalog.state.query.name, fixture['name']);
        expect(catalog.state.query.species, scenario.$2);
        expect(catalog.state.query.sex, scenario.$3);
        expect(catalog.state.total, scenario.$4);
        expect(catalog.state.items.length, scenario.$4);
      }
    },
  );
}
