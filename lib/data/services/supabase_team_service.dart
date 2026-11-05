import 'package:supabase_flutter/supabase_flutter.dart';
import '../../utils/app_failure.dart';
import '../../utils/result.dart';
import 'service_result.dart';
import 'team_service.dart';

final class SupabaseTeamService implements TeamService {
  SupabaseTeamService(this.client);
  final SupabaseClient client;
  static const _messages = {
    'existing_account':
        'Este e-mail já possui uma conta. Solicite ajuda ao administrador técnico.',
    'already_member': 'Esta pessoa já faz parte da equipe.',
    'invitation_exists': 'Já existe um convite para este e-mail.',
    'invitation_opened':
        'O convite já foi aberto. Cancele-o antes de criar outro.',
    'invitation_cooldown': 'Aguarde um minuto antes de reenviar o convite.',
    'invitation_rate_limited':
        'Limite de convites atingido. Tente novamente mais tarde.',
    'invitation_unavailable': 'Este convite não está mais disponível.',
    'invitation_version_conflict': 'O convite mudou. Atualize a lista.',
    'member_version_conflict': 'O acesso mudou. Atualize a equipe.',
    'administrator_required':
        'Somente administradores podem gerenciar a equipe.',
    'password_required': 'Defina sua senha antes de aceitar o convite.',
  };
  // The typed wrapper preserves a safe message without returning SDK exceptions.
  Future<Result<T>> _safe<T>(Future<T> Function() action) async {
    String? message;
    final result = await serviceResult(() async {
      try {
        return await action();
      } on PostgrestException catch (error) {
        message = _messages[error.message];
        rethrow;
      } on FunctionException catch (error) {
        if (error.details is Map) {
          message = _messages[(error.details as Map)['code']];
        }
        rethrow;
      }
    });
    return message == null
        ? result
        : Failure(
            AppFailure(FailureCode.validation, fieldErrors: {'team': message!}),
          );
  }

  Map<String, Object?> _object(Object? value) {
    if (value is! Map) throw const FormatException('Invalid team response');
    return Map<String, Object?>.from(value);
  }

  @override
  Future<Result<Map<String, Object?>?>> request(
    String name,
    Map<String, Object?> parameters,
  ) => _safe(() async {
    final data = await client.rpc(name, params: parameters);
    return data == null ? null : _object(data);
  });
  @override
  Future<Result<Map<String, Object?>>> send(Map<String, Object?> body) => _safe(
    () async => _object(
      (await client.functions.invoke('team-invitation', body: body)).data,
    ),
  );
  @override
  Future<Result<Map<String, Object?>>> reconcile(String key) => _safe(
    () async => _object(
      (await client.functions.invoke(
        'team-invitation',
        method: HttpMethod.get,
        queryParameters: {'operation_key': key},
      )).data,
    ),
  );
  @override
  Future<Result<Unit>> definePassword(String password) => _safe(() async {
    await client.auth.updateUser(UserAttributes(password: password));
    return Unit.value;
  });
}
