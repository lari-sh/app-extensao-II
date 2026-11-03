import 'package:abrigo_dos_anjos/domain/models/animal.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import 'fakes/fake_animals_repository.dart';
import 'presentation_fixtures.dart';

FakeAnimalsRepository managementScenario() =>
    FakeAnimalsRepository()..handler = managementResponse;
Future<Object?> managementResponse(String method, List<Object?> args) async {
  final animal = presentationAnimal('bento');
  if (method == 'getStatusCounts') {
    return const Success<Map<AnimalStatus, int>>({AnimalStatus.available: 2});
  }
  if (method == 'getManagement') return Success(ManagedAnimal(animal: animal));
  if (method == 'listManagement') {
    return Success(
      ManagedAnimalPage(
        items: args.first == AnimalStatus.available
            ? [ManagedAnimal(animal: animal)]
            : [],
        total: args.first == AnimalStatus.available ? 2 : 0,
        cursor: args.first == AnimalStatus.available && args.last == null
            ? 'next'
            : null,
      ),
    );
  }
  return Success(animal);
}
