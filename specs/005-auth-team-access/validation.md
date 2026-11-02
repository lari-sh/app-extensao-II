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


## T027 — aumento de cobertura — 2026-11-02

Solicitação: ampliar a cobertura de testes. Acrescentados 47 testes, com fakes de
Repository controlados por resultado/Completer, sem alteração do código de produção.

- ViewModels: paginação e filtros, autorização perdida durante requisição,
  respostas tardias após troca de identidade/dispose, conflito de versão,
  bloqueio de duplicatas durante busy/resultado incerto e reconciliação usando
  a chave original. Aceite verifica prova de senha, impede uso de prova de outro
  convite e preserva a senha salva ao repetir somente a confirmação.
- Services/Repositories: métodos e payloads HTTP, erros traduzidos sem dados
  internos, senha isolada no SDK, versionamento, ausência de identidade/perfil
  fornecidos pelo cliente no aceite e rejeição de dados malformados.
- Widgets: confirmação/desistência de alteração de perfil/desativação,
  restauração, cancelamento/reenvio de convite, reconciliação, paginação e
  atualização da listagem após retorno do formulário.

Validação: `flutter analyze --no-pub` sem problemas; formato aprovado;
`flutter test --no-pub --coverage`: **347 testes PASS**, 54 s.
Mesma base de 89 arquivos/6.171 linhas instrumentadas de produção:
**5.331 → 5.471 linhas cobertas; 86,39% → 88,66% (+2,27 pontos percentuais)**.
Equipe/convites/callbacks, mesmos 11 arquivos/708 linhas:
**537 → 677 linhas cobertas; 75,85% → 95,62% (+19,77 pontos percentuais)**.
Relatório local em coverage/lcov.info. Métrica de linhas, não de branches ou
percentual de jornadas ponta a ponta. Nenhuma exclusão adicional de arquivos
foi aplicada à comparação. SQL/Deno/Android não foram repetidos nesta etapa de
testes Flutter; a CI remota do novo commit ainda precisa concluir.


## Ampliação global — etapa fotos — 2026-11-02

15 novos testes de PhotoUploadViewModel PASS: permissão/validação/erro nativo,
recuperação manual sem upload automático, troca de animal durante recuperação,
estados terminais do job, retry explícito com a mesma chave e reconciliação com
falha de acesso/transporte. Analyze sem problemas. Código de produção preservado.
Percentual global será medido na suíte completa após medicamentos e navegação.


## Ampliação global — etapa medicamentos — 2026-11-02

12 novos testes de MedicationEditorViewModel PASS: horários fixos/intervalos,
remoção e ajuste de horários, datas, validações de período e duplicata, busca de
tratamento em paginação, proteção contra cursor sem avanço, retomada após falha
de listagem, confirmação de operação divergente e reconciliação com erro.
Negação de acesso antes de salvar mantém o rascunho e não envia a escrita.
Analyze sem problemas. Medição global final ainda pendente nesta etapa.


## Ampliação global — navegação, permissões e medição final — 2026-11-02

13 novos Widget Tests do AppRouter PASS: configuração ausente, rotas privadas,
funcionário impedido de consultar equipe, administrador abrindo equipe/convite,
argumentos/serviços de medicação ausentes e rota desconhecida. São rotas reais,
com Services/Repositories substituídos somente pelas dependências controladas de teste.

Fechamento das três etapas: **40 testes novos** (15 fotos, 12 medicamentos,
13 navegação/permissões). `flutter analyze --no-pub`: sem problemas.
`flutter test --no-pub --coverage`: **387 testes PASS**, 57 segundos.
Formato conferido e nenhuma alteração de produção nesta ampliação.

**Cobertura global: 88,66% → 90,63% (+1,97 pontos percentuais)**.
Linhas cobertas: **5.471 → 5.593**, mesma base de **6.171 linhas/89 arquivos**.
Nenhuma exclusão adicional, redução do denominador ou remoção de teste.
Equipe/convites permanece em 95,62% (677/708 linhas).

| Arquivo priorizado | Antes | Depois | Linhas cobertas |
| --- | ---: | ---: | ---: |
| photo_upload_view_model.dart | 75.14% | 96.69% | 175/181 |
| medication_editor_view_model.dart | 84.94% | 99.22% | 382/385 |
| app_router.dart | 74.24% | 86.46% | 198/229 |

Métrica de linhas instrumentadas de produção em coverage/lcov.info, sem código
gerado; não representa branches nem percentual de jornadas ponta a ponta.
SQL/Deno/Android não foram repetidos para alterações apenas em testes Flutter.
As etapas de fotos e medicamentos foram enviadas separadamente nos commits
8388be8 e e8c880d. A CI remota do novo fechamento ainda precisa concluir.


## Meta de 95% — fluxo público — 2026-11-02

13 novos testes PASS de catálogo, favoritos e ficha pública: falhas tipadas e
inesperadas, fotos, filtros inválidos/limpeza, bloqueio de escrita duplicada e
revalidação de disponibilidade antes de copiar interesse de adoção. Analyze sem
problemas. Código de produção preservado; medição global ao fechar as etapas.


## Meta de 95% — composição e inicialização — 2026-11-02

3 Widget Tests PASS: composição produtiva registra os contratos e inicia como
visitante sem consultar/escrever dados remotos; configuração ausente exibe
aviso; SDK inicializa com adaptadores de preferências locais de teste. Cliente
SDK criado/descartado em runAsync para manter seu worker fora do FakeAsync.
Armazenamento oficial em memória, sem ler preferências reais; dependência de
teste já transitiva documentada no plano. Analyze sem problemas.


## Meta de 95% — programação e segurança clínica — 2026-11-02

17 testes novos PASS: seletores de início/término, edição/remoção de horários,
unidades do intervalo, reconciliação pelo rodapé e recarga após falha. Detalhes
clínicos testam revisão/intervalo, erro de leitura, cursor cíclico, exceção de
histórico, confirmação divergente e falhas ao reconciliar aplicação. Não há
confirmação otimista de medicação quando o recibo não corresponde à operação.
Analyze sem problemas; produção preservada nesta etapa.


## Meta de 95% — callbacks e navegação privada — 2026-11-02

8 testes novos PASS: eventos reais do SDK com HTTP simulado, entrega única de
convite para observador imediato/tardio, troca do cliente e cancelamento da
assinatura. AuthApplication encaminha convite para verificação no servidor sem
liberar manejo. Painel real integra calendário, atualização ao retomar o app e
entrada Equipe; editor novo/existente integra medicações e descarta conteúdo
quando backend/evento concordam com a revogação. Analyze sem problemas.
Medição anterior a esta etapa: 93,45%, 420 testes PASS, mesma base de 6.171 linhas.


Correção do gate da etapa de callbacks: a primeira análise apontou somente um
import redundante de dart:async no teste. Import removido e análise repetida;
o aviso não afetava os testes funcionais, mas impedia considerar o gate limpo.


## Meta de 95% — cadastro e contratos clínicos — 2026-11-02

7 testes novos PASS: listagem/gravação/histórico/recibo de medicamentos pelo
Service HTTP; flags públicas e tipo de registro clínico; leitura negada, epoch
alterado durante leitura, exceção de carga e gravação/reconciliação incerta.
Nova tentativa de salvar um cadastro incerto consulta o recibo antes de repetir.
Analyze limpo. Medição intermediária anterior: **94,20% (5.813/6.171)**,
428 testes Flutter PASS. A meta de 95% ainda não estava atingida nessa medição.


## Meta de 95% — sessão e fechamento — 2026-11-02

6 testes novos PASS de SessionViewModel: exceção ao restaurar/revalidar,
assinatura inválida, erro no stream, ticket de login obsoleto e falha ao sair.
Todos verificam bloqueio das capacidades privadas e mensagens sem erro bruto.

`flutter analyze --no-pub`: sem problemas. Formato conferido.
`flutter test --no-pub --coverage`: **441 testes PASS**, cerca de 1 minuto.
Resultado global: **95,09% (5.868/6.171 linhas instrumentadas)**, 89 arquivos.
Base anterior: 90,63% (5.593/6.171), mesmos arquivos e denominador.
Ganho: **275 linhas cobertas, +4,46 pontos percentuais e 54 testes novos**.
Equipe/convites/callbacks: **98,45% (697/708)**.

A meta foi atingida sem excluir arquivos adicionais, remover testes ou alterar
código de produção. A única dependência declarada foi o adaptador oficial de
preferências para teste, já transitivo, com justificativa no plano. O percentual
é de linhas Flutter instrumentadas, não de branches, segurança absoluta ou
jornadas ponta a ponta. Código gerado não compõe esta métrica.

Etapas validadas e enviadas separadamente: fluxo público e823f08; composição
1fe2dbf; fluxos clínicos 5a1adb0; callbacks/navegação b4d475c (aviso de estilo
corrigido em 9ac04df); cadastro/contratos 9b023d5; sessão no commit desta seção.
A última CI consultada (41392409043, SHA 9b023d511091618cdd91366a356112ac24175d2d)
estava em andamento. A CI remota do fechamento ainda precisa concluir.
SQL/Deno/Android não foram repetidos nesta ampliação de testes Flutter.


## Revisão da CI — falha Android e correção — 2026-11-02

Run 41392651726, SHA 463aa6003fbfeaf3df9de42782e0bb553b10c723:
Flutter PASS (441 testes, geração/formato/analyze); backend PASS (337 pgTAP,
19 Deno e fluxos HTTP). Android: 7 das 8 jornadas passaram; authentication_flow
falhou ao localizar a mensagem visível de conta sem autorização. Delivery foi
bloqueado pela falha Android; esta execução não aprovou a entrega.

A consulta local direta confirmou sessão válida de fixture-nonstaff e
is_staff_active=false/can_manage_team=false. O teste original passou localmente,
indicando dependência de timing/viewport da CI. O helper podia aceitar um estado
anterior e consultar o texto antes de pintá-lo ou trazê-lo à área visível.
Ajuste: exigir estado distinto do anterior, aguardar o frame terminal e rolar
até o feedback. As asserções de senha errada, negação de acesso, restauração,
revogação e logout foram preservadas. Nenhuma alteração de layout ou autorização.

Jornada corrigida PASS no emulator-5554 (14 s após instalação); analyze limpo.
Nova CI completa será conferida antes de concluir esta revisão.


## CI aprovada após correção — 2026-11-02

Execução: [41395580798](https://github.com/lari-sh/app-extensao-II/actions/runs/41395580798).
Commit de código validado: **62d40f40ad5e22e671e56b3fc72a5e2a62b16fe9**, branch developer.
Status consultado: **completed / success**, quatro jobs aprovados.

| Job | Resultado conferido |
| --- | --- |
| flutter | Geração determinística, formato, analyze e **441 testes PASS** |
| backend | **337 testes SQL**, **19 testes Deno**, fluxos HTTP e concorrência PASS |
| android | **8 jornadas PASS**, incluindo login/conta sem vínculo/restauração/revogação e convites |
| deliver | APK debug compilado e artefato publicado |

As oito jornadas conferidas nos logs são catálogo público, ficha do visitante,
autenticação, painel de manejo, cadastro/edição, calendário de medicamentos,
contatos de adoção e convite/aceite da equipe. O cenário de autenticação que
falhou no run anterior passou mantendo as asserções de segurança.

Artefato: [abrigo-dos-anjos-android-debug · 13119744573](https://github.com/lari-sh/app-extensao-II/actions/runs/41395580798/artifacts/13119744573),
76.916.598 bytes, não expirado na consulta, retenção até 2026-11-09 06:08:31 UTC.
O workflow inclui APK debug e validation.txt com SHA/run. Não é publicação em loja.

A medição local registrada continua **95,09%** de linhas; a CI confirmou execução
completa dos 441 testes, sem publicar percentual LCOV próprio nos logs.
O APK normal também foi reinstalado/aberto no emulador local após o teste focado.
Esta seção encerra a revisão da CI das alterações de código acima; não marca como
concluídos persistência de sessão, recuperação de senha ou validação iOS pendentes.


## T017 — armazenamento de sessão — 2026-11-02

Adaptador LocalStorage serializado, separado do armazenamento PKCE do SDK.
9 testes PASS: escolha marcada/desmarcada, restauração após recriação, limpeza de
legado, erro de preferência/gravação, login antigo invalidado por logout/nova
escolha e refresh concorrente. Teste com o armazenamento PKCE real do SDK e
preferências em memória confirma que limpar a sessão preserva o verificador.
Sessão só é confirmada como persistente após escrita durável; falha retorna
Result e mantém o adaptador fechado. Analyze sem problemas. Integração de UI e
validação Android continuam pendentes nas tarefas T018/T019.
