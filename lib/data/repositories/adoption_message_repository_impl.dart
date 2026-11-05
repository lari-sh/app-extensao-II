import '../../utils/app_failure.dart';
import 'repository_result.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import 'package:abrigo_dos_anjos/domain/models/animal.dart';
import '../../domain/repositories/adoption_message_repository.dart';
import '../services/clipboard_service.dart';

class AdoptionMessageRepositoryImpl implements AdoptionMessageRepository {
  AdoptionMessageRepositoryImpl(this.service);
  final ClipboardService service;
  @override
  Future<Result<Unit>> copyInterestMessage(PublicAnimal animal) async {
    if (!animal.isPublished || animal.status != AnimalStatus.available) {
      return Failure(AppFailure(FailureCode.forbidden));
    }
    return mapRepositoryResult(
      () => service.copy(
        'Olá! Tenho interesse em adotar ${animal.name}. Podemos conversar sobre a adoção?',
      ),
      (value) => value,
    );
  }
}
