import '../../domain/models/session_access.dart';
import '../../domain/models/team_access.dart';
import '../../domain/repositories/team_repository.dart';
import '../../utils/result.dart';
import '../services/team_service.dart';
import 'repository_result.dart';

final class TeamRepositoryImpl implements TeamRepository {
  TeamRepositoryImpl(this.service);
  final TeamService service;
  Map<String, Object?> _object(Object? value) =>
      (value as Map).cast<String, Object?>();
  String _text(Map<String, Object?> data, String key) {
    final value = data[key];
    if (value is! String || value.isEmpty) {
      throw const FormatException('Invalid team field');
    }
    return value;
  }

  int _number(Map<String, Object?> data, String key) {
    final value = data[key];
    if (value is! int || value < 1) {
      throw const FormatException('Invalid team number');
    }
    return value;
  }

  StaffRole _role(Map<String, Object?> data) => switch (data['role']) {
    'administrator' => StaffRole.administrator,
    'employee' => StaffRole.employee,
    _ => throw const FormatException('Invalid team role'),
  };
  TeamMember _member(Object? value) {
    final d = _object(value);
    if (d['active'] is! bool) {
      throw const FormatException('Invalid team status');
    }
    return TeamMember(
      id: _text(d, 'user_id'),
      name: _text(d, 'display_name'),
      email: _text(d, 'email'),
      role: _role(d),
      active: d['active'] as bool,
      version: _number(d, 'version'),
    );
  }

  TeamInvitation _invitation(Object? value) {
    final d = _object(value);
    final status = _text(d, 'status');
    if (!const [
      'preparing',
      'pending',
      'expired',
      'failed',
      'accepted',
      'revoked',
    ].contains(status)) {
      throw const FormatException('Invalid invitation status');
    }
    return TeamInvitation(
      id: _text(d, 'id'),
      name: _text(d, 'name'),
      email: _text(d, 'email'),
      role: _role(d),
      status: status,
      generation: _number(d, 'generation'),
      version: _number(d, 'version'),
      expiresAt: DateTime.parse(_text(d, 'expires_at')),
      deliveryState: _text(d, 'delivery_state'),
      retryAfter: (d['retry_after'] as int?) ?? 0,
      passwordReady: d['password_ready'] == true,
    );
  }

  TeamReceipt _receipt(Map<String, Object?>? d) {
    if (d == null) throw const FormatException('Missing receipt');
    // Member operations predate the invitation envelope and return only member.
    final state = d['state'] ?? (d['member'] != null ? 'confirmed' : null);
    if (!const ['pending', 'confirmed', 'failed'].contains(state)) {
      throw const FormatException('Invalid receipt');
    }
    return TeamReceipt(
      state: state as String,
      code: d['code'] as String?,
      invitation: d['invitation'] == null ? null : _invitation(d['invitation']),
      member: d['member'] == null ? null : _member(d['member']),
    );
  }

  Future<Result<TeamReceipt>> _rpc(
    String name,
    Map<String, Object?> parameters,
  ) => mapRepositoryResult(() => service.request(name, parameters), _receipt);
  @override
  Future<Result<TeamPage>> members({required bool active, String? cursor}) =>
      mapRepositoryResult(
        () => service.request('list_team_members', {
          'p_status': active ? 'active' : 'inactive',
          'p_cursor': cursor,
        }),
        (d) {
          if (d == null ||
              d['items'] is! List ||
              (d['items'] as List).length > 50) {
            throw const FormatException('Invalid page');
          }
          return TeamPage(
            members: (d['items'] as List).map(_member).toList(),
            nextCursor: d['next_cursor'] as String?,
          );
        },
      );
  @override
  Future<Result<TeamPage>> invitations({String? cursor}) => mapRepositoryResult(
    () => service.request('list_team_invitations', {
      'p_status': 'pending',
      'p_cursor': cursor,
    }),
    (d) {
      if (d == null ||
          d['items'] is! List ||
          (d['items'] as List).length > 50) {
        throw const FormatException('Invalid page');
      }
      return TeamPage(
        invitations: (d['items'] as List).map(_invitation).toList(),
        nextCursor: d['next_cursor'] as String?,
      );
    },
  );
  @override
  Future<Result<TeamReceipt>> invite(
    String name,
    String email,
    StaffRole role,
    String key,
  ) => mapRepositoryResult(
    () => service.send({
      'action': 'invite',
      'operation_key': key,
      'name': name.trim(),
      'email': email.trim().toLowerCase(),
      'role': role.name,
    }),
    _receipt,
  );
  @override
  Future<Result<TeamReceipt>> resend(TeamInvitation invitation, String key) =>
      mapRepositoryResult(
        () => service.send({
          'action': 'resend',
          'operation_key': key,
          'invitation_id': invitation.id,
          'expected_version': invitation.version,
        }),
        _receipt,
      );
  @override
  Future<Result<TeamReceipt>> cancel(TeamInvitation invitation, String key) =>
      _rpc('cancel_team_invitation', {
        'p_invitation_id': invitation.id,
        'p_expected_version': invitation.version,
        'p_operation_key': key,
      });
  @override
  Future<Result<TeamReceipt>> change(
    TeamMember member,
    StaffRole role,
    bool active,
    String key,
  ) => _rpc('change_team_member', {
    'p_user_id': member.id,
    'p_expected_version': member.version,
    'p_role': role.name,
    'p_active': active,
    'p_operation_key': key,
  });
  @override
  Future<Result<TeamReceipt>> reconcile(String key) =>
      mapRepositoryResult(() => service.reconcile(key), _receipt);
  @override
  Future<Result<TeamInvitation?>> ownInvitation() => mapRepositoryResult(
    () => service.request('get_my_invitation', {}),
    (d) => d == null ? null : _invitation(d),
  );
  @override
  Future<Result<Unit>> definePassword(String password) =>
      mapRepositoryResult(() => service.definePassword(password), (v) => v);
  @override
  Future<Result<TeamReceipt>> accept(TeamInvitation invitation, String key) =>
      _rpc('accept_team_invitation', {
        'p_expected_generation': invitation.generation,
        'p_expected_version': invitation.version,
        'p_operation_key': key,
      });
}
