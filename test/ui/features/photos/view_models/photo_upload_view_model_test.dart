import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/ui/features/photos/view_models/photo_upload_view_model.dart';
import 'package:abrigo_dos_anjos/domain/models/photo_candidate.dart';
import 'package:abrigo_dos_anjos/domain/models/photo_content.dart';
import 'package:abrigo_dos_anjos/domain/models/photo_upload_state.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import 'package:abrigo_dos_anjos/utils/app_failure.dart';
import '../../../../support/fakes/fake_photo_repository.dart';
import '../../../../support/public_fixtures.dart';

const candidate = PhotoCandidate(bytes: [255, 216, 255], mime: 'image/jpeg');
void main() {
  test(
    'logout and disposal during upload cannot publish late confirmation or bytes',
    () async {
      var allowed = true;
      final pending = Completer<Result<PhotoUploadState>>();
      final repo = FakePhotoRepository()
        ..handler = (method, _) async => method == 'pickFromGallery'
            ? const Success<PhotoCandidate?>(candidate)
            : pending.future;
      final vm = PhotoUploadViewModel(repo, isAuthorized: () => allowed);
      await vm.bindAnimal(fixtureId(1), null);
      await vm.pick();
      final work = vm.upload();
      await Future<void>.delayed(Duration.zero);
      allowed = false;
      vm.dispose();
      pending.complete(
        const Success(
          PhotoUploadState(
            jobId: 'job',
            status: PhotoJobStatus.attached,
            photoId: 'late',
          ),
        ),
      );
      await work;
      expect(vm.state.candidate, isNull);
      expect(vm.state.image, isNull);
      expect(vm.state.photoId, isNull);
      expect(repo.calls.where((c) => c.method == 'readPrimary'), isEmpty);
    },
  );
  test(
    'later pending job cancels retry eligibility from an earlier missing lookup',
    () async {
      var reads = 0;
      final repo = FakePhotoRepository()
        ..handler = (method, _) async {
          if (method == 'pickFromGallery') {
            return const Success<PhotoCandidate?>(candidate);
          }
          if (method == 'uploadPrimary') {
            return Failure<PhotoUploadState>(AppFailure(FailureCode.timeout));
          }
          if (reads++ == 0) {
            return Failure<PhotoUploadState>(AppFailure(FailureCode.notFound));
          }
          return const Success(
            PhotoUploadState(jobId: 'job', status: PhotoJobStatus.pending),
          );
        };
      final vm = PhotoUploadViewModel(repo, delay: (_) async {});
      addTearDown(vm.dispose);
      await vm.bindAnimal(fixtureId(1), null);
      await vm.pick();
      await vm.upload();
      expect(vm.state.uncertain, isTrue);
      expect(vm.state.canRetry, isFalse);
    },
  );
  test(
    'rebinding during native selection clears loading and discards late candidate',
    () async {
      final selected = Completer<Result<PhotoCandidate?>>();
      final repo = FakePhotoRepository()..handler = (_, _) => selected.future;
      final vm = PhotoUploadViewModel(repo);
      addTearDown(vm.dispose);
      await vm.bindAnimal(fixtureId(1), null);
      final work = vm.pick();
      await Future<void>.delayed(Duration.zero);
      await vm.bindAnimal(fixtureId(2), null);
      selected.complete(const Success<PhotoCandidate?>(candidate));
      await work;
      expect(vm.state.animalId, fixtureId(2));
      expect(vm.state.candidate, isNull);
      expect(vm.state.busy, isFalse);
    },
  );
  test(
    'cancel and denied permission end loading, preserve image and never upload',
    () async {
      final repo = FakePhotoRepository()
        ..handler = (method, _) async => method == 'readPrimary'
            ? Success(PhotoContent(bytes: [255, 216, 255], mime: 'image/jpeg'))
            : const Success<PhotoCandidate?>(null);
      final vm = PhotoUploadViewModel(repo);
      addTearDown(vm.dispose);
      await vm.bindAnimal(fixtureId(1), 'old');
      await vm.pick();
      expect(vm.state.image, isNotNull);
      expect(vm.state.candidate, isNull);
      repo.handler = (_, _) async =>
          Failure<PhotoCandidate?>(AppFailure(FailureCode.permissionDenied));
      await vm.pick();
      expect(vm.state.busy, isFalse);
      expect(vm.state.photoId, 'old');
      expect(vm.state.message, contains('permissão'));
      expect(repo.calls.where((c) => c.method == 'uploadPrimary'), isEmpty);
    },
  );
  test(
    'success swaps image only after confirmation and uses current photo on replay',
    () async {
      final completion = Completer<Result<PhotoUploadState>>();
      final repo = FakePhotoRepository()
        ..handler = (method, _) async {
          if (method == 'pickFromGallery') {
            return const Success<PhotoCandidate?>(candidate);
          }
          if (method == 'uploadPrimary') return completion.future;
          return Success(
            PhotoContent(bytes: [255, 216, 255], mime: 'image/jpeg'),
          );
        };
      final vm = PhotoUploadViewModel(repo);
      addTearDown(vm.dispose);
      await vm.bindAnimal(fixtureId(1), 'old');
      await vm.pick();
      final work = vm.upload();
      await Future<void>.delayed(Duration.zero);
      await vm.upload();
      expect(vm.state.photoId, 'old');
      expect(repo.calls.where((c) => c.method == 'uploadPrimary').length, 1);
      completion.complete(
        const Success(
          PhotoUploadState(
            jobId: 'job',
            status: PhotoJobStatus.attached,
            photoId: 'original',
            currentPhotoId: 'current',
          ),
        ),
      );
      await work;
      expect(vm.state.photoId, 'current');
      expect(vm.state.candidate, isNull);
    },
  );
  test(
    'timeout reconciles only three times at 1/2/4 seconds and retains operation identity',
    () async {
      final waits = <int>[];
      final repo = FakePhotoRepository()
        ..handler = (method, _) async {
          if (method == 'pickFromGallery') {
            return const Success<PhotoCandidate?>(candidate);
          }
          if (method == 'uploadPrimary') {
            return Failure<PhotoUploadState>(AppFailure(FailureCode.timeout));
          }
          return const Success(
            PhotoUploadState(jobId: 'job', status: PhotoJobStatus.pending),
          );
        };
      final vm = PhotoUploadViewModel(
        repo,
        delay: (duration) async {
          waits.add(duration.inSeconds);
        },
      );
      addTearDown(vm.dispose);
      await vm.bindAnimal(fixtureId(1), null);
      await vm.pick();
      await vm.upload();
      expect(waits, [1, 2, 4]);
      expect(vm.state.busy, isFalse);
      expect(vm.state.uncertain, isTrue);
      expect(vm.canSelect, isFalse);
      final original = repo.calls
          .firstWhere((c) => c.method == 'uploadPrimary')
          .arguments
          .last;
      expect(
        repo.calls
            .where((c) => c.method == 'getUpload')
            .every((c) => c.arguments.single == original),
        isTrue,
      );
    },
  );
  test(
    'gallery return revalidates after resume and private loss discards late upload result',
    () async {
      var epoch = 0, allowed = true;
      final selected = Completer<Result<PhotoCandidate?>>();
      final repo = FakePhotoRepository()..handler = (_, _) => selected.future;
      final vm = PhotoUploadViewModel(
        repo,
        isAuthorized: () => allowed,
        accessEpoch: () => epoch,
      );
      await vm.bindAnimal(fixtureId(1), null);
      final work = vm.pick();
      await Future<void>.delayed(Duration.zero);
      epoch++;
      selected.complete(const Success<PhotoCandidate?>(candidate));
      await work;
      expect(vm.state.candidate, isNotNull);
      allowed = false;
      await vm.upload();
      expect(repo.calls.where((c) => c.method == 'uploadPrimary'), isEmpty);
      vm.dispose();
      expect(vm.state.candidate, isNull);
      expect(vm.state.image, isNull);
    },
  );
  for (final code in [FailureCode.forbidden, FailureCode.unauthenticated]) {
    test(
      'upload ${code.name} discards candidate bytes before reauthorization',
      () async {
        var checks = 0;
        final repo = FakePhotoRepository()
          ..handler = (method, _) async => method == 'pickFromGallery'
              ? const Success<PhotoCandidate?>(candidate)
              : Failure<PhotoUploadState>(AppFailure(code));
        final vm = PhotoUploadViewModel(
          repo,
          isAuthorized: () => true,
          authorize: () async {
            checks++;
            return true;
          },
        );
        addTearDown(vm.dispose);
        await vm.bindAnimal(fixtureId(1), null);
        await vm.pick();
        expect(vm.state.candidate, isNotNull);
        await vm.upload();
        expect(vm.state.candidate, isNull);
        expect(vm.state.image, isNull);
        expect(vm.state.photoId, isNull);
        expect(vm.state.busy, false);
        expect(checks, greaterThan(1));
      },
    );
  }
  test(
    'verified same-user recovery can select again after denied upload without retaining bytes',
    () async {
      final repo = FakePhotoRepository()
        ..handler = (method, _) async => method == 'pickFromGallery'
            ? const Success<PhotoCandidate?>(candidate)
            : Failure<PhotoUploadState>(
                AppFailure(FailureCode.unauthenticated),
              );
      final vm = PhotoUploadViewModel(
        repo,
        isAuthorized: () => true,
        authorize: () async => true,
      );
      addTearDown(vm.dispose);
      await vm.bindAnimal(fixtureId(1), null);
      await vm.pick();
      await vm.upload();
      expect(vm.state.candidate, isNull);
      expect(vm.state.image, isNull);
      expect(vm.canSelect, true);
      await vm.pick();
      expect(vm.state.candidate, isNotNull);
    },
  );
}
