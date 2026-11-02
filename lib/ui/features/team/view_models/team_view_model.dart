import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../domain/models/team_access.dart';
import '../../../../domain/models/session_access.dart';
import '../../../../domain/repositories/team_repository.dart';
import '../../../../utils/result.dart';
import '../../../../utils/app_failure.dart';
import '../../../../utils/operation_id.dart';
import '../../../core/view_models/public_list_view_model.dart'
    show failureMessage;
part 'team_view_model.freezed.dart';

enum TeamTab { active, invitations, inactive }

String teamFailure(AppFailure failure) =>
    failure.fieldErrors['team'] ?? failureMessage(failure);
String roleLabel(StaffRole role) =>
    role == StaffRole.administrator ? 'Administrador' : 'Funcionário';
String receiptMessage(TeamReceipt receipt) => switch (receipt.code) {
  'delivery_uncertain' =>
    'Convite registrado. A entrega do e-mail ainda não foi confirmada.',
  'send_failed' =>
    'Não foi possível enviar o convite. Confira o e-mail e tente novamente.',
  'existing_account' =>
    'Este e-mail já possui conta. Solicite ajuda ao administrador técnico.',
  'invitation_unavailable' => 'Este convite não está mais disponível.',
  _ =>
    receipt.state == 'confirmed'
        ? 'Alteração confirmada.'
        : 'Resultado ainda não confirmado. Consulte novamente.',
};

@freezed
abstract class TeamState with _$TeamState {
  const factory TeamState({
    @Default(TeamTab.active) TeamTab tab,
    @Default([]) List<TeamMember> members,
    @Default([]) List<TeamInvitation> invitations,
    String? nextCursor,
    @Default(false) bool loading,
    @Default(false) bool busy,
    @Default(false) bool uncertain,
    String? message,
  }) = _TeamState;
}

class TeamViewModel extends ChangeNotifier {
  TeamViewModel(
    this.repository, {
    required this.canManage,
    required this.authorize,
    required this.contextKey,
    required this.currentUserId,
  });
  final TeamRepository repository;
  final bool Function() canManage;
  final Future<bool> Function() authorize;
  final String Function() contextKey;
  final String? Function() currentUserId;
  TeamState _state = const TeamState();
  TeamState get state => _state;
  bool _disposed = false;
  int _revision = 0;
  final _operation = OperationId();
  bool get canAct => canManage() && !state.busy && !state.uncertain;
  bool canEdit(TeamMember member) => canAct && member.id != currentUserId();
  void _emit(TeamState value) {
    if (!_disposed) {
      _state = value;
      notifyListeners();
    }
  }

  bool _current(int revision, String key) =>
      !_disposed && revision == _revision && contextKey() == key && canManage();
  Future<void> select(TeamTab tab) async {
    if (state.busy || state.uncertain) return;
    _emit(TeamState(tab: tab));
    await load();
  }

  Future<void> load({bool more = false}) async {
    if (_disposed || state.loading || state.busy) return;
    final revision = ++_revision, key = contextKey();
    final tab = state.tab;
    _emit(state.copyWith(loading: true, message: null));
    try {
      if (!await authorize() || !_current(revision, key)) return;
      final cursor = more ? state.nextCursor : null;
      final result = tab == TeamTab.invitations
          ? await repository.invitations(cursor: cursor)
          : await repository.members(
              active: tab == TeamTab.active,
              cursor: cursor,
            );
      if (!_current(revision, key)) return;
      switch (result) {
        case Success<TeamPage>(:final value):
          _emit(
            state.copyWith(
              members: [if (more) ...state.members, ...value.members],
              invitations: [
                if (more) ...state.invitations,
                ...value.invitations,
              ],
              nextCursor: value.nextCursor,
            ),
          );
        case Failure<TeamPage>(:final failure):
          _emit(state.copyWith(message: teamFailure(failure)));
      }
    } finally {
      if (!_disposed && revision == _revision) {
        _emit(state.copyWith(loading: false));
      }
    }
  }

  Future<void> resend(TeamInvitation invitation) async {
    if (canAct && invitation.canResend) {
      await _command((key) => repository.resend(invitation, key));
    }
  }

  Future<void> cancel(TeamInvitation invitation) async {
    if (canAct && invitation.canCancel) {
      await _command((key) => repository.cancel(invitation, key));
    }
  }

  Future<void> change(TeamMember member, StaffRole role, bool active) async {
    if (canEdit(member)) {
      await _command((key) => repository.change(member, role, active, key));
    }
  }

  Future<void> _command(
    Future<Result<TeamReceipt>> Function(String) action, {
    bool reconcile = false,
  }) async {
    if (_disposed || state.busy || (!reconcile && state.uncertain)) return;
    final revision = ++_revision, key = contextKey();
    _emit(state.copyWith(busy: true, message: null));
    String? message;
    try {
      if (!await authorize() || !_current(revision, key)) return;
      final result = await action(_operation.value);
      if (!_current(revision, key)) return;
      if (result case Success<TeamReceipt>(:final value)) {
        final uncertain = value.state == 'pending';
        if (!uncertain) _operation.complete();
        message = receiptMessage(value);
        _emit(state.copyWith(uncertain: uncertain, message: message));
      } else {
        final failure = (result as Failure<TeamReceipt>).failure;
        final uncertain = const [
          FailureCode.network,
          FailureCode.timeout,
          FailureCode.unknown,
        ].contains(failure.code);
        if (!uncertain) _operation.complete();
        message = teamFailure(failure);
        _emit(state.copyWith(uncertain: uncertain, message: message));
      }
    } finally {
      if (!_disposed && revision == _revision) {
        _emit(state.copyWith(busy: false));
      }
    }
    if (!_disposed && !state.uncertain) {
      await load();
      if (!_disposed) {
        _emit(state.copyWith(message: message));
      }
    }
  }

  Future<void> reconcile() => _command(repository.reconcile, reconcile: true);
  @override
  void dispose() {
    _disposed = true;
    _revision++;
    super.dispose();
  }
}

@freezed
abstract class InviteMemberState with _$InviteMemberState {
  const factory InviteMemberState({
    @Default(StaffRole.employee) StaffRole role,
    @Default(false) bool busy,
    @Default(false) bool uncertain,
    @Default(false) bool sent,
    @Default({}) Map<String, String> errors,
    String? message,
  }) = _InviteMemberState;
}

class InviteMemberViewModel extends ChangeNotifier {
  InviteMemberViewModel(
    this.repository, {
    required this.canManage,
    required this.authorize,
    required this.contextKey,
  });
  final TeamRepository repository;
  final bool Function() canManage;
  final Future<bool> Function() authorize;
  final String Function() contextKey;
  InviteMemberState _state = const InviteMemberState();
  InviteMemberState get state => _state;
  bool _disposed = false;
  final _operation = OperationId();
  bool get canEdit =>
      !state.busy && !state.uncertain && !state.sent && canManage();
  void _emit(InviteMemberState value) {
    if (!_disposed) {
      _state = value;
      notifyListeners();
    }
  }

  void selectRole(StaffRole role) {
    if (canEdit) _emit(state.copyWith(role: role));
  }

  Future<void> submit(String name, String email) async {
    if (!canEdit) return;
    final errors = <String, String>{};
    if (name.trim().isEmpty || name.trim().runes.length > 100) {
      errors['name'] = 'Informe um nome com até 100 caracteres.';
    }
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email.trim()) ||
        email.trim().length > 254) {
      errors['email'] = 'Informe um e-mail válido.';
    }
    _emit(state.copyWith(errors: errors, message: null));
    if (errors.isNotEmpty) return;
    await _send(
      () => repository.invite(name, email, state.role, _operation.value),
    );
  }

  Future<void> reconcile() async {
    if (!state.uncertain || state.busy) return;
    await _send(() => repository.reconcile(_operation.value));
  }

  Future<void> _send(Future<Result<TeamReceipt>> Function() action) async {
    final key = contextKey();
    _emit(state.copyWith(busy: true, message: null));
    try {
      if (!await authorize() ||
          _disposed ||
          !canManage() ||
          contextKey() != key) {
        return;
      }
      final result = await action();
      if (_disposed || !canManage() || contextKey() != key) return;
      switch (result) {
        case Success<TeamReceipt>(:final value):
          final uncertain = value.state == 'pending';
          _emit(
            state.copyWith(
              uncertain: uncertain,
              sent: value.state == 'confirmed',
              message: value.state == 'confirmed' && value.code == null
                  ? 'Convite enviado. A pessoa receberá um e-mail para definir a senha.'
                  : receiptMessage(value),
            ),
          );
          if (!uncertain) _operation.complete();
        case Failure<TeamReceipt>(:final failure):
          final uncertain = const [
            FailureCode.network,
            FailureCode.timeout,
            FailureCode.unknown,
          ].contains(failure.code);
          _emit(
            state.copyWith(uncertain: uncertain, message: teamFailure(failure)),
          );
          if (!uncertain) _operation.complete();
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
