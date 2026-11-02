import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../domain/models/team_access.dart';
import '../../../../domain/repositories/team_repository.dart';
import '../../../../domain/repositories/auth_repository.dart';
import '../../../../utils/result.dart';
import '../../../../utils/operation_id.dart';
import 'team_view_model.dart';
part 'accept_invitation_view_model.freezed.dart';

@freezed
abstract class AcceptInvitationState with _$AcceptInvitationState {
  const factory AcceptInvitationState({
    TeamInvitation? invitation,
    @Default(false) bool loading,
    @Default(false) bool busy,
    @Default(false) bool accepted,
    @Default(false) bool passwordSaved,
    @Default({}) Map<String, String> errors,
    String? message,
  }) = _AcceptInvitationState;
}

class AcceptInvitationViewModel extends ChangeNotifier {
  AcceptInvitationViewModel(this.repository, this.auth);
  final TeamRepository repository;
  final AuthRepository auth;
  AcceptInvitationState _state = const AcceptInvitationState();
  AcceptInvitationState get state => _state;
  final _operation = OperationId();
  bool _disposed = false;
  bool get canSubmit =>
      !state.loading &&
      !state.busy &&
      !state.accepted &&
      state.invitation?.canAccept == true;
  void _emit(AcceptInvitationState value) {
    if (!_disposed) {
      _state = value;
      notifyListeners();
    }
  }

  Future<void> load() async {
    if (_disposed || state.busy || state.loading) return;
    _emit(state.copyWith(loading: true, message: null));
    final result = await repository.ownInvitation();
    if (_disposed) return;
    switch (result) {
      case Success<TeamInvitation?>(:final value):
        _emit(
          state.copyWith(
            loading: false,
            invitation: value,
            passwordSaved: value?.passwordReady ?? false,
            message: value?.canAccept == true
                ? null
                : 'Este convite expirou, foi cancelado ou já foi utilizado. Solicite um novo convite.',
          ),
        );
      case Failure<TeamInvitation?>(:final failure):
        _emit(
          state.copyWith(
            loading: false,
            invitation: null,
            message: teamFailure(failure),
          ),
        );
    }
  }

  Future<void> submit(String password, String confirmation) async {
    if (!canSubmit) return;
    final errors = <String, String>{};
    if (!state.passwordSaved) {
      if (password.runes.length < 12) {
        errors['password'] = 'Use pelo menos 12 caracteres.';
      }
      if (password != confirmation) {
        errors['confirmation'] = 'As senhas precisam ser iguais.';
      }
    }
    _emit(state.copyWith(errors: errors, message: null));
    if (errors.isNotEmpty) return;
    _emit(state.copyWith(busy: true));
    try {
      if (!state.passwordSaved) {
        final saved = await repository.definePassword(password);
        if (_disposed) return;
        if (saved case Failure<Unit>(:final failure)) {
          // The Auth write may have committed before its response was lost.
          // Only the server proof can authorize skipping a repeated password write.
          final checked = await repository.ownInvitation();
          if (_disposed) return;
          final current = checked is Success<TeamInvitation?>
              ? checked.value
              : null;
          if (current?.passwordReady != true ||
              current?.id != state.invitation?.id ||
              current?.generation != state.invitation?.generation) {
            _emit(state.copyWith(message: teamFailure(failure)));
            return;
          }
        }
        _emit(state.copyWith(passwordSaved: true));
      }
      final result = await repository.accept(
        state.invitation!,
        _operation.value,
      );
      if (_disposed) return;
      if (result case Success<TeamReceipt>(:final value)) {
        if (value.state == 'confirmed') {
          final signedOut = await auth.signOut();
          if (_disposed) return;
          if (signedOut case Failure<Unit>(:final failure)) {
            _emit(state.copyWith(message: teamFailure(failure)));
            return;
          }
          _operation.complete();
          _emit(
            state.copyWith(
              accepted: true,
              message:
                  'Convite aceito! Entre com seu e-mail e a senha que você definiu.',
            ),
          );
        } else {
          _emit(state.copyWith(message: receiptMessage(value)));
        }
      } else {
        _emit(
          state.copyWith(
            message: teamFailure((result as Failure<TeamReceipt>).failure),
          ),
        );
      }
    } finally {
      if (!_disposed) _emit(state.copyWith(busy: false));
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
