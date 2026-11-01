# Evidências — calendário de medicamentos

Data: 2026-10-31. Implementação em andamento na developer.
Design 4e738eb aprovado explicitamente; T001 registrada antes da implementação.

## Referência e domínio

Suíte anterior: 181 testes Flutter aprovados. Testes novos foram executados antes
dos modelos (falha por arquivos ausentes), depois aprovados com os modelos reais.
Suíte completa com domínio: 185 testes aprovados. flutter analyze sem problemas.
Modelos Freezed para tratamento, programação, aplicação/eventos e snapshots.
Validações civis de entrada e capacidades usam referência de servidor; o app não
duplica a geração IANA. Limites e exclusividade dos modos cobertos no domínio.
Nenhum pacote novo. Fronteiras arquiteturais conferidas pela suíte existente.

## Pendências

Interfaces, Services/Repositories, RPCs funcionais, ViewModels, telas, Android e
CI do calendário ainda precisam das tarefas posteriores. Não declarar o calendário
funcional com apenas modelos. Ver tasks.md para o acompanhamento autoritativo.


## Fundação SQL privada

Migração 011 aplicada somente no Supabase local, após teste vermelho confirmado.
Suíte pgTAP: 149 testes aprovados em oito arquivos, incluindo 22 da fundação.
Verifica tabelas/ledger, equipe atual, anonimato, não equipe, sessão ausente/expirada,
revogação, auditoria/recibos sem leitura direta, DML direto negado, FK de animal
restritiva, unicidade de aplicação ativa e contador transacional inicial.
O schema público de animals não recebeu informações de medicação. As revisões
possuem referência deferida e IDs próprios, separados dos clinical_records legados.
Nenhuma migração de produção realizada; RPCs e jornada Android do calendário pendentes.


## Contratos, DTOs e Service

Contratos abstratos de Repository/Service, fakes controlados e relógio de teste
preparados. DTOs validam identificadores, versões, modos, datas civis/UTC, autoria,
páginas, limites e imutabilidade, descartando campos clínicos não relacionados.
Service encapsula SDK e usa RPCs estreitos; autor/hora real não são enviados pelo app.
Testes novos executados primeiro em vermelho; sete testes de DTO/Service passaram.
Suíte completa: 192 testes Flutter aprovados, flutter analyze sem problemas.
Erros SQL, AuthException, timeout e rede continuam tipados/sanitizados por Result.
As chamadas foram verificadas com HTTP controlado: as RPCs reais do calendário
continuam na próxima etapa; não confundir essa aprovação com integração funcional.


## Geração e gravação de tratamentos

Migração 012 aplicada somente localmente. Teste de contrato executado primeiro em
vermelho pela ausência das RPCs; depois 19 casos de programação aprovados.
Suíte completa pgTAP: 168 testes em nove arquivos, sem falhas. Casos: fixos e
intervalos, limites inclusivos, meia-noite, datas inválidas, gaps/folds IANA de
São Paulo, horários duplicados, 10.000 aplicações e rollback do excesso,
campos de autoria indevidos, período/intervalo inválidos, digest/replay/conflito,
listagem e recibo privado negado após revogação.
Resolver civil e geração ficam no servidor; o corpo da RPC fixa UTC e preserva
America/Sao_Paulo no contrato. A verificação de sessão da medicação usa relógio
real também após esperas/generação. Recibo e contador são transacionais.
Nesta etapa save cria tratamentos e rejeita edição; revisão/interrupção pertencem
à US4. Integração Repository/VM/tela e Android ainda pendentes.


## Repository real

MedicationsRepositoryImpl consome o Service, normaliza campos editáveis e mapeia
os modelos imutáveis. Confirmações precisam corresponder à chave/alvo solicitados;
respostas incompatíveis não podem virar sucesso. Validação de IDs, versões,
períodos/cursor e motivos evita chamadas inválidas, sem mover o fuso para o cliente.
Testes do Repository escritos antes da implementação e aprovados com Service falso:
normalização, DTO→domínio, páginas, autoria/eventos, Result, reconciliação,
falhas tipadas/inesperadas e recibo divergente. Suíte Flutter completa: 198 PASS;
flutter analyze sem problemas. Android ainda não validado para o calendário.

Correção de evidência do Repository: a primeira análise final tinha dois avisos de blocos if no teste; foram corrigidos antes de avançar. Nova execução de flutter analyze sem problemas e os seis testes do Repository novamente aprovados. A suíte completa de 198 testes havia passado; a correção alterou apenas delimitadores no teste.


## ViewModel de tratamentos

Dez testes unitários com Repository falso passaram: validação/animal não salvo,
confirmação, binding estável ao salvar a ficha geral, dois modos, autorização,
respostas de outro animal, geração privada, paginação, exceções e resultado incerto.
Timeout conserva chave/payload, consulta recibo e só repete a operação original;
resposta de sessão antiga não confirma visualmente, mas permite reconciliar no
mesmo usuário. Logout/troca de geração limpa estado privado. Edição/interrupção
são coordenadas pelo VM; RPCs de revisão continuam pendentes da US4.
Suíte completa: 208 testes Flutter PASS. Análise final: No issues found.
Sem pacote novo. Interface aprovada e jornada Android ainda não integradas.


## Formulário aprovado e composição protegida

Painel Medicações em uso integrado à ficha, com rota privada própria para Programar
medicação. A rota usa ProtectedScope e é removida da pilha no logout; recebe somente
identificadores e carrega o nome confirmado via Repository no ViewModel.
Os campos preservam cabeçalho/paleta, período, dois modos e ações do desenho aprovado.
Seletores nativos de data/hora enviam eventos ao VM; unidades persistidas são
reconstruídas corretamente. A prévia não inventa datas: informa a programação e
explica que a agenda será confirmada ao salvar, pois geração IANA cabe ao servidor.

Widget Tests: criação confirmada, formulário compacto em 320 px com texto 1,4×,
seleção por intervalo/erros e aplicação real removendo rascunho/rota no logout.
Revalidação concorrente dos componentes da mesma rota é coordenada na composição,
sem chamadas em build. Binding da medicação não depende de formVersion da ficha.
Suíte completa 212 Flutter PASS; análise final sem problemas. Testes de unidade
adicionais cobrem unidades/seletores. Android e prova com duas sessões reais da US1
seguem pendentes de T020; a aba calendário ainda pertence à US2.

## Contrato HTTP de tratamentos — duas sessões locais

medication_flow.py aprovado: duas sessões autenticadas, chamadas concorrentes com
a mesma chave gerando um único tratamento e quatro aplicações, recibo recuperado
pela segunda sessão e acesso de visitante negado. Massa descartável removida em
transação, sem alterar animais manuais. Execução restrita ao Supabase local.

## US1 no Android — formulário de medicação

Jornada nativa medication_calendar_flow_test.dart aprovada no emulator-5554:
login da equipe, abertura da ficha pelo painel, gravação de horários fixos 08h/20h
e intervalo de oito horas. Segunda sessão confirmou dois tratamentos, quatro
aplicações por tratamento e o instante após a meia-noite, preservando as notas
privadas e a publicação da ficha. Logout local e limpeza da massa ao finalizar.

A primeira execução revelou colisão de Hero nas mensagens de sucesso entre
Scaffolds registrados no mesmo messenger. O editor agora possui ScaffoldMessenger
próprio, preservando a composição visual. Reexecução Android: 1 teste PASS, sem
exceções. Widget Tests do editor: 3 PASS; flutter analyze: No issues found.
T020 concluída; US2–US4 e integração desses testes à CI continuam pendentes.

## US2 — leituras privadas do calendário

Migration aditiva 013 aplicada somente no Supabase local. Mês por intervalo
indexado, contagens completas por estado, dia com 100 aplicações por página e
histórico com 100 eventos por página. Leituras de versão e itens no mesmo snapshot
SQL; cursor vincula usuário/dia/versão, conflito PT409 exige recarga. Datas civis
calculadas em America/Sao_Paulo. Sem API externa nem novo pacote.

32 testes novos cobrem meia-noite, simultâneos, 101 aplicações sem omissão, estados,
101 eventos, cursores inválidos/trocados, mutação, equipe revogada e visitante.
Suíte SQL completa: 200 PASS em 10 arquivos. Teste legado do contador agora aceita
dados locais existentes, verificando não negatividade em vez de presumir zero.
T021/T023 concluídas; interface/Android da US2 ainda pendentes.

## US2 — ViewModel e contrato de leitura

MedicationCalendarViewModel com estado Freezed, grade e rótulos prontos em
português, seleção mês/dia, Hoje pelo calendário civil do servidor, paginação e
recarga em conflito de snapshot. Respostas antigas de mês/dia/sessão ignoradas;
logout/troca de geração limpa dados privados. Atraso usa server_now, sem offset
fixo ou conversão pelo fuso do dispositivo.

Dez testes do VM e onze de Service/Repository passaram (21 no conjunto). Cobertura
de 28/29/30/31 dias, ano, limite UTC/mês civil, simultâneos, erros, todos os itens,
cursores repetidos, conflito, gerações privadas e payload restrito de leitura.
Análise final sem problemas após corrigir avisos de estilo. T022/T024/T025
concluídas. Nenhuma mudança visual ou pacote novo neste contexto.

## US2 — grade e agenda integradas ao painel

A aba Calendário agora seleciona modo próprio no DashboardViewModel, carrega via
callback de composição fora de build e usa MedicationCalendarPanel. Preservados
cabeçalho, estatísticas, abas, paleta, cartão mensal, marcadores e lista do dia do
screen-7 aprovado. Retomar o app/atualizar/selecionar aba recarrega dados. Providers
privados removem listeners e descartam VM ao encerrar o escopo.

Widget Tests aprovados: mês anterior/próximo, Hoje, seleção diária, aplicações,
vazio/erro/retry e regressões Kanban/Lista; painel completo em 320 px e texto 1,4×.
Teste unitário cobre o novo modo e seu callback. Suíte Flutter: 229 PASS; análise
final sem problemas após corrigir dois avisos de estilo. T026/T027 concluídas.
Validação nativa e revisão visual da US2 continuam em T028. Setas dos cartões
preservadas visualmente; conclusão/detalhes auditados pertencem à US3 seguinte.

## US2 — comparação visual com screen-7

Captura Flutter de revisão comparada com design/previews/calendar.png: mantidos
agrupamentos, grade, marcadores, título do dia e cartões. Ajustadas altura das
células e área de Hoje, além das cores de realizada/setas, para coincidir com o
protótipo. Cinco Widget Tests de calendário/painel PASS e análise sem problemas.
Captura é de renderização Flutter de teste, não evidência de Android. A primeira
jornada nativa da US2 parou no harness ao procurar botão Voltar ausente; será
repetida usando o comando Voltar do sistema antes de concluir T028.

## US2 — jornada Android e HTTP concluídas

Jornada medication_calendar_flow_test.dart aprovada no emulator-5554: login,
tratamentos fixos/intervalo na ficha real, Voltar do sistema, aba Calendário,
Novembro/Dezembro, dias 1/2, cartões e horário 04h da série intervalada após a
meia-noite. Segunda sessão confirmou cinco aplicações do animal no dia 2, sem
alterar notas/publicação. Retorno a Lista e Kanban sem exceções. 1 teste Android
PASS (30 s), com limpeza exclusiva dos animais descartáveis ao finalizar.

medication_flow.py ampliado e aprovado com duas sessões: mês, 101 aplicações
percorridas por todas as páginas sem duplicar/omitir, civis 00h–01h40, mutação
seguida de PT409 no cursor antigo e leitura mensal negada ao visitante.
T028 concluída. US1/US2 somam 28/50 tarefas; US3/US4 ainda não implementadas.
CI remota desta entrega não foi declarada aprovada; inclusão dessas jornadas na
esteira segue em T046. Somente backend local, sem implantação em produção.

## Navegação visível — solicitação adicional T051

AppBackButton em português no login, painel de manejo, cadastro/edição, área do
voluntário, favoritos, sobre e lista administrativa legada. Retorno usa maybePop,
preserva guard de rota e não encerra sessão. Login desabilita ação enquanto envia
credenciais; reautenticação usa onCancel. Fechar da programação/detalhes mantidos.

Suíte Flutter completa: 232 PASS; análise sem problemas. Testes novos de retorno
à origem, rota bloqueada, cancelamento de reautenticação e logo centralizado.
Jornada Android ampliada: Voltar explícito da ficha ao painel e do painel à área
do voluntário, além da navegação mês/dia; 1 teste PASS em 32 s. Massa descartável
removida. Protótipo atualizado e testado em 320/390 px, sem erro JS; ações Voltar
e logo centralizado verificados. T051 concluída: 29/51 tarefas, 22 restantes.
