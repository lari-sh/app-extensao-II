import '../../../../support/presentation_fixtures.dart';
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
  for (final retry in [false, true]) {
    testWidgets(
      'recovered Amora JPEG handles uncertain upload and ${retry ? 'retry' : 'reconcile'}',
      (tester) async {
        final image = presentationPhoto('amora');
        var confirmed = false;
        var attempts = 0;
        final repo = FakePhotoRepository()
          ..handler = (method, args) async {
            if (method == 'readPrimary') {
              return Success(PhotoContent(bytes: image, mime: 'image/jpeg'));
            }
            if (method == 'uploadPrimary') {
              attempts++;
              if (attempts > 1) confirmed = true;
              if (!confirmed) {
                return Failure<PhotoUploadState>(
                  AppFailure(FailureCode.timeout),
                );
              }
            }
            if (confirmed) {
              return const Success(
                PhotoUploadState(
                  jobId: 'job',
                  status: PhotoJobStatus.attached,
                  photoId: 'new',
                ),
              );
            }
            return Failure<PhotoUploadState>(AppFailure(FailureCode.notFound));
          };
        var recovery = true;
        final vm = PhotoUploadViewModel(
          repo,
          delay: (_) async {},
          recoveryAvailable: () => recovery,
          recoverCandidate: (_) async {
            recovery = false;
            return Success<PhotoCandidate?>(
              PhotoCandidate(bytes: image, mime: 'image/jpeg'),
            );
          },
        );
        addTearDown(vm.dispose);
        await vm.bindAnimal(presentationAnimal('amora').id, 'old');
        vm.refreshRecovery();
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: PhotoUploadPanel(viewModel: vm),
              ),
            ),
          ),
        );
        await tester.ensureVisible(
          find.text('Usar foto recuperada neste animal'),
        );
        await tester.tap(find.text('Usar foto recuperada neste animal'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Confirmar envio da foto'));
        await tester.tap(find.text('Confirmar envio da foto'));
        await tester.pumpAndSettle();
        expect(vm.state.uncertain, isTrue);
        expect(vm.state.photoId, 'old');
        expect(vm.state.canRetry, isTrue);
        final action = retry
            ? 'Tentar enviar novamente'
            : 'Verificar envio da foto';
        if (!retry) confirmed = true;
        await tester.ensureVisible(find.text(action));
        await tester.pumpAndSettle();
        await tester.tap(find.text(action));
        await tester.pumpAndSettle();
        expect(vm.state.photoId, 'new');
        expect(vm.state.uncertain, isFalse);
        expect(vm.state.candidate, isNull);
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets('damaged uploaded preview falls back without breaking editor', (
    tester,
  ) async {
    final repo = FakePhotoRepository()
      ..handler = (_, _) async =>
          Success(PhotoContent(bytes: [1, 2, 3], mime: 'image/jpeg'));
    final vm = PhotoUploadViewModel(repo);
    addTearDown(vm.dispose);
    await vm.bindAnimal(presentationAnimal('mel').id, 'broken');
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: PhotoUploadPanel(viewModel: vm)),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Não foi possível visualizar a imagem.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

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
