import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/ui/features/photos/view_models/photo_recovery_view_model.dart';
import 'package:abrigo_dos_anjos/domain/models/photo_candidate.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import 'package:abrigo_dos_anjos/utils/app_failure.dart';
import '../../../../support/fakes/fake_photo_repository.dart';
import '../../../../support/public_fixtures.dart';

void main() {
  test(
    'unknown user cannot keep recovered bytes and permission failure ends loading',
    () async {
      var allowed = false;
      final repo = FakePhotoRepository()
        ..handler = (_, _) async => const Success<PhotoCandidate?>(
          PhotoCandidate(bytes: [255, 216, 255], mime: 'image/jpeg'),
        );
      final vm = PhotoRecoveryViewModel(
        repo,
        isAuthorized: () => allowed,
        userId: () => allowed ? 'u' : null,
      );
      addTearDown(vm.dispose);
      await vm.recover();
      expect(vm.state.candidate, isNull);
      expect(vm.canOffer, isFalse);
      allowed = true;
      repo.handler = (_, _) async =>
          Failure<PhotoCandidate?>(AppFailure(FailureCode.permissionDenied));
      await vm.recover();
      expect(vm.state.busy, isFalse);
      expect(vm.state.candidate, isNull);
      expect(vm.state.message, isNotNull);
    },
  );
  test(
    'revocation during explicit target authorization discards recovered candidate',
    () async {
      var allowed = true;
      final repo = FakePhotoRepository()
        ..handler = (_, _) async => const Success<PhotoCandidate?>(
          PhotoCandidate(bytes: [255, 216, 255], mime: 'image/jpeg'),
        );
      final vm = PhotoRecoveryViewModel(
        repo,
        isAuthorized: () => allowed,
        userId: () => 'u',
        authorize: () async {
          allowed = false;
          return true;
        },
      );
      addTearDown(vm.dispose);
      await vm.recover();
      expect(await vm.confirmForAnimal(fixtureId(1)), isA<Failure>());
      expect(vm.state.candidate, isNull);
      expect(repo.calls.where((c) => c.method == 'uploadPrimary'), isEmpty);
    },
  );
  test(
    'recovery requires verified same user and explicit target; no automatic upload',
    () async {
      var user = 'u';
      final repo = FakePhotoRepository()
        ..handler = (_, _) async => const Success<PhotoCandidate?>(
          PhotoCandidate(bytes: [255, 216, 255], mime: 'image/jpeg'),
        );
      final vm = PhotoRecoveryViewModel(
        repo,
        isAuthorized: () => true,
        userId: () => user,
      );
      addTearDown(vm.dispose);
      await vm.recover();
      expect(vm.canOffer, isTrue);
      expect(repo.calls.map((c) => c.method), ['recoverLostSelection']);
      expect(await vm.confirmForAnimal(''), isA<Failure>());
      expect(vm.canOffer, isTrue);
      final selected = await vm.confirmForAnimal(fixtureId(1));
      expect(selected, isA<Success>());
      expect(vm.canOffer, isFalse);
      await vm.recover();
      user = 'other';
      vm.accessChanged();
      expect(vm.canOffer, isFalse);
      expect(vm.state.candidate, isNull);
    },
  );
}
