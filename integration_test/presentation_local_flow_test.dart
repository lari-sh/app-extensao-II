// Manual local presentation journey; never targets a shared/production backend.
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:abrigo_dos_anjos/app/bootstrap.dart';
import 'package:abrigo_dos_anjos/ui/features/animals/views/animal_detail_screen.dart';
import 'package:abrigo_dos_anjos/ui/features/medications/views/medication_application_details_sheet.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'local examples show real JPEGs, statuses and medication audit',
    (tester) async {
      const url = String.fromEnvironment('SUPABASE_URL');
      expect(url, 'http://127.0.0.1:54321');
      final response = await http.get(
        Uri.parse('http://127.0.0.1:58763/fixture-password'),
      );
      final password = (jsonDecode(response.body) as Map)['password'] as String;
      Future<void> waitFor(Finder finder) async {
        for (
          var attempt = 0;
          attempt < 100 && finder.evaluate().isEmpty;
          attempt++
        ) {
          await tester.pumpAndSettle();
          await Future<void>.delayed(const Duration(milliseconds: 100));
        }
        expect(finder, findsWidgets);
      }

      await tester.pumpWidget(await bootstrapApplication());
      final client = Supabase.instance.client;
      await client.auth.signOut(scope: SignOutScope.local);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Quero Adotar (Visitante)'));
      await waitFor(find.text('8 animais encontrados'));
      await tester.tap(find.text('Amora').first);
      await waitFor(find.byType(AnimalDetailScreen));
      final details = tester.widget<AnimalDetailScreen>(
        find.byType(AnimalDetailScreen),
      );
      for (var i = 0; i < 100 && details.viewModel.state.photo == null; i++) {
        await tester.pumpAndSettle();
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
      expect(details.viewModel.state.photo!.length, greaterThan(1000));
      expect(details.viewModel.state.canAdopt, isFalse);
      expect(
        details.viewModel.state.publicInformation['Vacinas'],
        'V8 • 10/09/2026\nAntirrábica • 24/09/2026',
      );
      expect(
        details.viewModel.state.publicInformation['Peso'],
        contains('12,4'),
      );
      expect(find.bySemanticsLabel('Foto de Amora'), findsOneWidget);
      await tester.tap(find.byTooltip('Fechar detalhes'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Início'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Acesso Voluntário / Funcionário'));
      await waitFor(find.byKey(const ValueKey('loginEmail')));
      await tester.enterText(
        find.byKey(const ValueKey('loginEmail')),
        'fixture-admin@example.test',
      );
      await tester.enterText(
        find.byKey(const ValueKey('loginPassword')),
        password,
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await waitFor(find.text('Animais do abrigo'));
      await tester.tap(find.text('Animais do abrigo'));
      await waitFor(find.text('Total: 8 animais'));
      expect(find.text('Em tratamento · 3'), findsOneWidget);
      expect(find.text('Quarentena · 1'), findsOneWidget);
      final now = DateTime.now().toUtc();
      final month =
          await client.rpc(
                'get_medication_calendar_month',
                params: {
                  'p_month':
                      '${now.year}-${now.month.toString().padLeft(2, '0')}',
                },
              )
              as Map;
      final day =
          await client.rpc(
                'list_medication_day',
                params: {'p_day': month['shelter_today'], 'p_cursor': null},
              )
              as Map;
      final application = (day['items'] as List).cast<Map>().firstWhere(
        (a) =>
            a['animal_name'] == 'Amora' &&
            a['state'] == 'pending' &&
            a['medication_name'] == 'Cuidados simulados — Amora' &&
            DateTime.parse(
              a['scheduled_at'] as String,
            ).isBefore(DateTime.parse(month['server_now'] as String)),
      );
      final id = application['id'] as String;
      await tester.tap(find.text('Calendário'));
      await tester.pumpAndSettle();
      final calendarScroll = find
          .descendant(
            of: find.byKey(const ValueKey('medicationCalendarScroll')),
            matching: find.byType(Scrollable),
          )
          .first;
      final card = find.byKey(ValueKey('medicationApplication-$id'));
      await tester.scrollUntilVisible(card, 250, scrollable: calendarScroll);
      await tester.pumpAndSettle();
      await tester.tap(card);
      await waitFor(find.text('Detalhes da aplicação'));
      await tester.tap(find.text('Marcar como aplicada'));
      await tester.pumpAndSettle();
      final sheet = tester.widget<MedicationApplicationDetailsSheet>(
        find.byType(MedicationApplicationDetailsSheet),
      );
      for (
        var i = 0;
        i < 100 && sheet.viewModel.state.application?.performedAt == null;
        i++
      ) {
        await tester.pumpAndSettle();
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
      expect(
        sheet.viewModel.state.application!.performedBy,
        client.auth.currentUser!.id,
      );
      expect(sheet.viewModel.state.application!.performedAt, isNotNull);
      final scroll = find
          .descendant(
            of: find.byKey(const ValueKey('medicationApplicationScroll')),
            matching: find.byType(Scrollable),
          )
          .first;
      await tester.scrollUntilVisible(
        find.text('Corrigir registro de aplicação'),
        200,
        scrollable: scroll,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Corrigir registro de aplicação'));
      await tester.pumpAndSettle();
      final reason = find.byKey(const ValueKey('medicationCorrectionReason'));
      await tester.ensureVisible(reason);
      await tester.pumpAndSettle();
      await tester.enterText(
        reason,
        'Demonstração autorizada: desfazer marcação simulada para novos testes.',
      );
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Confirmar correção'),
        140,
        scrollable: scroll,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirmar correção'));
      await tester.pumpAndSettle();
      final history =
          await client.rpc(
                'get_medication_application_history',
                params: {'p_application_id': id, 'p_cursor': null},
              )
              as Map;
      expect((history['items'] as List).length, greaterThanOrEqualTo(2));
      expect(tester.takeException(), isNull);
    },
    skip: !const bool.fromEnvironment('LOCAL_PRESENTATION_TEST'),
  );
}
