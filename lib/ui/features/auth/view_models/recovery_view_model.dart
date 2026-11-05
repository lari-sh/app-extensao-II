import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../domain/repositories/auth_repository.dart';
import '../../../../utils/result.dart';
part 'recovery_view_model.freezed.dart';

@freezed
abstract class RecoveryState with _$RecoveryState {
  const factory RecoveryState({
    @Default(false) bool busy,
    @Default(false) bool loading,
    @Default(false) bool available,
    @Default(false) bool completed,
    @Default({}) Map<String, String> errors,
    String? message,
  }) = _RecoveryState;
}

abstract class RecoveryNotifier extends ChangeNotifier {
  RecoveryNotifier(this.repository);
  final AuthRepository repository;
  RecoveryState _state = const RecoveryState();
  RecoveryState get state => _state;
  bool disposed = false;
  void publish(RecoveryState value) {
    if (!disposed) {
      _state = value;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    disposed = true;
    super.dispose();
  }
}

class RecoveryViewModel extends RecoveryNotifier {
  RecoveryViewModel(super.repository);
  Future<void> submit(String email) async {
    if (disposed || state.busy || state.completed) return;
    final address = email.trim();
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(address)) {
      publish(state.copyWith(errors: {'email': 'Informe um e-mail válido.'}));
      return;
    }
    publish(state.copyWith(busy: true, errors: {}, message: null));
    final result = await repository.requestPasswordReset(address);
    publish(
      state.copyWith(
        busy: false,
        completed: result is Success<Unit>,
        message: result is Failure<Unit>
            ? 'Não foi possível enviar as orientações. Verifique sua conexão e tente novamente.'
            : null,
      ),
    );
  }
}

class ResetPasswordViewModel extends RecoveryNotifier {
  ResetPasswordViewModel(super.repository);
  Future<void> load() async {
    if (disposed || state.loading || state.busy || state.completed) return;
    publish(state.copyWith(loading: true, available: false, message: null));
    final result = await repository.canResetPassword();
    final available = result is Success<bool> && result.value;
    publish(
      state.copyWith(
        loading: false,
        available: available,
        message: available
            ? null
            : 'Este link está inválido, expirou ou já foi utilizado. Solicite novas orientações.',
      ),
    );
  }

  Future<void> submit(String password, String confirmation) async {
    if (disposed || state.busy || !state.available || state.completed) return;
    final errors = <String, String>{};
    if (password.length < 12) {
      errors['password'] = 'Use pelo menos 12 caracteres.';
    }
    if (password != confirmation) {
      errors['confirmation'] = 'As senhas precisam ser iguais.';
    }
    if (errors.isNotEmpty) {
      publish(state.copyWith(errors: errors));
      return;
    }
    publish(state.copyWith(busy: true, errors: {}, message: null));
    final result = await repository.updateRecoveredPassword(password);
    publish(
      state.copyWith(
        busy: false,
        completed: result is Success<Unit>,
        message: result is Failure<Unit>
            ? 'Não foi possível atualizar a senha. Verifique sua conexão ou solicite um novo link.'
            : null,
      ),
    );
  }
}
