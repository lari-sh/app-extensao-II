import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/data/repositories/adoption_contact_repository_impl.dart';
import 'package:abrigo_dos_anjos/data/services/external_link_service.dart';
import 'package:abrigo_dos_anjos/domain/repositories/adoption_contact_repository.dart';
import 'package:abrigo_dos_anjos/domain/models/animal.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import '../../support/public_fixtures.dart';
import 'package:abrigo_dos_anjos/utils/app_failure.dart';

class LinkFake implements ExternalLinkService {
  final opened = <Uri>[];
  Result<Unit> result = const Success(Unit.value);
  @override
  Future<Result<Unit>> open(Uri uri) async {
    opened.add(uri);
    return result;
  }
}

void main() {
  test(
    'uses official channels and safely encodes Portuguese public data',
    () async {
      final links = LinkFake();
      final repo = AdoptionContactRepositoryImpl(links);
      final animal = fixtureAnimal(1).copyWith(name: 'Luna & João? #1');
      expect(
        await repo.open(AdoptionChannel.whatsapp, animal),
        isA<Success<Unit>>(),
      );
      final uri = links.opened.last;
      expect(uri.host, 'wa.me');
      expect(uri.path, '/5534991378936');
      expect(uri.queryParameters['text'], contains('Luna & João? #1'));
      expect(uri.queryParameters['text'], contains(animal.approximateAge));
      expect(uri.queryParameters.keys, ['text']);
      expect(uri.queryParameters['text'], isNot(contains('http')));
      await repo.open(AdoptionChannel.instagram, animal);
      expect(
        links.opened.last.toString(),
        'https://www.instagram.com/abrigodosanjosoficial/',
      );
      await repo.open(AdoptionChannel.facebook, animal);
      expect(
        links.opened.last.toString(),
        'https://www.facebook.com/abrigodosanjosura/?locale=pt_BR',
      );
      expect(links.opened.every((uri) => uri.scheme == 'https'), isTrue);
    },
  );
  test(
    'rejects unavailable animal before opening and preserves typed failure',
    () async {
      final links = LinkFake();
      final repo = AdoptionContactRepositoryImpl(links);
      for (final animal in [
        fixtureAnimal(1).copyWith(isPublished: false),
        fixtureAnimal(1).copyWith(status: AnimalStatus.adopted),
      ]) {
        expect(
          await repo.open(AdoptionChannel.whatsapp, animal),
          isA<Failure<Unit>>(),
        );
      }
      expect(links.opened, isEmpty);
      // No outgoing operation is falsely reported as a message sent.
      links.result = Failure(AppFailure(FailureCode.network));
      expect(
        await repo.open(AdoptionChannel.instagram, fixtureAnimal(1)),
        same(links.result),
      );
    },
  );
}
