import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/ui/features/photos/views/photo_upload_panel.dart';
import 'package:abrigo_dos_anjos/ui/features/photos/view_models/photo_upload_view_model.dart';
import 'package:abrigo_dos_anjos/ui/features/animals/views/animal_editor_screen.dart';
import 'package:abrigo_dos_anjos/ui/features/animals/view_models/animal_editor_view_model.dart';
import 'package:abrigo_dos_anjos/domain/models/photo_candidate.dart';
import 'package:abrigo_dos_anjos/domain/models/photo_content.dart';
import 'package:abrigo_dos_anjos/domain/models/photo_upload_state.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import 'package:abrigo_dos_anjos/utils/app_failure.dart';
import '../../../../support/fakes/fake_photo_repository.dart';
import '../../../../support/fakes/fake_animals_repository.dart';
import '../../../../support/public_fixtures.dart';

final bytes = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR4nGM4Kqv1HwAEwwIMevLbSwAAAABJRU5ErkJggg==',
);
void main() {
  testWidgets(
    'select and explicitly upload, preserve old photo on failure then show confirmed image',
    (tester) async {
      var fail = true;
      final repo = FakePhotoRepository()
        ..handler = (method, _) async {
          if (method == 'pickFromGallery') {
            return Success<PhotoCandidate?>(
              PhotoCandidate(bytes: bytes, mime: 'image/png'),
            );
          }
          if (method == 'uploadPrimary') {
            return fail
                ? Failure<PhotoUploadState>(AppFailure(FailureCode.validation))
                : const Success(
                    PhotoUploadState(
                      jobId: 'job',
                      status: PhotoJobStatus.attached,
                      photoId: 'new',
                    ),
                  );
          }
          return Success(PhotoContent(bytes: bytes, mime: 'image/png'));
        };
      final vm = PhotoUploadViewModel(repo);
      addTearDown(vm.dispose);
      await vm.bindAnimal(fixtureId(1), 'old');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: PhotoUploadPanel(viewModel: vm)),
          ),
        ),
      );
      await tester.tap(find.text('Selecionar foto'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('selectedAnimalPhoto')), findsOneWidget);
      expect(repo.calls.where((c) => c.method == 'uploadPrimary'), isEmpty);
      await tester.ensureVisible(find.text('Confirmar envio da foto'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirmar envio da foto'));
      await tester.pumpAndSettle();
      expect(vm.state.photoId, 'old');
      expect(find.byKey(const ValueKey('currentAnimalPhoto')), findsOneWidget);
      fail = false;
      await tester.tap(find.text('Confirmar envio da foto'));
      await tester.pumpAndSettle();
      expect(vm.state.photoId, 'new');
      expect(find.text('Foto enviada com sucesso.'), findsOneWidget);
    },
  );
  testWidgets(
    'permission denial in editor preserves draft and photo with zero uploads',
    (tester) async {
      final repo = FakePhotoRepository()
        ..handler = (method, _) async => method == 'readPrimary'
            ? Success(PhotoContent(bytes: bytes, mime: 'image/png'))
            : Failure<PhotoCandidate?>(
                AppFailure(FailureCode.permissionDenied),
              );
      final photo = PhotoUploadViewModel(repo);
      addTearDown(photo.dispose);
      await photo.bindAnimal(fixtureId(1), 'old');
      final editor = AnimalEditorViewModel(FakeAnimalsRepository());
      addTearDown(editor.dispose);
      editor.setName('Rascunho preservado');
      await tester.pumpWidget(
        MaterialApp(
          home: AnimalEditorScreen(viewModel: editor, photoViewModel: photo),
        ),
      );
      final select = find.text('Selecionar foto');
      for (var i = 0; i < 20 && select.evaluate().isEmpty; i++) {
        await tester.drag(find.byType(Scrollable).first, const Offset(0, -450));
        await tester.pumpAndSettle();
      }
      await tester.ensureVisible(select);
      await tester.pumpAndSettle();
      await tester.tap(select);
      await tester.pumpAndSettle();
      expect(photo.state.message, contains('permissão'));
      expect(photo.state.busy, false);
      expect(photo.state.photoId, 'old');
      expect(editor.state.draft.name, 'Rascunho preservado');
      expect(repo.calls.where((c) => c.method == 'uploadPrimary'), isEmpty);
    },
  );
}
