# Contratos propostos — sem implementação

Todos os comandos devolvem Result tipado na fronteira do app. Respostas públicas
de recuperação não revelam se o e-mail existe. Segredos permanecem no servidor.

## Função de convite

POST team-invitation: JWT da pessoa atual, operation_key e comando invite/resend,
nome/e-mail/perfil ou invitation_id + expected_version. Revalidar administrator
na reserva e finalização. Resultado confirmed/pending_reconciliation/failed, com
convite sem URL/token. Mesmo key/payload devolve recibo; key/payload diferente
conflita. Falhas Auth/SMTP viram códigos amigáveis, não mensagens cruas.
Conta sem vínculo mas já registrada: existing_account; não alterar senha/role.

## RPCs

- list_team_members(status, cursor): administrator, paginação estável 50/página.
- list_team_invitations(status, cursor): administrator, mesma regra.
- get_team_operation(operation_key): só autor atual autorizado, recibo sanitizado.
- cancel_team_invitation(id, expected_version, operation_key): revoga geração.
- change_team_member(user_id, expected_version, role, active, operation_key):
  administrador atual, recusa self-demotion/self-deactivation/último admin.
- get_my_invitation(): identidade Auth verificada, somente convite do destinatário,
  devolve abrigo/nome/perfil/validade/status, nunca aceita ID/e-mail arbitrário como
  prova de identidade. Convite inválido retorna indisponível.
- accept_team_invitation(expected_generation, expected_version, operation_key):
  verificação de destinatário, prazo, vínculo Auth reservado e senha definida;
  ativa vínculo uma vez. Perfil deriva do convite, não da requisição.
- access_context(): manter campos existentes e acrescentar role/capacidades;
  DB consulta acesso atual, não confia em estado da tela.

## Repositories e Services

TeamRepository: listMembers/listInvitations, invite/resend/cancel/changeMember,
currentInvitation/accept/reconcile. AuthRepository: signIn com rememberSession,
requestPasswordReset, updateRecoveredPassword e fluxo de estado de recuperação.
Services isolam SDK, links e armazenamento. Nenhum Supabase User/AuthState chega
à View ou ao domínio. Estado incerto bloqueia repetição cega e oferece verificar.

## Resultados verificáveis

unauthenticated, forbidden, conflict, expired_invitation, revoked_invitation,
already_member, existing_account, invalid_input, last_administrator,
rate_limited, network, timeout e unknown. Mapping de UI em português, sem expor
SQL/JWT/e-mail de terceiros. Senha definida deve ser comprovada pelo fluxo servidor,
não por booleano aceito do cliente; a implementação precisa testar essa prova.
