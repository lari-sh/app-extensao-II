import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/ui/features/photos/view_models/photo_recovery_view_model.dart';
import 'package:abrigo_dos_anjos/domain/models/photo_candidate.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import '../../../../support/fakes/fake_photo_repository.dart';
import '../../../../support/public_fixtures.dart';

void main() {
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
