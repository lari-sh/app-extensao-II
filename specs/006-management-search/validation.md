# Validação — busca global administrativa 006

## Aprovação — 2026-11-02

Responsável respondeu “Aprovar revisão v2” à proposta DESIGN-SEARCH-001 v2.
T002 concluída. Branch developer, prerequisites PASS; sem checklists ou hooks de
extensão. Skill speckit-implement e arquitetura Flutter serão seguidas. Backend,
Flutter, Android e CI serão registrados separadamente após validação efetiva.
Nenhuma tarefa de implementação é marcada apenas por geração de arquivos.


## Acompanhamento na skill — 2026-11-02

Por solicitação, speckit-implement aponta para tasks.md da feature 006 e exige
atualização de estado/evidências após cada contexto validado. Sem duplicar a lista
na skill nem inserir tarefas na constituição. Frontmatter e links validados.


## T003 — códigos dos animais — 2026-11-02

Migration 202611020018 aplicada localmente com transação explícita/bloqueio e
backfill por UUID. UUIDs, fotos e relações não mudam. Código é único, não editável,
gerado só pelo servidor, permite lacunas e cresce após A9999 sem truncar.
Snapshot anterior: hashes/contagens preservados em animals (excluindo só o novo
campo), animal_internal_details, clinical_records, photo_upload_jobs,
medication_treatments e medication_applications. Dados manuais/demo preservados.

Teste red confirmou coluna ausente antes da implementação. Depois, 19 testes de
código PASS e regressão completa: **356 SQL em 15 arquivos PASS**. Inclui legado,
homônimos, >9999/bigint, rejeição de código forjado, estabilidade em edição,
rollback/lacunas e privilégios. HTTP local com duas sessões independentes PASS:
alocação concorrente distinta, replay concorrente de mesma chave com uma identidade
e código estável após renomear. Fixtures próprias removidas; nenhuma credencial
impressa. Teste HTTP incluído no job backend da CI; resultado remoto ainda pendente.

T004 (RPC de busca) e integração Flutter permanecem pendentes. Código ainda não é
exibido na UI do app; o backfill não representa conclusão da busca.


## T004 — RPC global de busca — 2026-11-02

Migration 202611020019 aditiva, sem mudar list_managed_animals/RLS. A RPC só permite
sessão/vínculo ativos, busca nome/código e os cinco filtros em todos os animais,
com total anterior à paginação, página de 25 e cursor apenas se existir próxima.
Parâmetros não incluem modo/dia/coluna. Código é igualdade normalizada, nome/cor
parciais literais; não pesquisa notas clínicas. Sem SQL dinâmico.

Red confirmou função ausente antes da implementação. Depois, **36 testes da busca
PASS**; regressão completa **392 SQL/16 arquivos PASS**. Homônimos, código, cinco
filtros, cor nula/parcial, %, _, barra/apóstrofo, fora da primeira página, página
final cheia, entrada/cursor inválidos, visitante, sem vínculo, inativo e sessão
revogada cobertos. Validação HTTP e performance constam de T009, ainda pendente.
Não foram aplicadas alterações no app Flutter nesta etapa.

## T005/T006 — contrato Flutter e Repository — 2026-11-02

Filtro imutável com cinco critérios, Service/RPC/cursor validado e Repository
com Result e código obrigatório na busca. Replays antigos continuam legíveis sem
reescrever auditoria nem fabricar código. Nenhum pacote novo.

11 testes específicos PASS; flutter analyze sem problemas; regressão completa
**485 testes PASS** com cobertura coletada. Android e CI deste contexto ainda
não validados. Interface de busca permanece pendente em T007/T008.

## T007 — ViewModel da busca — 2026-11-02

Estado Freezed, debounce 300 ms/submit imediato, cinco filtros com rascunho,
aplicar/cancelar/limpar e chips. Paginação e fotos respeitam geração, contexto
privado, acesso e dispose; dados tardios são descartados e erros saneados.
O VM não altera modo/data do dashboard. Oito testes específicos PASS cobrindo
concorrência, perda de acesso, fotos e paginação; analyze sem problemas.
Integração visual, Android, cobertura final e CI permanecem pendentes.

## T008 — integração visual, primeira validação — 2026-11-02

Campo fixo após totais, filtros em painel com aplicar/cancelar/limpar/chips,
resultados com foto/código/características/situação e acesso à ficha. Três modos
permanecem montados em IndexedStack/Offstage para conservar o contexto. Busca
reconsulta ao retornar da ficha e atualizar o painel. Sem quarta aba.

Seis testes Widget PASS (novos e regressão do dashboard), incluindo 320/390 px
e texto 1,4x; analyze sem problemas. Android com preservação de data/retorno,
medição final de cobertura e CI ainda pendentes; T008 segue aberta até concluir
a validação de contexto e a revisão visual no Android.

## T009 — HTTP e volume — 2026-11-02

Fluxo real local PASS: nome/código fora da primeira página, cinco filtros, total,
cursor sem duplicação e animais sem tratamento/evento na agenda. Funcionário e
administrador autorizados; anônimo, sem vínculo, inativo e sessão encerrada negados.
5.000 animais temporários próprios: consultas HTTP locais de 0,041 / 0,031 / 0,012 s
(abaixo de 2 s; não representa rede externa nem produção). Fixtures removidas no
finally, sem reset ou alteração de cadastros anteriores. Teste adicionado à CI;
resultado remoto desse código ainda pendente.

### Revalidação de sessão na composição real

A revalidação avança accessEpoch e bloqueia temporariamente o acesso, mantendo
o mesmo privateGeneration. A busca preserva critérios durante esse intervalo
e captura a época confirmada após autorizar; troca de conta/perda real continua
invalidando dados e respostas. Teste específico e composição: **12 PASS**.
O teste de lifecycle agora percorre inactive/hidden/paused e o retorno válido,
sem salto paused→resumed rejeitado pelo listener do campo de texto.

### Regressão Flutter e controles completos

Regressão completa após revalidação: **497 testes PASS**, cobertura global
**6.610/6.954 linhas = 95,05%**. Teste Widget adicional das quatro seleções,
submit/limpar texto, limpar filtros e cancelar: suíte específica **4 PASS**.
Android compilou, mas a primeira tentativa foi interrompida por transporte/
ActivityManager travado no emulador. Reinício sem wipe; repetição pendente.

### Gate de cobertura

CI passa a reprovar relatório ausente/vazio ou cobertura global inferior a 95%,
sem excluir arquivos/linhas do LCOV. Gate executado localmente: 6.610/6.954 =
95,05%, PASS. Workflow YAML validado por parser antes do commit.

### Envio pelo teclado

O comando de submit recebe explicitamente o texto da ação do teclado, atualiza
o critério e cancela o debounce antes de consultar. Evita usar critério anterior
quando a conexão de edição nativa é recriada. VM/Widgets: **13 PASS**. Jornada
Android ainda em repetição, sem afirmar aprovação antes do resultado final.

### Controles após carregar calendário

A jornada avançou por homônimos, código e cinco filtros e identificou a toolbar
ainda desabilitada após a revalidação iniciada pelo calendário. refreshAccess
agora notifica mudanças de capacidade mesmo quando a geração privada não mudou,
conservando os critérios. Testes VM/Widget: **13 PASS**, incluindo notificações
durante e depois da confirmação de acesso. Android em repetição.

## T008/T010 — contexto preservado e Android — 2026-11-02

Jornada Android real PASS, emulator-5554/API 37: login de funcionário isolado,
dois homônimos com códigos distintos, nome/código normalizado, cinco filtros,
três modos, busca no calendário sem tratamento, ficha/retorno preservando busca,
dia anterior preservado ao limpar e logout. Teste termina sem escrever medicação
ou editar animal. Controller cria apenas dois animais próprios e limpa no fim.

Suíte Widget específica **5 PASS**, incluindo posição fixa em 320/390 px/texto
ampliado, filtros/erro/retry e restauração explícita da rolagem da Lista e dia
2026-11-03 após busca/ficha. Esta é a décima jornada da CI, mantendo as nove
anteriores. Resultado remoto e APK normal atualizado ainda pendentes em T011.

### Gates finais locais e primeira CI integrada

**499 testes Flutter PASS; 6.626/6.958 linhas = 95,23%**. Regressão SQL: 392/16
arquivos PASS. Formato de 298 arquivos sem alterações; shell Android e YAML PASS.
APK normal compilado/instalado/aberto no emulador. CI 41534388871/e6fd1a5 parou
em três lints de chaves nos testes novos, antes do backend/Android. Corrigidos
sem alterar comportamento; analyze local sem problemas. Nova CI pendente.

### Conferência visual no APK normal

Busca nativa por Luna exibiu foto, código A0067 e dados do cadastro local sem
duplicar/alterar animais. Ajustados os cartões para fundo branco e chips de
código/situação do protótipo; cadastro flutuante oculto enquanto há resultados
globais, evitando sobreposição. Oito Widgets (busca/dashboard) PASS, incluindo
texto ampliado/320 px e preservação de contexto; analyze sem problemas.

## Validação remota do código final — d2c826e

[CI 41536304106](https://github.com/lari-sh/app-extensao-II/actions/runs/41536304106),
commit d2c826ea10fd61ca2a5adbca42863149c3e75686 na developer.
Flutter PASS: análise, geração determinística, formato, 499 testes e gate
**6.636/6.968 linhas = 95,24%**, sem exclusões adicionais.
Backend PASS: 392 SQL/16 arquivos, 19 Deno e fluxos HTTP existentes/novos.
Concorrência de código/replay/renomeação/forja PASS. Busca HTTP com 5.000 registros:
0,043 / 0,013 / 0,012 s, com filtros/páginas/permissões/sessão revogada PASS.
Android PASS: dez jornadas, incluindo management_search_flow_test.dart,
no emulador Linux/API 35 da CI. Entrega do APK PASS.

APK normal local recompilado/instalado após o ajuste visual e aberto autenticado
no manejo com busca por Luna; conferidos foto, código A0067, cartão branco,
chips, posição fixa e ausência de sobreposição pelo botão de cadastro.

## Fechamento — 2026-11-02

**T001–T012 concluídas.** A CI 41536304106 terminou com sucesso para d2c826e:
Flutter, backend, Android e entrega aprovados. Dez jornadas Android confirmadas
nos logs, mantendo as nove anteriores e acrescentando a busca global.

[APK debug validado](https://github.com/lari-sh/app-extensao-II/actions/runs/41536304106/artifacts/13186182175):
artefato 13186182175, 77.006.811 bytes, não expirado na conferência; retenção até
2026-11-09 22:49:58 UTC. A entrega usa somente configuração pública de desenvolvimento.
O APK normal local foi recompilado/instalado e deixado no painel com a busca por Luna.

Resumo: 499 testes Flutter, 95,24% de linhas (6.636/6.968), 392 SQL, 19 Deno,
HTTP de concorrência/permissões/volume e dez jornadas Android PASS. Dados manuais
preservados; fixtures próprias removidas. iOS e ambiente produtivo não fazem parte
desta validação Android. Nenhuma dependência adicionada.

Este registro e o commit posterior de fechamento alteram somente Markdown;
as evidências executáveis referem-se exatamente ao código d2c826e acima.
.specify/extensions.yml permanece ausente: nenhum hook after_implement aplicável.

## Revisão v3 — manejo e busca no modo atual

Pedido substitui a apresentação global em Lista: manter Kanban e Calendário;
no Calendário usar somente as medicações do dia selecionado, conforme resposta
expressa da responsável. T013–T016 adicionadas antes de prosseguir.

Manejo: _authorize agora aguarda a verificação disponível mesmo quando o acesso
local está temporariamente suspenso durante o carregamento de medicações/foto;
a permissão continua obrigatória após a confirmação e no servidor. Teste de
reprodução e regressão VM/composição: **16 PASS**. Android ainda pendente.

### Calendário contextual — camada de dados

RPC aditiva search_medication_day aplica os seis critérios aos animais antes da
paginação das aplicações, mantendo o dia civil do abrigo. Cursor vinculado à
sessão/dia/versão e critérios. Endpoint original preservado para agenda sem busca.
12 SQL e 26 Flutter específicos/regressão PASS. Sem reset de dados. VM preserva
o filtro entre dias e limpar restaura a agenda da mesma data. Integração visual
e ampliação dos testes ainda pendentes.

### CI 41546000590 — correção de formato

O commit 847c70e falhou no gate dart format: três arquivos de Service/fakes
haviam sido alterados por dart fix após a formatação. Backend/Android não
executaram. Arquivos formatados novamente, com verificação sem alterações;
correção de estilo separada da integração visual em andamento.

### Integração visual v3

Busca mantém os cartões nas colunas do Kanban, os itens na Lista e somente as
aplicações do dia no Calendário. Integração de filtros com a RPC contextual.
Três testes Widget passaram, incluindo 320/390 px e texto ampliado; análise
estática sem problemas. Jornada nativa atualizada, ainda pendente de execução.

### CI 41547227518 — regressões Android em investigação

Flutter e backend aprovados. Android: sete jornadas passaram e três falharam:
animal_editor_flow (reabertura sem aguardar os dados), medication_calendar_flow
(carregamento/permissões do editor) e team_access_flow (listagem após navegação).
Entrega não executada. Evidência não representa aprovação da revisão v3.

### Correção da CI Android — carregamento e esperas

Teste de regressão reproduziu três leituras concorrentes antes da conclusão
inicial da ficha. A composição agora espera o cadastro terminar de carregar/salvar
para vincular os leitores de manejo e medicações. A verificação de permissão
continua obrigatória. Teste falhou antes e passou após a correção.

17 testes de composição/VM PASS; análise estática sem problemas; formato aprovado.
Jornadas de reabertura da ficha e Equipe agora aguardam os dados do servidor em
vez de apenas o fim da animação. Os asserts de conteúdo permanecem obrigatórios.

Celular físico MFZHZLA6TC49NJFI (Android 15): jornada management_search_flow PASS,
32 segundos de execução após instalação; busca Kanban/Lista/Calendário, dia
preservado e mudança de status confirmada por RPC. Essa execução utilizou 33b9bd2,
antes da correção adicional da ordem de carregamento; CI completa ainda pendente.

### Regressões no celular e APK para teste manual

Suíte Flutter completa: **501 PASS**, cobertura **95,19% (6.623/6.958)**,
sem exclusões adicionais. Execução com concorrência 2; tentativa anterior com
concorrência padrão foi interrompida por falta de memória, não por assert.

As jornadas de ficha, calendário e equipe aceitam apenas hosts locais de teste
(10.0.2.2 ou 127.0.0.1). Controlador de convite recebe TEST_ANDROID_SERIAL,
preservando emulator-5554 por padrão na CI. Análise estática PASS.

No celular, calendário de medicamentos PASS após a correção de composição.
Ficha bloqueada por INSTALL_FAILED_USER_RESTRICTED nessa tentativa; Equipe
revelou uma segunda espera incorreta: scrollUntilVisible era chamado enquanto
o conteúdo estava oculto na revalidação. Helper agora aguarda a ação confirmada
antes de ensureVisible; rerun remoto pendente. Não registrar a suíte como aprovada.

APK normal recompilado, instalado e aberto no celular. Login feito com
fixture-admin@example.test, administrador local persistente para uso manual;
nenhuma credencial foi incluída no código ou logs. Hierarquia Android confirmou
Kanban/Olá, equipe e ação Equipe. Automação encerrada no aparelho para não
interferir no teste manual da responsável. Backend permanece local, via USB.

### Busca confirmada, sem interrupção da digitação — 2026-11-02

Cada tecla antes apagava resultados e agendava busca após 300 ms; a busca
revalidava a sessão e podia ocultar o painel/teclado. O texto em edição agora é
separado do filtro confirmado. Digitar não consulta, não autoriza e não aplica
filtro na agenda; os cartões permanecem. Buscar no teclado confirma, assim como
as ações explícitas de filtro. Refresh/retorno não submetem texto em edição.
Paginação não mistura critérios, respostas antigas são descartadas e logout
continua removendo o estado privado. Nenhum layout/SDK/backend foi alterado.

15 testes específicos VM/Widget PASS, incluindo foco/teclado após pausas longas,
nenhuma consulta/revalidação ao digitar, calendário sem callback prematuro e
resposta tardia descartada. Suíte completa: **504 PASS**, **95,18% (6.622/6.957)**,
com todas as linhas do LCOV. Formato e análise estática PASS. Android/CI dessa
revisão ainda pendentes; não usar evidências nativas anteriores como aprovação.

### Menu administrativo aprovado — DESIGN-ADMIN-NAV-001

Equipe saiu do corpo do painel. Menu ⋮ de 48 × 48 dp no cabeçalho contém Equipe e
acessos somente para administradores e Sair da conta; Atualizar continua ao lado,
Voltar à esquerda. Entrada pública preservada. Backend/permissões não relaxados.
Protótipo separado e captura aprovados expressamente antes da implementação.

14 testes Widget/composição/regressão PASS, incluindo os seis pares perfil/modo,
alvo mínimo, callback de saída e preservação do modo ao voltar da equipe.
Suíte completa: **510 PASS**; análise e formato PASS. Jornadas Android atualizadas
para o menu, espera de digitação e verificação de funcionário sem item Equipe.
Validação nativa/CI específica ainda pendente em T024.

T025–T028 registram o novo pedido de busca pública por nome/espécie/sexo; ainda
não são implementação concluída. A execução segue speckit-implement, com tasks.md
como fonte única. Nenhuma tarefa foi copiada para a constituição.

### Correção da limpeza de fixtures com medicamentos

As fixtures de busca passaram a incluir tratamentos, mas a limpeza anterior
apagava o animal diretamente. As FKs são RESTRICT, não CASCADE: a limpeza passou
a falhar. Helper agora remove recibos/eventos/aplicações/revisões/tratamentos e
animais próprios em transação, com guardas de ator, nome, ownership e foto.

Validação real local PASS: criar animal/tratamento próprios, tentar limpar um
animal alheio (rejeitado e preservado), limpar o próprio e conferir ausência de
recibos/animal. Sem reset, sem alteração dos cadastros manuais. A correção fica
separada da implementação pública. Não modifica as FKs protetoras do aplicativo.

### Busca pública por nome, espécie e sexo — 006-FR-010

CatalogViewModel interpreta tokens portugueses sem dependências novas e envia
nome/espécie/sexo/porte juntos ao Repository existente. Gato não implica macho;
gato fêmea funciona. Critérios reconhecidos passam aos dropdowns existentes e o
campo conserva apenas o nome restante. Digitação não consulta; Buscar confirma.
Contradições/limite são validados antes do Repository, inclusive invalidando
resposta anterior pendente. Limpar filtros remove também o texto em edição.

31 testes específicos/regressão PASS; caso Widget ampliado confirmou buscas
sucessivas no mesmo campo. Suíte completa: **532 PASS**, cobertura **95,31%
(6.686/7.015)**, sem novas exclusões. Formato e análise estática PASS.

Jornada Android ampliada com nome + gato macho, gata fêmea, gato fêmea e cachorro
fêmea usando só os dois animais próprios publicados para o teste. Primeira execução
revelou necessidade de conferir foco/texto entre confirmações; rerun com toque
explícito e assert do texto pendente. Uma tentativa seguinte foi bloqueada por
INSTALL_FAILED_USER_RESTRICTED. Validação nativa final e CI ainda pendentes.

### Validação física concluída — fonte 2e8fdb9

Celular MFZHZLA6TC49NJFI, Android 15/API 35. Jornada ampliada
management_search_flow_test.dart **PASS**, 50 segundos após instalação: digitação
mantém filtro/resultados, Buscar confirma, Kanban/Lista/Calendário preservados,
medicações somente do dia, manejo alterado e confirmado no banco, logout pelo
menu, catálogo com nome + gato macho/gata fêmea/gato fêmea/cachorro fêmea.
O toque explícito no campo antes de cada nova entrada resolveu a repetição do
teste; os asserts de texto pendente e filtro confirmado foram mantidos.

APK normal da mesma fonte recompilado, instalado e aberto; login novamente como
fixture-admin@example.test, no painel. Nenhuma automação permanece navegando no
aparelho. Conexão com backend local via USB 54321 preservada para teste manual.
Fixtures próprias atuais removidas por HTTP 204; limpeza também removeu três
atores antigos de busca, verificando preservação da contagem dos demais animais.

Código/documentação publicados por contexto na developer. CI da fonte 2e8fdb9:
https://github.com/lari-sh/app-extensao-II/actions/runs/41556748443
Na consulta de fechamento ainda pendente/em processamento: T024/T028 conservam
pendência remota. Não declarar a suíte completa do GitHub aprovada com base nos
532 testes locais ou nesta única jornada física. Nenhuma alteração na main.

### Proposta de cadastro no topo — DESIGN-ADD-TOP-001

Confirmado no código: FAB inferior e padding bottom 90 no Kanban e na Lista.
Proposta isolada criada, com + Animal no cabeçalho, Atualizar no menu e extensão
vertical das colunas. QA HTML em 320/390 px sem overflow do cabeçalho; alvo do
botão 92 × 48 px. Sem alteração no Flutter, no APK ou nos dados. Aprovação visual
pendente conforme a constituição; tarefas T030/T031 registradas para retomada por
speckit-implement, sem duplicar tarefas na skill de constituição.

### Cadastro no topo, vermelho e Total — aprovação aplicada

Botão vermelho #C51D2A com texto completo Adicionar animal no cabeçalho; versão
compacta permanece no cabeçalho abaixo do título. FAB removido. Atualizar migrou
para o menu administrativo. Total é derivado das contagens reais do DashboardVM,
com singular/plural. Exemplos do design também usam Total. Padding inferior do
Kanban/Lista reduzido de 90 para 12, preservando SafeArea.

27 testes específicos/regressão PASS: botão/cores/alvo mínimo de 48 dp, abrir
cadastro e retornar sem perder modo, visibilidade nos perfis/modos, altura real
das colunas até 12 dp da área útil, total derivado e busca preservada na digitação.
A regressão antiga assumia cabeçalho de altura idêntica entre todos os modos;
foi adaptada para a nova altura contextual, mantendo estabilidade durante digitação
e ao limpar no mesmo modo. Não foi removida a verificação de posição/overflow.

Suíte final **532 PASS**, cobertura **95,32% (6.697/7.026)**, sem exclusões adicionais.
Formato e análise estática PASS. APK debug normal compilado; instalação no celular
em andamento. Jornadas Android atualizadas para o novo botão, ainda não reexecutadas
nesta etapa. CI remota específica também pendente. Proposta mostrada no navegador
com cor/texto corretos, captura atualizada. Nenhuma alteração de largura do Kanban.

### Feedback do cabeçalho e revisão v3

APK 9a791a6 foi instalado e aberto como administrador; captura real confirmou
Adicionar animal vermelho, Total: 72 animais derivado dos dados e Kanban estendido.
Uma tentativa de automação por hierarquia Android não confirmou a abertura do
cadastro; não registrar esse clique como PASS. Widget/composição e suíte 532 PASS
permanecem evidências locais distintas, sem afirmar nova jornada nativa completa.

A responsável rejeitou o botão na mesma linha por comprimir o título. Nova prévia
HTML coloca a ação em linha própria abaixo do cabeçalho em todas as larguras,
alinhada à direita. QA: título em uma linha em 320/390 px, largura útil 184,4/254,4
px, sem overflow; botão abaixo do título, mantendo texto completo e cor vermelha.
Captura em previews/add-animal-top-row-v3.png e página atualizada no navegador.
A revisão v3 aguarda aprovação antes de substituir a posição no aplicativo.
T031/T032 permanecem abertas; T033 registra o refinamento solicitado.

### Cadastro no menu — decisão vigente implementada

Adicionar animal é a primeira ação do menu ⋮, com texto vermelho e peso destacado.
Não há mais botão externo/linha extra, liberando a largura do título. Total e
Kanban até a área segura preservados. Cadastro disponível nos três modos, sujeito
a canManage e aos controles do servidor; Equipe permanece só para administradores.
Getters antigos usados apenas para esconder o FAB foram removidos por obsolescência,
sem exclusões de cobertura. Casos de modo/atualização continuam testados.

14 testes específicos PASS: administrador/funcionário nos três modos, ação vermelha
com altura >=48 dp, cadastro e retorno preservando modo, menu e extensão vertical.
Suíte completa **532 PASS**, cobertura **95,31% (6.684/7.013)**. Formato/análise PASS.
Protótipo e captura add-animal-menu-v4.png atualizados, menu aberto para revisão.
APK normal compilado; instalação/conferência física em andamento. CI remota dessa
revisão ainda não confirmada, sem reaproveitar aprovação de commits anteriores.

### Conferência no celular — fonte 693a28a

APK normal instalado e aberto como administrador. Checagem real no Android PASS:
abrir menu Administração, tocar Adicionar animal, encontrar a tela Cadastrar animal,
voltar ao Kanban e reabrir o menu. Captura local confirmou texto vermelho, Equipe,
Atualizar e Sair, título sem compressão e Total: 72 animais derivado dos dados.
Nenhum cadastro foi salvo; app ficou logado no painel com o menu aberto.

A pós-condição do helper anterior ainda esperava Adicionar animal fora do menu;
foi corrigida para verificar após abrir o menu, preservando a checagem real de
cadastro e retorno. Não houve alteração adicional de produto para passar o helper.
T031/T032/T034 concluídas sob a decisão vigente; T033 substituída, sem implementação.

CI remota da fonte 693a28a consultada em execução, ainda sem resultado final:
https://github.com/lari-sh/app-extensao-II/actions/runs/41560376615
As evidências 532 testes/95,31% são locais. T016/T024/T028 mantêm a pendência remota;
este fechamento documental não declara aprovação completa da esteira.

### Divergência 71/72 — causa e correção local

Banco tinha 72 registros: 69 disponíveis, 1 em tratamento, 1 em quarentena e 1
adotado. A diferença era a fixture 8b4b2d41-61fa-493b-847d-60ab386e50cc, criada
pela jornada Android de medicamentos com fixture-staff@example.test. Limpeza
protegida removeu exclusivamente esse registro e seus vínculos temporários;
hash de todos os demais animais antes/depois permaneceu idêntico.

Resultado: 71 registros (68 disponíveis + 1 tratamento + 1 quarentena + 1 adotado).
O contador estava somando corretamente o banco; não foi fixado número nem excluído
adotado para mascarar a diferença. Painel do celular atualizado e Total: 71 animais
confirmado. Nenhuma recompilação do app foi necessária para corrigir os dados.

Prevenção: finally da jornada limpa seu próprio UUID pelo controlador loopback,
que valida fixture reservada e não aceita cadastros comuns. Nova regressão HTTP/
SQL cria somente animais próprios, prova recusa de um controle não descartável,
remove tratamento/animal temporário e restaura o total. Duas regressões Python PASS,
incluídas na CI. Teste do VM cobre 68+1+1+1=71 e independência da página carregada.

Suíte Flutter: **533 PASS**, análise/formato PASS; cobertura medida pelo gate global.
A jornada Android completa com o novo finally ainda aguarda a CI remota; a checagem
de atualização do contador no celular passou. Escopo funcional do contador preservado.


## Cobertura — dados e armazenamento (2026-11-02)

539 testes Flutter PASS. LCOV integral: 6726/7013 linhas, 95,91%, sem novas exclusões. Novos cenários: falhas e fila de persistência de sessão, leitura JPEG inconsistente/timeout, interrupção de tratamentos e mapeamento/ordenação dos animais. A meta de 99% permanece pendente.


## Sobre: contatos e Pix — 2026-11-02

544 testes Flutter PASS; análise estática e formato PASS. Repository/VM/Widget verificam chave literal, três URLs oficiais, falhas sanitizadas, repetição, descarte e navegação de retorno. No celular MFZHZLA6TC49NJFI, APK atualizado: Visitante → Sobre, chave 23.785.379/0001-98 visível, Copiar chave Pix → confirmação, contatos presentes após rolagem; PASS. Evidência local .tools/about-pix-phone.png. Não foi enviado contato nem realizado pagamento. App normal deixado autenticado no painel administrativo.

Protótipo design/about-contact-pix.html conferido no navegador, incluindo confirmação de cópia; acesso Sobre do protótipo principal aponta para a nova referência. Screenshot design/previews/about-contact-pix.png. A meta global 99% continua em T037–T039 e não é declarada concluída nesta entrega. Resultado remoto da CI deve ser distinguido da validação local acima.


## Substituição dos dados de teste antigos — 2026-11-02

Pedido expresso: excluir antigos e usar novos com fotos. Removidos 60 IDs técnicos exatos e três exemplos antigos de agenda, com notas/autoria conferidas. Backup local em .tools/demo_animals/retired-20261103T021143Z/records.json, incluindo vínculos e bytes das fotos anexadas; três objetos antigos removidos. Restaram exatamente os oito IDs e fotos do manifesto autorizado. Fotos públicas dos oito revalidadas via Function, sem autenticação. Amora em tratamento, Mel em quarentena, Bento disponível; todos com agenda simulada em 2026-11-02–04, horários fixos ou intervalo de 8h. Cadastro e agenda reaplicados sem duplicação; testes Python de seleção/proteção: 2 PASS.

Uma verificação posterior à exclusão apontou diferença em recibos sem tratamento porque SQL NOT NULL omitia-os do snapshot, não por perda confirmada de recibos. Corrigido o predicado com COALESCE; os oito IDs/fotos foram conferidos novamente. Não se declara comparação byte a byte dos recibos naquela primeira execução. Nenhum ambiente remoto/reset foi utilizado. Validação visual no celular e cenários completos continuam em T044/T045.


## Fotos e cenários realistas automatizados — 2026-11-02

14 testes específicos Flutter PASS: fichas Amora/Bento/Mel com JPEGs reais ilustrativos, dados públicos completos, erro/retry de leitura, foto danificada e fechar/backdrop; upload recuperado, incerteza, reconciliação/reenvio e preservação da foto anterior; SDK de detalhe/favoritos exige publicação e exclui adotados. Fotos versionadas para testes offline; hashes/tamanhos conferidos contra manifesto autorizado. Análise estática PASS.

Jornada HTTP de medicação PASS: duas sessões, replay, agenda de 101 itens, fuso civil, conflito de snapshot e bloqueio do visitante; autoria/horário de servidor, corrida e valores forjados; edição/interrupção preservando atrasadas, correção com histórico, revogação durante espera e isolamento de adoção/save genérico. Fixtures próprias removidas no finally. Esta evidência não significa cobertura exaustiva de todos os cenários possíveis. CI remota ainda em andamento.


## Vacinas: nome antes da data — 006-FR-012 (2026-11-02)

Formato público agora Nome • DD/MM/AAAA, uma dose por linha, mantendo reforços e
ordem. Nenhum registro do backend foi alterado; somente apresentação no VM.
Protótipo atualizado e conferido no navegador (design/previews/vaccines-name-date.png).
12 testes específicos PASS, incluindo 320 px/texto 1,4 e reforços V4 separados.
Suíte integral 554 PASS, 6823/7075 linhas = 96,44% (meta 99% pendente).
Jornada SDK Android no celular repetida PASS em 16 s, incluindo valor exato de
Vacinas na ficha da Amora e conclusão/correção da aplicação simulada.
Não declarar CI remota aprovada enquanto estiver em execução.


## Recuperação do painel — ampliação de cobertura

Sete testes novos PASS: falha/revogação na revalidação, erro de primeira página e paginação preservando dados, recibo ausente/incerto/confirmado no animal focado e nos totais, modos/situação adotado, paginação Kanban/Lista, edição e retomada do app, consulta antes de repetir a mesma operação. Exemplos Bento/Amora com dados do manifesto. Análise estática PASS. Sem mudança de produção ou layout; nova medição global será feita com a suíte integral, não com LCOV parcial.


## Recuperação da programação de medicamentos — ampliação de cobertura

Sete testes Widget novos PASS: recarregar após falha, paginação sem duplicação, abrir/fechar tratamento existente, interromper com resposta incerta, consultar antes de repetir a mesma operação, concluir por recibo/reenvio e retornar da programação; período invertido e horários fixos duplicados exibem erros. A lista e o formulário oferecem retries distintos e testados. Análise estática PASS, sem mudanças de produção/layout ou novas dependências.


## Catálogo, favoritos e contatos — ampliação de cobertura

Seis testes específicos PASS (três novos): catálogo confirma pela navegação inferior e combina porte/sexo/espécie; lista pública com JPEGs recupera falha de favoritos, pagina sem duplicação, muda favorito e recarrega após fechar a ficha; contato recupera falha de leitura, mostra abertura em andamento, sanitiza erro da plataforma e revalida disponibilidade antes de abrir canal. Análise estática PASS. Medição integral anterior: 568 PASS, 6880/7075 = 97,24%; nova medição em execução, sem usar amostra parcial como cobertura global.


## Sessão, callbacks e dados inválidos — ampliação de cobertura

33 testes específicos PASS (oito novos): recuperação de senha verificada pelo SDK com refresh de token e consumidor tardio; erro real de sessão inicial sanitizado; sessão expirada preserva estado recuperável em falha de transporte; leitura de acesso tardia é cancelada após trocar senha; falha tipada no stream; DTO recusa foto/atributos inválidos, datas impossíveis, intervalo não inteiro e correção sem motivo; launcher padrão solicita aplicativo externo e Result converte timeout em falha retryable. Sem pacotes novos, sem API interna do SDK e sem exclusões de cobertura. Última medição integral antes deste lote: 571 PASS, 97,89%.


## Troca de instância da sessão — regressão de privacidade (2026-11-03)

Teste Widget reproduziu (RED) retenção do conteúdo privado da primeira sessão
quando outra sessão autorizada com mesma privateGeneration substituía a instância.
ProtectedScope agora descarta o conteúdo e reinicia a geração antes de conectar
os listeners da nova sessão. GREEN: conteúdo da conta anterior desaparece e seus
eventos posteriores não afetam a nova conta. Sem alteração de layout.
46 testes direcionados de auth/permissões PASS; suíte integral 580 PASS,
6958/7077 linhas = 98,32%, sem exclusões. Authentication_flow agora aceita os dois
hosts locais para executar também no celular. APK de teste compilado/instalado;
jornada física interrompida pelo bloqueio da tela, aguardando desbloqueio da
responsável. T048 permanece aberta para essa validação, sem declarar Android PASS.


## Cadastro e lista administrativa — ampliação de cobertura (2026-11-03)

Três testes Widget novos PASS: paginação/atualização e retorno de cadastro/edição na lista administrativa; falha de carga e salvamento incerto com consulta/reenvio; remoção de vacina e mudança do tipo de cuidado interno sem alterar a data pública de vermifugação. Análise estática PASS. Cenários de apresentação Amora/Mel, sem gravação no backend.


## Aplicação de medicamentos — ampliação de cobertura (2026-11-03)

Quatro testes novos PASS: carregamento e retomada do aplicativo, fechar detalhes, confirmação antes de repetir a mesma operação, histórico de cancelamento preservado após cursor repetido e revalidação explícita ao negar conclusão. UI e ViewModel reais com Repository controlado; não registra doses em animais reais nem altera o backend de apresentação. Análise estática PASS.
