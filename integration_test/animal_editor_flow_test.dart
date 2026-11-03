import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:integration_test/integration_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:abrigo_dos_anjos/app/bootstrap.dart';
import 'package:abrigo_dos_anjos/ui/features/animals/views/animal_editor_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'Android creates a private animal and edits persisted data visible in a second session',
    (tester) async {
      const url = String.fromEnvironment('SUPABASE_URL');
      expect(Uri.parse(url).host, anyOf('10.0.2.2', '127.0.0.1'));
      final fixtureHost = Uri.parse(url).host;
      final response = await http.get(
        Uri.parse('http://$fixtureHost:58763/fixture-password'),
      );
      final password = (jsonDecode(response.body) as Map)['password'] as String;
      final name = 'Validação Android ${DateTime.now().millisecondsSinceEpoch}';
      final second = SupabaseClient(
        url,
        const String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY'),
        authOptions: const AuthClientOptions(autoRefreshToken: false),
      );
      try {
        await tester.pumpWidget(await bootstrapApplication());
        await tester.pumpAndSettle();
        final entry = find.text('Acesso Voluntário / Funcionário');
        await tester.ensureVisible(entry);
        await tester.tap(entry);
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(const ValueKey('loginEmail')),
          'fixture-staff@example.test',
        );
        await tester.enterText(
          find.byKey(const ValueKey('loginPassword')),
          password,
        );
        final login = find.widgetWithText(FilledButton, 'Entrar no painel');
        await tester.ensureVisible(login);
        await tester.tap(login);
        await tester.pumpAndSettle(const Duration(milliseconds: 300));
        await tester.tap(find.text('Animais do abrigo'));
        await tester.pumpAndSettle(const Duration(milliseconds: 300));
        await tester.tap(find.byTooltip('Administração'));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('addAnimal')));
        await tester.pumpAndSettle();
        Future<void> text(
          String key,
          String value, {
          bool upwards = false,
        }) async {
          final field = find.byKey(ValueKey(key));
          for (var i = 0; i < 30 && field.evaluate().isEmpty; i++) {
            await tester.drag(
              find.byType(Scrollable).first,
              Offset(0, upwards ? 450 : -450),
            );
            await tester.pumpAndSettle();
          }
          await tester.ensureVisible(field);
          await tester.pumpAndSettle();
          await tester.enterText(field, value);
        }

        await text('animalName', name);
        await text('animalAge', '3 anos');
        for (final entry in {
          'animalSpecies': 'Cachorro',
          'animalSex': 'Fêmea',
          'animalSize': 'Médio',
        }.entries) {
          FocusManager.instance.primaryFocus?.unfocus();
          await tester.pumpAndSettle();
          final field = find.byKey(ValueKey(entry.key));
          await tester.ensureVisible(field);
          await tester.pumpAndSettle();
          await tester.tap(field.hitTestable());
          await tester.pumpAndSettle();
          await tester.tap(find.text(entry.value).last);
          await tester.pumpAndSettle();
        }
        await text('animalNotes', 'Nota interna Android');
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pumpAndSettle();
        await text('animalWeight', '4,25');
        await text('animalColor', 'Branca');
        await text('animalTemperament', 'Calma');
        await text('animalLastDewormedOn', '29/02/2024');
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(
          find.text('Adicionar vacina'),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.tap(find.text('Adicionar vacina'));
        await tester.pumpAndSettle();
        await text('vaccinationDate0', '29/02/2024');
        await text('vaccineType0', 'V4');
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pumpAndSettle();
        final care = find.text('Adicionar cuidado');
        await tester.scrollUntilVisible(
          care,
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.tap(care);
        await tester.pumpAndSettle();
        await text('careDescription0', 'Vacinação registrada no teste');
        Future<void> save() async {
          FocusManager.instance.primaryFocus?.unfocus();
          await tester.pumpAndSettle();
          final button = find.text('Salvar animal');
          for (var i = 0; i < 30 && button.evaluate().isEmpty; i++) {
            await tester.drag(
              find.byType(Scrollable).first,
              const Offset(0, -450),
            );
            await tester.pumpAndSettle();
          }
          await tester.ensureVisible(button);
          await tester.pumpAndSettle();
          await tester.tap(button);
          await tester.pumpAndSettle(const Duration(milliseconds: 300));
          expect(find.text('Animal salvo com sucesso.'), findsOneWidget);
        }

        await save();
        final editor = tester.widget<AnimalEditorScreen>(
          find.byType(AnimalEditorScreen),
        );
        final id = editor.viewModel.state.savedId!;
        await second.auth.signInWithPassword(
          email: 'fixture-staff@example.test',
          password: password,
        );
        final saved = await second.rpc(
          'get_managed_animal',
          params: {'p_animal_id': id},
        );
        expect(saved['animal']['name'], name);
        expect(saved['animal']['is_published'], false);
        expect(saved['animal']['weight_kg'], 4.25);
        expect(saved['animal']['color'], 'Branca');
        expect(saved['animal']['last_dewormed_on'], '2024-02-29');
        expect(saved['animal']['temperament'], 'Calma');
        expect(saved['animal']['vaccinations'], [
          {'applied_on': '2024-02-29', 'vaccine_type': 'V4'},
        ]);
        expect(saved['clinical_notes'], 'Nota interna Android');
        expect((saved['care_records'] as List).length, 1);
        await text('animalName', '$name editado', upwards: true);
        await tester.pumpAndSettle();
        expect(editor.viewModel.state.draft.name, '$name editado');
        await save();
        final edited = await second.rpc(
          'get_managed_animal',
          params: {'p_animal_id': id},
        );
        expect(edited['animal']['name'], '$name editado');
        await second.rpc(
          'set_animal_publication',
          params: {
            'p_animal_id': id,
            'p_is_published': true,
            'p_operation_key': 'v${DateTime.now().microsecondsSinceEpoch}'
                .padRight(32, 'v'),
          },
        );
        final visitor = SupabaseClient(
          url,
          const String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY'),
        );
        try {
          final public = await visitor
              .from('animals')
              .select()
              .eq('id', id)
              .single();
          expect(public['vaccinations'], [
            {'applied_on': '2024-02-29', 'vaccine_type': 'V4'},
          ]);
          expect(public.containsKey('clinical_notes'), false);
          expect(public['weight_kg'], 4.25);
        } finally {
          await visitor.dispose();
        }
        final appNavigator = Navigator.of(
          tester.element(find.byType(AnimalEditorScreen)),
        );
        appNavigator.pushNamed('/detail', arguments: id);
        await tester.pumpAndSettle();
        final sheet = find.byKey(const ValueKey('publicAnimalSheet'));
        expect(sheet, findsOneWidget);
        expect(
          find.descendant(of: sheet, matching: find.text('29/02/2024 • V4')),
          findsOneWidget,
        );
        expect(
          find.descendant(of: sheet, matching: find.text('Branca')),
          findsOneWidget,
        );
        expect(
          find.descendant(of: sheet, matching: find.text('4,25 kg')),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: sheet,
            matching: find.text('Nota interna Android'),
          ),
          findsNothing,
        );
        await tester.tap(find.byTooltip('Fechar detalhes'));
        await tester.pumpAndSettle();
        await text('animalLastDewormedOn', '', upwards: true);
        await text('animalWeight', '', upwards: true);
        await save();
        final cleared = await second.rpc(
          'get_managed_animal',
          params: {'p_animal_id': id},
        );
        expect(cleared['animal']['last_dewormed_on'], isNull);
        expect(cleared['animal']['weight_kg'], isNull);
        expect(cleared['clinical_notes'], 'Nota interna Android');
        // Close and reopen the route to prove the form loads persisted data.
        await tester.tap(find.byTooltip('Voltar'));
        await tester.pumpAndSettle(const Duration(milliseconds: 300));
        appNavigator.pushNamed('/animal-editor', arguments: id);
        await tester.pumpAndSettle(const Duration(milliseconds: 300));
        // Navigation settling does not await an HTTP read or access verification.
        for (var i = 0; i < 100; i++) {
          final matches = find.byType(AnimalEditorScreen);
          if (matches.evaluate().length == 1) {
            final screen = tester.widget<AnimalEditorScreen>(matches);
            if (screen.viewModel.canEdit &&
                screen.viewModel.state.draft.name == '$name editado') {
              break;
            }
          }
          await tester.pump(const Duration(milliseconds: 100));
          await Future<void>.delayed(const Duration(milliseconds: 100));
        }
        expect(find.text('$name editado'), findsOneWidget);
      } finally {
        await second.auth.signOut(scope: SignOutScope.local);
        await second.dispose();
        await Supabase.instance.client.auth.signOut();
        await tester.pumpAndSettle();
      }
    },
  );
}
