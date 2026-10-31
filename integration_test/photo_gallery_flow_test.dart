import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:integration_test/integration_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:abrigo_dos_anjos/app/bootstrap.dart';
import 'package:abrigo_dos_anjos/utils/operation_id.dart';
import 'package:abrigo_dos_anjos/ui/features/photos/views/photo_upload_panel.dart';
import 'package:abrigo_dos_anjos/ui/features/animals/views/animal_editor_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'native gallery cancellation, explicit upload and replacement preserve editor draft',
    (tester) async {
      expect(
        Uri.parse(const String.fromEnvironment('SUPABASE_URL')).host,
        '10.0.2.2',
      );
      final response = await http.get(
        Uri.parse('http://10.0.2.2:58763/fixture-password'),
      );
      final password = (jsonDecode(response.body) as Map)['password'] as String;
      Future<void> reveal(Finder target) async {
        for (var i = 0; i < 30 && target.evaluate().isEmpty; i++) {
          await tester.drag(
            find.byType(Scrollable).first,
            const Offset(0, -450),
          );
          await tester.pumpAndSettle();
        }
        await tester.ensureVisible(target);
        await tester.pumpAndSettle();
      }

      await tester.pumpWidget(await bootstrapApplication());
      await tester.pumpAndSettle();
      await reveal(find.text('Acesso Voluntário / Funcionário'));
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
      await reveal(find.widgetWithText(FilledButton, 'Entrar no painel'));
      await tester.tap(find.widgetWithText(FilledButton, 'Entrar no painel'));
      await tester.pumpAndSettle();
      expect(find.text('Acesso autorizado'), findsOneWidget);
      final client = Supabase.instance.client;
      final saved = await client.rpc(
        'save_animal',
        params: {
          'p_operation_key': OperationId().value,
          'p_payload': {
            'name':
                'Validação Android foto ${DateTime.now().millisecondsSinceEpoch}',
            'species': 'dog',
            'sex': 'female',
            'size': 'medium',
            'approximate_age': '2 anos',
            'clinical_notes': 'Nota persistida',
          },
        },
      );
      final id = saved['animal']['id'] as String;
      Navigator.of(
        tester.element(find.text('Acesso autorizado')),
      ).pushNamed('/animal-editor', arguments: id);
      await tester.pumpAndSettle();
      final notes = find.byKey(const ValueKey('animalNotes'));
      await reveal(notes);
      await tester.enterText(notes, 'Rascunho de foto preservado');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await reveal(find.text('Selecionar foto'));
      final photo = tester
          .widget<PhotoUploadPanel>(find.byType(PhotoUploadPanel))
          .viewModel;
      final editor = tester
          .widget<AnimalEditorScreen>(find.byType(AnimalEditorScreen))
          .viewModel;
      Future<void> settled() async {
        for (var i = 0; i < 150 && photo.state.busy; i++) {
          await tester.pump(const Duration(milliseconds: 100));
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 50)),
          );
        }
        await tester.pumpAndSettle();
        expect(photo.state.busy, isFalse);
      }

      debugPrint('NATIVE_PICKER: cancel');
      await tester.tap(find.text('Selecionar foto'));
      await tester.pumpAndSettle();
      await settled();
      expect(photo.state.candidate, isNull);
      expect(editor.state.draft.clinicalNotes, 'Rascunho de foto preservado');
      String? firstId;
      for (var i = 0; i < 2; i++) {
        await reveal(find.text('Selecionar foto'));
        debugPrint('NATIVE_PICKER: select $i');
        await tester.tap(find.text('Selecionar foto'));
        await tester.pumpAndSettle();
        await settled();
        expect(photo.state.candidate, isNotNull);
        expect(photo.state.photoId, firstId);
        await reveal(find.text('Confirmar envio da foto'));
        await tester.tap(find.text('Confirmar envio da foto'));
        await tester.pumpAndSettle();
        await settled();
        expect(photo.state.message, 'Foto enviada com sucesso.');
        expect(photo.state.image, isNotNull);
        expect(photo.state.photoId, isNotNull);
        if (i == 0) {
          firstId = photo.state.photoId;
        } else {
          expect(photo.state.photoId, isNot(firstId));
        }
        final remote = await client.rpc(
          'get_managed_animal',
          params: {'p_animal_id': id},
        );
        expect(remote['animal']['primary_photo_id'], photo.state.photoId);
        expect(remote['clinical_notes'], 'Nota persistida');
        expect(editor.state.draft.clinicalNotes, 'Rascunho de foto preservado');
      }
      await client.auth.signOut();
      await tester.pumpAndSettle();
      expect(find.byType(PhotoUploadPanel), findsNothing);
    },
  );
}
