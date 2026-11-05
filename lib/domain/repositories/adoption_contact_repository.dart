import '../models/animal.dart';
import '../../utils/result.dart';

enum AdoptionChannel { whatsapp, instagram, facebook }

abstract interface class AdoptionContactRepository {
  Future<Result<Unit>> open(AdoptionChannel channel, PublicAnimal animal);
}
