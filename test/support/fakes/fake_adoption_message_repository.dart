import 'fake_behavior.dart';
import 'package:abrigo_dos_anjos/domain/repositories/adoption_message_repository.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import 'package:abrigo_dos_anjos/domain/models/animal.dart';

class FakeAdoptionMessageRepository extends FakeBehavior
    implements AdoptionMessageRepository {
  @override
  Future<Result<Unit>> copyInterestMessage(PublicAnimal animal) =>
      invoke<Unit>('copyInterestMessage', [animal]);
}
