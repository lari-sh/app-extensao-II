import '../../domain/models/animal.dart';
import '../../domain/repositories/adoption_contact_repository.dart';
import '../../utils/app_failure.dart';
import '../../utils/result.dart';
import '../services/external_link_service.dart';

class AdoptionContactRepositoryImpl implements AdoptionContactRepository {
  AdoptionContactRepositoryImpl(this._links);
  final ExternalLinkService _links;

  @override
  Future<Result<Unit>> open(
    AdoptionChannel channel,
    PublicAnimal animal,
  ) async {
    if (!animal.isPublished || animal.status != AnimalStatus.available) {
      return Failure(AppFailure(FailureCode.notFound));
    }
    final Uri uri;
    switch (channel) {
      case AdoptionChannel.whatsapp:
        final species = animal.species == AnimalSpecies.dog
            ? 'Cachorro'
            : 'Gato';
        final sex = animal.sex == AnimalSex.female ? 'Fêmea' : 'Macho';
        final message =
            'Olá! Tenho interesse em adotar ${animal.name}. '
            '$species · $sex · ${animal.approximateAge}. '
            'Gostaria de saber mais sobre a adoção.';
        uri = Uri.https('wa.me', '/5534991378936', {'text': message});
      case AdoptionChannel.instagram:
        uri = Uri.parse('https://www.instagram.com/abrigodosanjosoficial/');
      case AdoptionChannel.facebook:
        uri = Uri.https('www.facebook.com', '/abrigodosanjosura/', {
          'locale': 'pt_BR',
        });
    }
    try {
      return await _links.open(uri);
    } catch (_) {
      return Failure(AppFailure(FailureCode.unknown, retryable: true));
    }
  }
}
