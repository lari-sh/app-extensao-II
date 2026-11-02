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


## Backend de convites e aceite — 2026-11-02

Migration 202611010017 aplicada sem reset e sem promover contas existentes.
Envio/reenvio usa Function com identidade verificada, reserva durável, geração,
cooldown, quota e reconciliação sem segundo envio automático em timeout.
Cancelamento/aceite são transacionais, com recibo idempotente e auditoria.
O aceite exige senha definida após confirmação; a credencial aleatória criada
pelo próprio Auth na verificação não concede acesso. A referência fica privada.

Regressão SQL: 14 arquivos, 337 testes PASS. Handler: 7 testes Deno PASS.
Jornada HTTP real local PASS: e-mail Mailpit, callback, senha mínima, aceite/replay,
funcionário sem gestão, role forjada, reenvio/link antigo, cancelamento e corrida
aceite/cancelamento. Somente fixtures próprias @example.test; limpeza por prefixo
único, preservando os dados do usuário. Nova jornada adicionada ao job backend.
Telas Flutter, Android e CI remota desta etapa ainda pendentes.

## T009 — camada de dados Flutter

Modelos Freezed, contrato TeamRepository e Service Supabase isolado implementados.
10 novos testes de Service/Repository PASS: paginação, imutabilidade, perfil
desconhecido, resposta inválida, identidade normalizada, versionamento e erros
seguros em português. Analyze sem problemas. Interface e Android pendentes.


## Telas de equipe e aceite — 2026-11-02

Equipe (ativos/convites/inativos), formulário de convite, alteração de perfil,
desativação/reativação e aceite implementados no Flutter com ViewModels e estados
Freezed. Entrada Equipe somente para administrador. A guarda protege também rota
direta e descarta o conteúdo ao trocar de perfil. Voltar permanece à esquerda.
Reenvio/cancelamento usam versão e recibos; envio incerto bloqueia nova submissão
até reconciliação com a mesma chave. Aceite define senha e encerra sessão antes
do login normal. Callback permite somente scheme/host/path próprios de convite;
URI e credenciais não atravessam o Service. Recovery continua etapa separada.

Android real PASS (20 s após instalar): login administrador, equipe, convite pela
interface, e-mail Mailpit, intent VIEW genuíno, definição de senha, aceite, login
funcionário, manejo e rota direta de equipe negada. Conta/convite com prefixo único
@example.test, sem alterar usuários/animais existentes. Emulador teve system_server
zumbi e erro Broken pipe na instalação inicial; foi reaberto sem apagar dados e
a jornada completa passou. Links iOS configurados, execução iOS ainda pendente.
Nova jornada adicionada à CI preservando as sete anteriores. CI 41382654913 do
commit d92b340 falhou em formato, antes do backend; formato corrigido nesta etapa.
CI remota das telas e link com processo encerrado ainda a confirmar.


## Medição solicitada — 2026-11-02

`flutter test --no-pub --coverage`: 298 testes PASS, 54 s.
LCOV: 5.295/6.143 linhas instrumentadas (86,20%), em 89 arquivos de produção;
arquivos gerados excluídos (não constavam no LCOV desta execução).
Recorte equipe/convites/callbacks: 501/680 linhas (73,68%), 11 arquivos.
SQL, Deno e Android são evidências adicionais, sem compor esse percentual.
Medição intermediária antes dos últimos ajustes visuais e dois novos casos de
texto ampliado/reconciliação de senha; será repetida no fechamento desta etapa.


## Fechamento da etapa de convites — 2026-11-02

Após os ajustes finais, `flutter test --no-pub --coverage`: **300 testes PASS**,
44 s; **86.39%** (5331/6171 linhas), 89 arquivos.
Equipe/convites/callbacks: **75.85%** (537/708), 11 arquivos.
Métrica de linhas LCOV de produção instrumentada, sem código gerado; não é
cobertura de branches nem percentual de jornadas ponta a ponta. As jornadas
Android e os testes SQL/Deno não entram no cálculo. Ainda existem caminhos de
erro/reconciliação sem teste de linhas.

Texto ampliado 1,8x em 320 px nas três telas PASS. Resposta perdida na definição
de senha reconciliada com prova do servidor, sem nova escrita de senha: PASS.
Análise sem problemas e formato: 252 arquivos, nenhuma mudança necessária.
Android repetido com layout final: convite/intent/aceite/login funcionário/rota
restrita PASS, 18 s após instalação. Repetição usa novo destinatário único,
sem depender de conta já aceita em execução anterior.

Checkbox de persistência, recuperação de senha, cold-start ampliado e iOS seguem
pendentes nas tarefas próprias. CI remota da nova interface ainda não confirmada.


APK normal de desenvolvimento recompilado, instalado e aberto no emulator-5554
após o teste de integração. Fixtures de equipe removidas por prefixo exclusivo.
CI da interface: run 41387157608, SHA 0cd6b84b9011c3a2f178c81705dfbfda2fb6ac53,
em andamento na última consulta; ainda não equivale a entrega remota aprovada.
