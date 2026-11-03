import '../../domain/repositories/shelter_contact_repository.dart';
import '../../utils/app_failure.dart';
import '../../utils/result.dart';
import '../services/clipboard_service.dart';
import '../services/external_link_service.dart';

class ShelterContactRepositoryImpl implements ShelterContactRepository {
  ShelterContactRepositoryImpl(this._clipboard, this._links);
  final ClipboardService _clipboard;
  final ExternalLinkService _links;

  Future<Result<Unit>> _run(Future<Result<Unit>> Function() action) async {
    try {
      return await action();
    } catch (_) {
      return Failure(AppFailure(FailureCode.unknown, retryable: true));
    }
  }

  @override
  Future<Result<Unit>> copyPix() =>
      _run(() => _clipboard.copy(ShelterContactRepository.pixKey));

  @override
  Future<Result<Unit>> open(ShelterChannel channel) => _run(
    () => _links.open(switch (channel) {
      ShelterChannel.whatsapp => Uri.parse('https://wa.me/5534991378936'),
      ShelterChannel.instagram => Uri.parse(
        'https://www.instagram.com/abrigodosanjosoficial/',
      ),
      ShelterChannel.facebook => Uri.parse(
        'https://www.facebook.com/abrigodosanjosura/?locale=pt_BR',
      ),
    }),
  );
}
