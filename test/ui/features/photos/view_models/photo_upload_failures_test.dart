import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/ui/features/photos/view_models/photo_upload_view_model.dart';
import 'package:abrigo_dos_anjos/domain/models/photo_candidate.dart';
import 'package:abrigo_dos_anjos/domain/models/photo_upload_state.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import 'package:abrigo_dos_anjos/utils/app_failure.dart';
import '../../../../support/fakes/fake_photo_repository.dart';
import '../../../../support/public_fixtures.dart';

const candidate = PhotoCandidate(bytes: [255, 216, 255], mime: 'image/jpeg');
void main() {
  for (final code in [
    FailureCode.permissionDenied,
    FailureCode.validation,
    FailureCode.forbidden,
    FailureCode.network,
  ]) {
    test('gallery $code is friendly and never starts upload', () async {
      final repo = FakePhotoRepository()
        ..handler = (_, _) async => Failure<PhotoCandidate?>(AppFailure(code));
      final vm = PhotoUploadViewModel(repo);
      addTearDown(vm.dispose);
      await vm.bindAnimal(fixtureId(1), null);
      await vm.pick();
      expect(vm.state.message, isNotEmpty);
      expect(vm.state.busy, isFalse);
      expect(vm.canUpload, isFalse);
      expect(repo.calls.length, 1);
    });
  }
  test(
    'gallery platform exception clears busy and offers another attempt',
    () async {
      final repo = FakePhotoRepository()
        ..handler = (_, _) async => throw StateError('private native detail');
      final vm = PhotoUploadViewModel(repo);
      addTearDown(vm.dispose);
      await vm.bindAnimal(fixtureId(1), null);
      await vm.pick();
      expect(vm.canSelect, isTrue);
      expect(vm.state.message, isNot(contains('private')));
    },
  );
  for (final mode in ['candidate', 'failure', 'exception']) {
    test('recovered selection $mode is never uploaded automatically', () async {
      final repo = FakePhotoRepository();
      final vm = PhotoUploadViewModel(
        repo,
        recoveryAvailable: () => true,
        recoverCandidate: (_) async {
          if (mode == 'exception') throw StateError('private');
          if (mode == 'failure') {
            return Failure<PhotoCandidate?>(AppFailure(FailureCode.validation));
          }
          return const Success<PhotoCandidate?>(candidate);
        },
      );
      addTearDown(vm.dispose);
      await vm.bindAnimal(fixtureId(1), null);
      vm.refreshRecovery();
      expect(vm.canRecover, isTrue);
      await vm.useRecovered();
      expect(vm.state.busy, isFalse);
      expect(repo.calls, isEmpty);
      expect(vm.state.message, isNotEmpty);
      if (mode == 'candidate') {
        expect(vm.state.candidate, candidate);
        expect(vm.canUpload, isTrue);
        expect(vm.state.hasRecovery, isFalse);
      }
    });
  }
  test('recovered bytes from an old animal are discarded', () async {
    final pending = Completer<Result<PhotoCandidate?>>();
    final vm = PhotoUploadViewModel(
      FakePhotoRepository(),
      recoverCandidate: (_) => pending.future,
    );
    addTearDown(vm.dispose);
    await vm.bindAnimal(fixtureId(1), null);
    final work = vm.useRecovered();
    await vm.bindAnimal(fixtureId(2), null);
    pending.complete(const Success<PhotoCandidate?>(candidate));
    await work;
    expect(vm.state.candidate, isNull);
  });
  for (final status in [
    PhotoJobStatus.failed,
    PhotoJobStatus.cleaned,
    PhotoJobStatus.cleanupNeeded,
  ]) {
    test('terminal $status preserves the original photo binding', () async {
      final repo = FakePhotoRepository()
        ..handler = (method, _) async => method == 'pickFromGallery'
            ? const Success<PhotoCandidate?>(candidate)
            : Success(PhotoUploadState(jobId: 'job', status: status));
      final vm = PhotoUploadViewModel(repo);
      addTearDown(vm.dispose);
      await vm.bindAnimal(fixtureId(1), null);
      await vm.pick();
      await vm.upload();
      expect(vm.state.uncertain, isFalse);
      expect(vm.state.canRetry, isFalse);
      expect(vm.state.candidate, candidate);
      expect(vm.state.message, contains('anterior foi preservada'));
    });
  }
  test(
    'missing receipt permits explicit retry with same key; retry failure never duplicates polling',
    () async {
      var uploads = 0;
      final repo = FakePhotoRepository()
        ..handler = (method, args) async {
          if (method == 'pickFromGallery') {
            return const Success<PhotoCandidate?>(candidate);
          }
          if (method == 'uploadPrimary') {
            uploads++;
            return Failure<PhotoUploadState>(
              AppFailure(
                uploads == 1 ? FailureCode.timeout : FailureCode.validation,
              ),
            );
          }
          return Failure<PhotoUploadState>(AppFailure(FailureCode.notFound));
        };
      final vm = PhotoUploadViewModel(repo, delay: (_) async {});
      addTearDown(vm.dispose);
      await vm.bindAnimal(fixtureId(1), null);
      await vm.pick();
      await vm.upload();
      expect(vm.state.canRetry, isTrue);
      final key = repo.calls
          .firstWhere((c) => c.method == 'uploadPrimary')
          .arguments
          .last;
      await vm.retry();
      expect(
        repo.calls
            .where((c) => c.method == 'uploadPrimary')
            .last
            .arguments
            .last,
        key,
      );
      expect(vm.state.uncertain, isFalse);
      expect(vm.state.canRetry, isFalse);
    },
  );
  test(
    'polling access denial requests revalidation and preserves uncertain result',
    () async {
      var checks = 0;
      final repo = FakePhotoRepository()
        ..handler = (method, args) async => method == 'pickFromGallery'
            ? const Success<PhotoCandidate?>(candidate)
            : Failure<PhotoUploadState>(
                AppFailure(
                  method == 'getUpload'
                      ? FailureCode.forbidden
                      : FailureCode.timeout,
                ),
              );
      final vm = PhotoUploadViewModel(
        repo,
        authorize: () async {
          checks++;
          return true;
        },
        delay: (_) async {},
      );
      addTearDown(vm.dispose);
      await vm.bindAnimal(fixtureId(1), null);
      await vm.pick();
      await vm.upload();
      expect(checks, greaterThan(3));
      expect(vm.state.uncertain, isTrue);
      expect(vm.state.canRetry, isFalse);
    },
  );
  test(
    'polling exceptions give safe feedback and leave explicit reconciliation available',
    () async {
      final repo = FakePhotoRepository()
        ..handler = (method, args) async {
          if (method == 'pickFromGallery') {
            return const Success<PhotoCandidate?>(candidate);
          }
          throw StateError('private transport');
        };
      final vm = PhotoUploadViewModel(repo, delay: (_) async {});
      addTearDown(vm.dispose);
      await vm.bindAnimal(fixtureId(1), null);
      await vm.pick();
      await vm.upload();
      await vm.reconcile();
      expect(vm.state.busy, isFalse);
      expect(vm.state.message, contains('verificar'));
      expect(vm.state.message, isNot(contains('private')));
    },
  );
}
