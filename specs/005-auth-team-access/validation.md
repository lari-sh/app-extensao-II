# Evidências — planejamento e proposta

2026-11-01: spec, plano, pesquisa, modelo, contratos e 26 tarefas escritos.
Decisão expressa: primeiro administrador provisionado; demais convites no app,
com perfis Administrador e Funcionário. A skill de plano foi executada com feature
explícita e NO_PERSIST; git permanece na developer. Nenhum hook de extensão
registrado (.specify/extensions.yml ausente na verificação).

Constitution Check antes/após desenho técnico registrado em plan.md. SDK/plugins
somente em Services/composição, permissões server-side, Result, nomes/idioma,
testes por regra/tela e commits por contexto previstos. UI nova aguarda T003.
Research de convite conferiu fontes oficiais: sem PKCE no Admin Invite, conta
existente e reenvio tratados explicitamente, segredo restrito ao servidor.

Checklist de requisitos nesta etapa: decisões confirmadas registradas; cada uma
das quatro histórias tem tarefas e testes; permissão de funcionário e último
administrador têm negações; falhas e operação incerta não são sucesso de envio.
check-prerequisites retornou plan.md/tasks.md e documentos da feature.

Ainda não executados: implementação, Flutter/backend/Android/iOS e envio de e-mails.
Proposta visual/interações serão verificadas separadamente; aprovação pendente.

## T002 — proposta visual conferida

DESIGN-TEAM-001 em design/team-access-proposal.html. Sete visualizações conferidas
em 320, 390 e 1440 px: equipe, convite, aceite, recuperação, nova senha, convite
expirado e contexto do painel. Voltar à esquerda verificado geometricamente;
sem overflow horizontal do conteúdo/página e sem erros de JavaScript.
Simulações conferidas: envio/duplicata, cooldown de reenvio, cancelamento,
alteração de perfil, desativação, proteção do próprio administrador, visibilidade
por perfil, confirmação de senha divergente/correta, recuperação neutra e nova
senha. São interações HTML em memória, não testes Flutter/Supabase do produto.

Capturas visuais inspecionadas: equipe, convite e aceite, com logo/paleta atual.
Capturas de todas as sete telas e visão geral em design/previews/team/.
Protótipo principal preservado byte a byte após remover somente o novo script de
link lateral, comparado com a referência Git. Nenhum artboard anterior alterado.
MCP retornou Transport closed; nova página sincronizada no arquivo local do
projeto conhecido e seu link acrescentado pontualmente ao protótipo. HTTP 200
confirmado na página servida. Abertura solicitada no painel do chat; ferramenta
retornou queued. Link direto também está em design-approval.md.

Rastreabilidade conferida: 17 IDs de requisitos presentes nas tarefas, 26 IDs
únicos; T001/T002 concluídas, T003 de aprovação permanece desmarcada. Nenhum
arquivo lib/, pubspec, migration ou Function implementado nesta entrega.
Flutter/backend/Android não repetidos, pois o escopo é planejamento/protótipo.
A aprovação do usuário ainda é necessária e não foi presumida.

## Aprovação recebida

2026-11-01: usuário respondeu Aprovar o design ao cartão DESIGN-TEAM-001 para
Equipe, Convidar pessoa, Aceitar convite, Recuperar acesso e Nova senha. T003
concluída; novas Views liberadas após backend/contratos/testes necessários.
A aprovação não equivale a validação de implementação ou envio de e-mails.

## T004/T005 — fundação de autorização

Testes escritos antes da migration: execução inicial falhou pela ausência de role.
Migration 202611010016 aplicada atomicamente apenas ao banco local existente, sem
reset/downgrade/remoção de cadastros, e registrada no histórico local pelo CLI.
37 casos pgTAP novos aprovados: empregado/visitante negados, metadados não elevam
perfil, bootstrap restrito e pendente, versionamento/replay, auditoria única,
último administrador protegido e perda de capacidade com sessão ainda válida.

team_foundation_flow.py provou concorrência real: dois administradores aguardam
no mesmo lock; um altera o outro; o segundo perde a autorização ao adquirir lock
após o primeiro commit. Uma alteração, um administrador e um evento permanecem.
Fixtures removidas pelo harness, sem tocar em animais/medicações do usuário.
Nova jornada de fundação acrescentada ao job backend da CI.

Regressão local de banco: 13 arquivos, 293 testes PASS após isolar fixtures antigas
de medicação que presumiam banco vazio. Essa correção foi commitada separadamente.
PostgreSQL ainda não concedeu papel administrador a nenhuma conta existente.
T005 entrega estrutura e reserva técnica; envio/aceite de e-mail ainda pendentes.
T006/Flutter, convites, telas, persistência e recuperação ainda não implementados.
CI remota desta nova fundação não confirmada nesta etapa.

## T006 — capacidade administrativa no Flutter

SessionAccess/SessionState imutáveis passaram a expor perfil e canManageTeam.
SupabaseAuthService lê somente o access_context verificado; AuthRepository exige
perfil administrator e capacidade explícita concordantes, com membro ativo e
sessão não expirada. Campos ausentes, desconhecidos ou contraditórios não concedem
gestão de equipe. Nenhuma decisão de perfil adicionada a Widgets.

Durante restauração/revalidação/login, a capacidade fica bloqueada. Rebaixamento
mantém manejo de funcionário, mas troca a geração privada para descartar contexto
administrativo anterior. Expiração/saída revogam a capacidade e escondem o perfil.
Novos casos de domínio, Service HTTP mockado, Repository e SessionViewModel escritos
antes do código; teste inicial falhou por StaffRole ausente. Geração Freezed
executada; 277 testes Flutter PASS e analyze sem problemas (35,6 s), formato e diff
conferidos. Banco permanece na regressão 293/293 aprovada da etapa anterior.
Ainda sem TeamScreen, envio de e-mail, checkbox habilitado ou recuperação integrada;
esta etapa implementa o contrato e as regras que essas funcionalidades usarão.
Android e CI remota do novo código ainda não confirmados nesta etapa.
