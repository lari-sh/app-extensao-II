import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:integration_test/integration_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:abrigo_dos_anjos/app/bootstrap.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'Android saves treatments and browses calendar month and daily agenda',
    (tester) async {
      const url = String.fromEnvironment('SUPABASE_URL');
      expect(Uri.parse(url).host, '10.0.2.2');
      final password =
          (jsonDecode(
                    (await http.get(
                      Uri.parse('http://10.0.2.2:58763/fixture-password'),
                    )).body,
                  )
                  as Map)['password']
              as String;
      final second = SupabaseClient(
        url,
        const String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY'),
        authOptions: const AuthClientOptions(autoRefreshToken: false),
      );
      await second.auth.signInWithPassword(
        email: 'fixture-staff@example.test',
        password: password,
      );
      final name =
          '000 Fixture calendario medicacao ${DateTime.now().microsecondsSinceEpoch}';
      String key(String prefix) =>
          '$prefix${DateTime.now().microsecondsSinceEpoch}'
              .padRight(32, prefix)
              .substring(0, 32);
      final animal =
          await second.rpc(
                'save_animal',
                params: {
                  'p_operation_key': key('a'),
                  'p_payload': {
                    'name': name,
                    'species': 'dog',
                    'sex': 'female',
                    'size': 'small',
                    'approximate_age': '2 anos',
                    'clinical_notes': 'Nota privada da jornada de medicação',
                  },
                },
              )
              as Map;
      final animalId = (animal['animal'] as Map)['id'] as String;
      try {
        await tester.pumpWidget(await bootstrapApplication());
        await tester.pumpAndSettle();
        await Supabase.instance.client.auth.signOut(scope: SignOutScope.local);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Acesso Voluntário / Funcionário'));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(const ValueKey('loginEmail')),
          'fixture-staff@example.test',
        );
        await tester.enterText(
          find.byKey(const ValueKey('loginPassword')),
          password,
        );
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Entrar no painel'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Entrar no painel'));
        await tester.pumpAndSettle();
        // Navigate through the real dashboard/editor; the fixture may be on a later page.
        await tester.tap(find.text('Animais do abrigo'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Lista'));
        await tester.pumpAndSettle();
        final menu = find.byTooltip('Ações de $name');
        for (var i = 0; i < 35 && menu.evaluate().isEmpty; i++) {
          final more = find.text('Carregar mais disponíveis');
          if (more.evaluate().isNotEmpty) {
            await tester.ensureVisible(more);
            await tester.tap(more);
          } else {
            await tester.drag(
              find.byType(Scrollable).last,
              const Offset(0, -500),
            );
          }
          await tester.pumpAndSettle();
        }
        await tester.ensureVisible(menu);
        await tester.tap(menu);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Editar cadastro'));
        await tester.pumpAndSettle();
        Future<void> openMedication() async {
          final add = find.text('Adicionar medicação');
          await tester.scrollUntilVisible(
            add,
            300,
            scrollable: find.byType(Scrollable).first,
          );
          await tester.pumpAndSettle();
          await tester.tap(add);
          await tester.pumpAndSettle();
          expect(find.text('Programar medicação'), findsOneWidget);
        }

        Future<void> enter(String key, String value) async {
          final field = find.byKey(ValueKey(key));
          final scroll = find
              .descendant(
                of: find.byKey(const ValueKey('medicationFormScroll')),
                matching: find.byType(Scrollable),
              )
              .first;
          await tester.scrollUntilVisible(field, 180, scrollable: scroll);
          await tester.pumpAndSettle();
          await tester.enterText(field, value);
          await tester.pumpAndSettle();
        }

        Future<void> save() async {
          FocusManager.instance.primaryFocus?.unfocus();
          await tester.pumpAndSettle();
          await tester.tap(find.text('Salvar programação'));
          await tester.pumpAndSettle();
          expect(find.text('Programar medicação'), findsNothing);
        }

        await openMedication();
        await enter('medicationName', 'Medicação Android fixos');
        await enter('medicationStartsOn', '01/11/2026');
        await enter('medicationEndsOn', '02/11/2026');
        await save();
        var page =
            await second.rpc(
                  'list_animal_medication_treatments',
                  params: {'p_animal_id': animalId, 'p_cursor': null},
                )
                as Map;
        final fixed = (page['items'] as List).single as Map;
        expect(fixed['fixed_times'], ['08:00', '20:00']);
        expect(
          (await second
                  .from('medication_applications')
                  .select('id')
                  .eq('treatment_id', fixed['id'] as String))
              .length,
          4,
        );
        await openMedication();
        await enter('medicationName', 'Medicação Android intervalo');
        await enter('medicationStartsOn', '01/11/2026');
        await enter('medicationEndsOn', '02/11/2026');
        await enter('medicationStartsTime', '20:00');
        final interval = find.text('Por intervalo');
        await tester.ensureVisible(interval);
        await tester.pumpAndSettle();
        await tester.tap(interval);
        await tester.pumpAndSettle();
        await save();
        page =
            await second.rpc(
                  'list_animal_medication_treatments',
                  params: {'p_animal_id': animalId, 'p_cursor': null},
                )
                as Map;
        expect(page['items'], hasLength(2));
        final elapsed = (page['items'] as List).cast<Map>().singleWhere(
          (item) => item['schedule_mode'] == 'interval',
        );
        expect(elapsed['interval_minutes'], 480);
        final applications = await second
            .from('medication_applications')
            .select('scheduled_at')
            .eq('treatment_id', elapsed['id'] as String);
        expect(applications, hasLength(4));
        expect(
          applications.any(
            (item) =>
                DateTime.parse(item['scheduled_at'] as String).toUtc() ==
                DateTime.utc(2026, 11, 2, 7),
          ),
          true,
        );
        final confirmed =
            await second.rpc(
                  'get_managed_animal',
                  params: {'p_animal_id': animalId},
                )
                as Map;
        expect(
          confirmed['clinical_notes'],
          'Nota privada da jornada de medicação',
        );
        expect(confirmed['animal']['is_published'], false);

        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        await tester.tap(find.text('Calendário'));
        await tester.pumpAndSettle();
        // The server civil date chooses the month; navigate by visible controls.
        final monthResponse =
            await second.rpc(
                  'get_medication_calendar_month',
                  params: {'p_month': '2026-11'},
                )
                as Map;
        final today = monthResponse['shelter_today'] as String;
        final target = DateTime(2026, 11);
        final current = DateTime.parse('$today 00:00:00');
        final delta =
            (target.year - current.year) * 12 + target.month - current.month;
        for (var step = 0; step < delta.abs(); step++) {
          await tester.tap(
            find.byTooltip(delta > 0 ? 'Próximo mês' : 'Mês anterior'),
          );
          await tester.pumpAndSettle();
        }
        expect(find.text('Novembro 2026'), findsOneWidget);
        final dayOne = find.byKey(const ValueKey('medicationDay-2026-11-01'));
        await tester.ensureVisible(dayOne);
        await tester.tap(dayOne);
        await tester.pumpAndSettle();
        final ownCard = find.text(name);
        await tester.scrollUntilVisible(
          ownCard.first,
          160,
          scrollable: find
              .descendant(
                of: find.byKey(const ValueKey('medicationCalendarScroll')),
                matching: find.byType(Scrollable),
              )
              .first,
        );
        expect(ownCard, findsWidgets);
        expect(find.text('Medicação Android fixos'), findsWidgets);
        // Change month then return and select the second day.
        await tester.drag(
          find.byKey(const ValueKey('medicationCalendarScroll')),
          const Offset(0, 700),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('Próximo mês'));
        await tester.pumpAndSettle();
        expect(find.text('Dezembro 2026'), findsOneWidget);
        await tester.tap(find.byTooltip('Mês anterior'));
        await tester.pumpAndSettle();
        final dayTwo = find.byKey(const ValueKey('medicationDay-2026-11-02'));
        await tester.ensureVisible(dayTwo);
        await tester.tap(dayTwo);
        await tester.pumpAndSettle();
        final dayPage =
            await second.rpc(
                  'list_medication_day',
                  params: {'p_day': '2026-11-02', 'p_cursor': null},
                )
                as Map;
        final ownApplications = (dayPage['items'] as List)
            .cast<Map>()
            .where((item) => item['animal_id'] == animalId)
            .toList();
        expect(ownApplications, hasLength(5));
        expect(
          ownApplications.map((item) => item['scheduled_local_time']),
          contains('04:00'),
        );
        expect(find.text('Segunda, 2 nov.'), findsOneWidget);
        await tester.scrollUntilVisible(
          find.text(name).first,
          160,
          scrollable: find
              .descendant(
                of: find.byKey(const ValueKey('medicationCalendarScroll')),
                matching: find.byType(Scrollable),
              )
              .first,
        );
        expect(find.text('Medicação Android intervalo'), findsWidgets);
        await tester.drag(
          find.byKey(const ValueKey('medicationCalendarScroll')),
          const Offset(0, 700),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Lista'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Kanban'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      } finally {
        await second.auth.signOut(scope: SignOutScope.local);
        await second.dispose();
        await Supabase.instance.client.auth.signOut(scope: SignOutScope.local);
        await tester.pumpAndSettle();
      }
    },
  );
}
