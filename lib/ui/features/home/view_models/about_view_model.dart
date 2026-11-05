import 'package:flutter/foundation.dart';
import '../../../../domain/repositories/shelter_contact_repository.dart';
import '../../../../utils/result.dart';

class AboutViewModel extends ChangeNotifier {
  AboutViewModel([this._repository]);
  final ShelterContactRepository? _repository;
  bool _busy = false;
  bool _disposed = false;
  String? _message;
  bool get busy => _busy;
  String? get message => _message;
  String get pixKey => ShelterContactRepository.pixKey;
  String get title => 'Sobre o abrigo';
  String get body =>
      'O Abrigo dos Anjos acolhe animais e ajuda a encontrar lares responsáveis. Cada adoção é uma nova chance de carinho e cuidado.';
  String close() => '/';

  Future<void> copyPix() => _perform(
    () => _repository?.copyPix(),
    success: 'Chave Pix copiada!',
    failure: 'Não foi possível copiar. Tente novamente ou selecione a chave.',
  );

  Future<void> openContact(ShelterChannel channel) => _perform(
    () => _repository?.open(channel),
    failure: 'Não foi possível abrir o contato. Tente novamente.',
  );

  Future<void> _perform(
    Future<Result<Unit>>? Function() action, {
    String? success,
    required String failure,
  }) async {
    if (_busy || _disposed) return;
    _busy = true;
    _message = null;
    notifyListeners();
    try {
      final result = await action();
      _message = result is Success<Unit> ? success : failure;
    } catch (_) {
      _message = failure;
    } finally {
      _busy = false;
      if (!_disposed) notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
