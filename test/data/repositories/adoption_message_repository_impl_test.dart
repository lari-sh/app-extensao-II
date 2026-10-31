import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/data/repositories/adoption_message_repository_impl.dart';
import 'package:abrigo_dos_anjos/domain/models/animal.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import '../../support/fakes/fake_clipboard_service.dart';
import '../../support/public_fixtures.dart';

void main() {
  test(
    'copies Portuguese interest without sending a request and rejects unavailable animal',
    () async {
      final service = FakeClipboardService()
        ..handler = (_, args) async => const Success(Unit.value);
      final repo = AdoptionMessageRepositoryImpl(service);
      expect(await repo.copyInterestMessage(fixtureAnimal(1)), isA<Success>());
      expect(service.calls.single.arguments.first, contains('Luna 1'));
      expect(
        await repo.copyInterestMessage(
          fixtureAnimal(1).copyWith(status: AnimalStatus.adopted),
        ),
        isA<Failure>(),
      );
      expect(
        await repo.copyInterestMessage(
          fixtureAnimal(1).copyWith(isPublished: false),
        ),
        isA<Failure>(),
      );
      expect(service.calls.length, 1);
    },
  );
}
