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
    'Android saves fixed and interval treatments from the protected animal form',
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
