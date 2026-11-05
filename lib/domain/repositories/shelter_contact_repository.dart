import '../../utils/result.dart';

import '../models/shelter_channel.dart';
export '../models/shelter_channel.dart';

abstract interface class ShelterContactRepository {
  static const pixKey = '23.785.379/0001-98';
  Future<Result<Unit>> copyPix();
  Future<Result<Unit>> open(ShelterChannel channel);
}
