import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:integration_test/integration_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:abrigo_dos_anjos/app/bootstrap.dart';
import 'package:abrigo_dos_anjos/domain/models/animal.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'Android dashboard confirms status and publication visible in another session',
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
          '000 Validação Android painel ${DateTime.now().millisecondsSinceEpoch}';
      final created =
          await second.rpc(
                'save_animal',
                params: {
                  'p_operation_key': 'p${DateTime.now().microsecondsSinceEpoch}'
                      .padRight(32, 'p'),
                  'p_payload': {
                    'name': name,
                    'species': 'dog',
                    'sex': 'female',
                    'size': 'small',
                    'approximate_age': '2 anos',
                    'clinical_notes': 'Nota protegida',
                  },
                },
              )
              as Map;
      final id = (created['animal'] as Map)['id'] as String;
      try {
        await tester.pumpWidget(await bootstrapApplication());
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
        await tester.tap(find.text('Entrar no painel'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Animais do abrigo'));
        await tester.pumpAndSettle();
        expect(find.text('Olá, equipe'), findsOneWidget);
        await tester.tap(find.text('Lista'));
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('Ações de $name'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Mover para Em tratamento'));
        await tester.pumpAndSettle();
        var row =
            await second.rpc('get_managed_animal', params: {'p_animal_id': id})
                as Map;
        expect((row['animal'] as Map)['status'], 'treatment');
        expect(row['clinical_notes'], 'Nota protegida');
        // Treatment section can be below the first page of available animals.
        final menu = find.byTooltip('Ações de $name');
        for (var i = 0; i < 30 && menu.evaluate().isEmpty; i++) {
          await tester.drag(
            find.byType(Scrollable).last,
            const Offset(0, -500),
          );
          await tester.pumpAndSettle();
        }
        await tester.ensureVisible(menu);
        await tester.tap(menu);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Publicar no catálogo'));
        await tester.pumpAndSettle();
        row =
            await second.rpc('get_managed_animal', params: {'p_animal_id': id})
                as Map;
        expect((row['animal'] as Map)['is_published'], true);
        final public = SupabaseClient(
          url,
          const String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY'),
          authOptions: const AuthClientOptions(autoRefreshToken: false),
        );
        try {
          expect(
            (await public.from('animals').select('id').eq('id', id)).length,
            1,
          );
        } finally {
          await public.dispose();
        }
        await tester.tap(find.byTooltip('Ações de $name'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Editar cadastro'));
        await tester.pumpAndSettle();
        final situation = find.byType(DropdownButtonFormField<AnimalStatus>);
        await tester.ensureVisible(situation);
        await tester.tap(situation);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Quarentena').last);
        await tester.pumpAndSettle();
        final publication = find.widgetWithText(
          SwitchListTile,
          'Publicado no catálogo',
        );
        await tester.ensureVisible(publication);
        await tester.tap(publication);
        await tester.pumpAndSettle();
        row =
            await second.rpc('get_managed_animal', params: {'p_animal_id': id})
                as Map;
        expect((row['animal'] as Map)['status'], 'quarantine');
        expect((row['animal'] as Map)['is_published'], false);
        expect(row['clinical_notes'], 'Nota protegida');
        expect(tester.takeException(), isNull);
      } finally {
        await second.auth.signOut();
        await second.dispose();
      }
    },
  );
}
