# Tarefas — acesso e convites da equipe

Branch developer. Requisitos em spec.md; arquitetura em plan.md; contratos em
contracts/team-access.md. Proposta não equivale a implementação nem aprovação.

## Planejamento e gate visual

- [x] T001 Registrar spec.md, plan.md, research.md, data-model.md, contracts/team-access.md e quickstart.md conforme decisão do primeiro administrador provisionado e equipe por convite. [005-FR-001, 005-FR-002, 005-CR-001]
- [x] T002 Preparar design/team-access-proposal.html com equipe, convite, aceite, recuperação e nova senha; validar interações/responsividade e registrar design-approval.md como pendente. Proposta DESIGN-TEAM-001 conferida em 320/390/1440 px, com dados simulados e preservação das telas anteriores. [005-FR-013]
- [x] T003 Obter aprovação explícita do usuário para novas telas e entrada Equipe antes de codificar UI; registrar em design-approval.md. [005-FR-013, 005-CR-003]

## Fundação de autorização

- [x] T004 Escrever supabase/tests/database/team_access.test.sql: visitante/funcionário negados, backfill employee, bootstrap restrito, último admin e concorrência/versionamento. 37 casos e corrida real em team_foundation_flow.py aprovados localmente. [005-FR-001, 005-FR-002, 005-FR-007]
- [x] T005 Implementar migration seguinte com roles, convites, operações, auditoria, RLS e access_context; escrever roteiro técnico de bootstrap em quickstart.md, sem endpoint público. Migration 202611010016 aplicada localmente sem reset; bootstrap reserva convite, não envia e-mail nem ativa vínculo antes das etapas de aceite. [005-FR-001, 005-FR-002, 005-FR-008]
- [x] T006 Atualizar lib/domain/models/session_access.dart, Services/Repository de auth e SessionViewModel; testar perda de capacidade após rebaixamento/revogação em test/data/ e test/ui/features/auth/. Perfil/capacidade conferidos no Service/Repository; sessão bloqueia equipe durante revalidação e descarta contexto após troca de perfil. 277 testes Flutter e analyze aprovados localmente. [005-FR-001, 005-FR-008]

## US1 — equipe e convites

- [x] T007 [US1] Escrever testes Deno/HTTP e SQL de envio/reenvio/cancelamento: identidade forjada, role editável, expiração, conta existente, timeout, duplicata e revogação durante envio. [005-FR-003, 005-FR-005, 005-FR-009, 005-FR-014]
- [x] T008 [US1] Implementar supabase/functions/team-invitation e RPCs de listagem/recibos/cancelamento/alteração; estados duráveis, limites e reconciliação sem expor Admin API no app. [005-FR-003, 005-FR-004, 005-FR-009]
- [x] T009 [US1] Criar modelos Freezed e TeamRepository abstrato; Service/Repository em lib/data/ com unitários em test/data/{services,repositories}/; cobrir erros tipados e paginação. [005-CR-001, 005-CR-002]
- [x] T010 [US1] Implementar TeamViewModel e InviteMemberViewModel, testes de validação/permissão/busy/dispose/conflito/estado incerto em test/ui/features/team/view_models/. [005-FR-003, 005-FR-004, 005-FR-009]
- [x] T011 [US1] Após T003, implementar TeamScreen, InviteMemberScreen e confirmação de alteração/desativação em lib/ui/features/team/views/; Widget happy path por tela, 320 px e texto ampliado, Voltar à esquerda. [005-FR-004, 005-FR-007, 005-FR-013]
- [x] T012 [US1] Após T003, integrar entrada Equipe no dashboard e rotas/composição em lib/app/; teste de rota e negação para funcionário também por URL/rota direta. [005-FR-001, 005-FR-013]

## US2 — aceite

- [x] T013 [US2] Escrever testes SQL/HTTP de get_my_invitation e aceite: prazo, geração, identidade, senha definida, replay e races com cancelamento/role alterado. [005-FR-005, 005-FR-006, 005-FR-009]
- [x] T014 [US2] Implementar aceite e auditoria atômicos, vincular destinatário confirmado e proteger role/active no servidor; impedir booleano cliente como prova de senha. [005-FR-006, 005-FR-008]
- [x] T015 [US2] Implementar Service/Repository/AcceptInvitationViewModel e unitários; diferenciar Auth callback de convite e recuperação, sem supor PKCE para inviteUserByEmail. [005-FR-006, 005-FR-012]
- [x] T016 [US2] Após T003, implementar AcceptInvitationScreen/estados inválidos, Widget happy path/expirado e links Android/iOS/templates/config local; registrar SMTP real como implantação separada. [005-FR-006, 005-FR-012, 005-FR-013]

## US3 — Permanecer logado

- [x] T017 [US3] Testar adaptador SessionStorageService: marcado/desmarcado, falha de escrita, restauração, cleanup, concorrência e preservação do verificador PKCE sem salvar senha. [005-FR-010]
- [x] T018 [US3] Implementar adaptador LocalStorage e preferência nos Services, mediar por AuthRepository, injetar no bootstrap e propagar escolha via LoginViewModel; unitários de Repository/VM. [005-FR-010, 005-CR-001]
- [ ] T019 [US3] Habilitar checkbox existente preservando layout e testar Widget, login, logout e opções durante busy; validar kill/relaunch Android nos dois modos e revogação de equipe. [005-FR-010, 005-FR-013]

## US4 — Esqueci a senha

- [x] T020 [US4] Implementar e testar requestPasswordReset/updateRecoveredPassword em AuthService/Repository, resposta neutra, rate limit, evento de recuperação e falhas de link/token sem logs sensíveis. [005-FR-011, 005-FR-012]
- [x] T021 [US4] Após T003, implementar RecoveryViewModel/ResetPasswordViewModel e telas auth; unitários de validação/busy/dispose e Widget happy path/erro; botão existente habilitado com mesmo layout. [005-FR-011, 005-FR-013]
- [x] T022 [US4] Testar Mailpit/callback/PKCE com app aberto e encerrado, link expirado/repetido, troca efetiva de senha e retorno ao login sem manejo automático; não usar senhas de pessoas reais. [005-FR-011, 005-FR-012]

## Entrega e evidências

- [ ] T023 Criar integration_test/team_access_flow_test.dart e auth_recovery_flow_test.dart; administrador/funcionário, convite/aceite/revogação, persistência e recuperação ponta a ponta, preservando fixtures do usuário. [005-CR-002]
- [ ] T024 Executar formato/geração/analyze/test, SQL/HTTP e Android; integrar novas jornadas à CI sem remover as sete existentes; confirmar artifact/run/SHA em validation.md. [005-CR-002, 005-CR-003]
- [ ] T025 Validar links e sessão iOS em Mac/Xcode ou registrar dependência externa explicitamente, sem declarar sucesso por Windows. [005-FR-012]
- [ ] T026 Atualizar README.md, quickstart.md, validation.md e tasks.md após cada etapa validada; commits por contexto na developer e revisão de segredos/erros/dados públicos. [005-CR-003]

## Dependências

T001/T002 → T003 (UI). T004 → T005 → T006 → T007–T010 → T011/T012.
T013/T014 dependem da fundação; T015/T016 dependem do backend de aceite.
T017–T019 podem avançar independentemente dos convites, preservando a base auth.
T020–T022 reutilizam callbacks/storage e distinguem recuperação de convite.
T023/T024 após jornadas; T025 é gate de iOS separado; T026 em cada entrega.
Testes precedem implementação de suas regras. Nenhuma tarefa marcada por mera
existência de arquivo. 26 tarefas; aprovação visual DESIGN-TEAM-001 recebida em 2026-11-01.


## Reforço de cobertura solicitado em 2026-11-02

- [x] T027 Acrescentar testes unitários de paginação, concorrência, perda de acesso,
  conflito, reconciliação e aceite; testes de contratos Service/Repository e
  confirmações de ações em Widgets. 47 casos novos; 347 testes Flutter PASS.
  Cobertura global 88,66% e equipe/convites 95,62%, usando a mesma base LCOV
  anterior. Analyze e formato aprovados; evidências em validation.md. [005-CR-002]


- [x] T028 Superar 90% global priorizando fotos, medicamentos, navegação e permissões.
  40 novos testes; 387 testes Flutter PASS, analyze/formato aprovados.
  Cobertura 90,63% (5.593/6.171 linhas), sem mudança de produção ou exclusões.
  Etapas de fotos, medicamentos e rotas commitadas separadamente na developer;
  resultados por arquivo em validation.md. [005-CR-002, 005-CR-003]


- [x] T029 Atingir 95% de cobertura global com testes de comportamentos relevantes,
  preservando escopo/denominador e commits por contexto. Meta validada:
  **95,09% (5.868/6.171)**, 89 arquivos; **441 testes PASS**, 54 novos.
  Catálogo/favoritos, composição, programação/aplicação de medicações,
  navegação/callbacks, cadastro e falhas de sessão cobertos. Analyze/formato
  aprovados; CI remota do fechamento ainda pendente. [005-CR-002, 005-CR-003]


- [x] T030 Conferir a CI após a meta de cobertura, corrigir a jornada de login
  Android e documentar execução/commit/artefato. Run **41395580798**, commit
  **62d40f4**: Flutter/backend/Android/deliver PASS; 441 Flutter, 337 SQL,
  19 Deno e 8 jornadas Android aprovados. Artefato 13119744573.
  Correção e documentação em commits separados na developer. [005-CR-002, 005-CR-003]
