import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../domain/repositories/auth_repository.dart';
import '../../../../domain/models/session_access.dart';
import '../../../../utils/result.dart';
part 'login_view_model.freezed.dart';

@freezed
abstract class LoginState with _$LoginState {
  const factory LoginState({
    @Default(false) bool busy,
    @Default(false) bool signedIn,
    @Default({}) Map<String, String> fieldErrors,
    String? message,
  }) = _LoginState;
}

class LoginViewModel extends ChangeNotifier {
  LoginViewModel(
    this.repository, {
    this.beginAttempt,
    this.isAttemptCurrent,
    this.onAccess,
    this.onFailure,
    this.onCancel,
  });
  final AuthRepository repository;
  final int? Function()? beginAttempt;
  final bool Function(int)? isAttemptCurrent;
  final bool Function(int, SessionAccess)? onAccess;
  final void Function(int)? onFailure;
  final void Function(int)? onCancel;
  LoginState _state = const LoginState();
  LoginState get state => _state;
  bool _disposed = false;
  int _generation = 0;
  int? _attempt;
  void _publish(LoginState value) {
    if (!_disposed) {
      _state = value;
      notifyListeners();
    }
  }

  Future<void> submit(String email, String password) async {
    if (_disposed || state.busy) return;
    final errors = <String, String>{};
    final trimmed = email.trim();
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(trimmed)) {
      errors['email'] = 'Informe um e-mail válido.';
    }
    if (password.isEmpty) errors['password'] = 'Informe sua senha.';
    if (errors.isNotEmpty) {
      _publish(LoginState(fieldErrors: errors));
      return;
    }
    final ticket = beginAttempt == null ? 0 : beginAttempt!();
    if (ticket == null) return;
    _attempt = ticket;
    final generation = ++_generation;
    _publish(const LoginState(busy: true));
    try {
      final result = await repository.signIn(trimmed, password);
      if (_disposed ||
          generation != _generation ||
          (isAttemptCurrent != null && !isAttemptCurrent!(ticket))) {
        return;
      }
      switch (result) {
        case Failure<SessionAccess>():
          onFailure?.call(ticket);
          _publish(
            state.copyWith(
              message:
                  'Não foi possível entrar. Confira suas credenciais e tente novamente.',
            ),
          );
        case Success<SessionAccess>(:final value):
          if (onAccess != null && !onAccess!(ticket, value)) return;
          _publish(
            state.copyWith(
              signedIn: value.isAuthorized,
              message: value.isAuthorized
                  ? null
                  : value.level == AccessLevel.authenticatedWithoutStaff
                  ? 'Sua conta não possui autorização de voluntário.'
                  : 'Não foi possível entrar. Confira suas credenciais e tente novamente.',
            ),
          );
      }
    } catch (_) {
      if (!_disposed && generation == _generation) {
        onFailure?.call(ticket);
        _publish(
          state.copyWith(
            message:
                'Não foi possível entrar. Confira suas credenciais e tente novamente.',
          ),
        );
      }
    } finally {
      if (!_disposed && generation == _generation) {
        _attempt = null;
        _publish(state.copyWith(busy: false));
      }
    }
  }

  @override
  void dispose() {
    if (_attempt != null) onCancel?.call(_attempt!);
    _disposed = true;
    ++_generation;
    super.dispose();
  }
}
