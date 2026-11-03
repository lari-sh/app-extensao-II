import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/data/repositories/shelter_contact_repository_impl.dart';
import 'package:abrigo_dos_anjos/data/services/clipboard_service.dart';
import 'package:abrigo_dos_anjos/data/services/external_link_service.dart';
import 'package:abrigo_dos_anjos/domain/repositories/shelter_contact_repository.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import 'package:abrigo_dos_anjos/utils/app_failure.dart';

class ContactServices implements ClipboardService, ExternalLinkService {
  String? copied;
  Uri? opened;
  bool throws = false;
  Result<Unit> result = const Success(Unit.value);
  @override
  Future<Result<Unit>> copy(String message) async {
    if (throws) throw StateError('private details');
    copied = message;
    return result;
  }

  @override
  Future<Result<Unit>> open(Uri uri) async {
    if (throws) throw StateError('private details');
    opened = uri;
    return result;
  }
}

void main() {
  test(
    'copies the exact user supplied Pix key and opens only official HTTPS contacts',
    () async {
      final service = ContactServices();
      final repo = ShelterContactRepositoryImpl(service, service);
      expect(await repo.copyPix(), isA<Success<Unit>>());
      expect(service.copied, '23.785.379/0001-98');
      final expected = [
        'https://wa.me/5534991378936',
        'https://www.instagram.com/abrigodosanjosoficial/',
        'https://www.facebook.com/abrigodosanjosura/?locale=pt_BR',
      ];
      for (final channel in ShelterChannel.values) {
        expect(await repo.open(channel), isA<Success<Unit>>());
        expect(service.opened.toString(), expected[channel.index]);
      }
    },
  );
  test(
    'preserves typed failures and catches unexpected platform exceptions',
    () async {
      final service = ContactServices();
      final repo = ShelterContactRepositoryImpl(service, service);
      service.result = Failure(AppFailure(FailureCode.permissionDenied));
      expect(await repo.copyPix(), same(service.result));
      expect(await repo.open(ShelterChannel.whatsapp), same(service.result));
      service.throws = true;
      expect(await repo.copyPix(), isA<Failure<Unit>>());
      expect(await repo.open(ShelterChannel.facebook), isA<Failure<Unit>>());
    },
  );
}
