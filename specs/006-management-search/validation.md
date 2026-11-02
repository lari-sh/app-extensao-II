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
