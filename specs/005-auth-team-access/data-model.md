# Modelo de dados proposto

- **staff_members**: user_id existente, display_name, active, role
  (administrator/employee), version crescente, created_at/updated_at. IDs de
  autoria existentes mantidos. Role/active somente por comandos autorizados.
- **team_invitations** (privado): id, normalized_email, display_name, intended_role,
  invited_auth_user_id, generation, status, expires_at, created_by, accepted_by,
  accepted_at, version e timestamps. Uma reserva corrente por e-mail. Status:
  preparing → pending → accepted; preparing → failed; pending → revoked/expired.
  Reenvio cria nova geração pendente e invalida a anterior, sem duplicar vínculo.
- **team_operations** (privado): operation_key, actor_id, command, target_id,
  payload_fingerprint, state (pending/confirmed/failed), receipt. Não armazenar
  senha ou tokens/link de convite. Chave fica vinculada ao autor e payload.
- **team_access_events** (privado append-only): id, actor_id, actor_label,
  target_id, action, previous_role/state, resulting_role/state, server_time,
  operation_key. Convite/cancelamento/aceite/perfil/desativação/restauração.
- **Local preference**: remember_session boolean; sessão serializada somente no
  adaptador SDK autorizado pela preferência. Verificador PKCE separado, com ciclo
  próprio; senha nunca persiste. RecoveryState/TeamState imutáveis e sem tokens.

Invariantes: último administrador protegido por lock; aceite atômico de geração
vigente, sem autoelevação; revogação efetiva no servidor; listagens não expõem
auth.users inteiro a clientes. Visitantes/funcionários não leem convites/auditoria.
Prazo proposto 1 h e cooldown 60 s conferidos pelo relógio do servidor.
