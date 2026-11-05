import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/domain/repositories/shelter_contact_repository.dart';
import 'package:abrigo_dos_anjos/ui/features/home/view_models/about_view_model.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import 'package:abrigo_dos_anjos/utils/app_failure.dart';

class AboutRepository implements ShelterContactRepository {
  int copies = 0;
  ShelterChannel? opened;
  Future<Result<Unit>> Function() action = () async =>
      const Success(Unit.value);
  @override
  Future<Result<Unit>> copyPix() {
    copies++;
    return action();
  }

  @override
  Future<Result<Unit>> open(ShelterChannel channel) {
    opened = channel;
    return action();
  }
}

void main() {
  test(
    'copy confirmation, links, failure, retry and unavailable dependency',
    () async {
      final repo = AboutRepository();
      final vm = AboutViewModel(repo);
      expect(vm.pixKey, '23.785.379/0001-98');
      await vm.copyPix();
      expect(vm.message, 'Chave Pix copiada!');
      await vm.openContact(ShelterChannel.instagram);
      expect(repo.opened, ShelterChannel.instagram);
      expect(vm.message, isNull);
      repo.action = () async => Failure(AppFailure(FailureCode.network));
      await vm.copyPix();
      expect(vm.message, contains('Não foi possível copiar'));
      await vm.openContact(ShelterChannel.facebook);
      expect(vm.message, contains('Não foi possível abrir'));
      repo.action = () async => throw StateError('secret');
      await vm.copyPix();
      expect(vm.message, isNot(contains('secret')));
      expect(vm.busy, isFalse);
      final missing = AboutViewModel();
      await missing.copyPix();
      expect(missing.message, contains('Não foi possível copiar'));
      missing.dispose();
      vm.dispose();
    },
  );
  test(
    'prevents duplicate actions and safely finishes after disposal',
    () async {
      final repo = AboutRepository();
      final pending = Completer<Result<Unit>>();
      repo.action = () => pending.future;
      final vm = AboutViewModel(repo);
      var changes = 0;
      vm.addListener(() => changes++);
      final request = vm.copyPix();
      expect(vm.busy, isTrue);
      await vm.copyPix();
      expect(repo.copies, 1);
      vm.dispose();
      pending.complete(const Success(Unit.value));
      await request;
      await vm.copyPix();
      expect(changes, 1);
      expect(repo.copies, 1);
    },
  );
}
