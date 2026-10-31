import '../../utils/result.dart';
import '../models/animal.dart';

abstract interface class AdoptionMessageRepository {
  Future<Result<Unit>> copyInterestMessage(PublicAnimal animal);
}
