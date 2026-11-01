# Recuperação da CI ampliada — CR-007

## Execução com falha
[41289495230](https://github.com/lari-sh/app-extensao-II/actions/runs/41289495230),
SHA a4fa1a32e781d0055bc8329d05b5727f6beb7fc4: Flutter e backend PASS;
Android: 4 jornadas PASS, 3 falhas; deliver não liberado.

Log do job 124798637718:
- Erros de ColorBuffer/textura do emulador antes da instalação do primeiro APK.
- public_catalog_flow não iniciou o corpo e atingiu timeout de carga de 12 min,
  incluindo a primeira compilação Gradle de 286,6 s.
- visitor_detail_flow falhou ao iniciar Dart Development Service; ADB ficou offline.
- authentication_flow iniciou, mas ensureVisible não encontrou o botão de login
  na árvore lazy. Essa falha do roteiro é independente do timeout de carga.
- Manejo clínico/Kanban, cadastro, calendário e contatos passaram. Não houve
  evidência de falha na asserção de resumo clínico do cartão.

## Ajustes e validação local
- Roteiro de autenticação isola a sessão inicial; revela o e-mail antes de digitar,
  fecha teclado e rola até o botão. Não enfraquece asserções de acesso/revogação.
  Teste Android repetido: PASS em 16 s.
- Workflow prepara APK debug x64 antes do banco/emulador para evitar a primeira
  compilação pesada concorrente com ambos. O APK de preparação não é publicado;
  flutter test recompila com o target e configurações de fixture corretos.
- Emulador usa swiftshader, Vulkan desativado, cold boot sem snapshots e sem
  coleta de métricas, opções já usadas com sucesso no AVD local. Isto é uma
  mitigação da infraestrutura observada, sem declarar causa gráfica definitiva.
- Script verifica transporte ADB com espera limitada a 60 s e boot_completed antes
  da bateria. Falha de transporte encerra o gate, sem retry silencioso de testes.
- YAML interpretado e bash -n PASS. Análise Flutter sem problemas.

A nova execução remota precisa passar antes de concluir T110. Manter as sete
jornadas na CI; não ignorar as três falhas nem reduzir o conjunto para obter verde.


## Segunda execução — carga recuperada, interação de login instável

[41291605301](https://github.com/lari-sh/app-extensao-II/actions/runs/41291605301),
SHA 69793468d6976bb28dd54f7db69adda237e734e7: Flutter/backend PASS;
Android 5 PASS e 2 falhas. Os dois fluxos públicos iniciaram e passaram; não houve
repetição dos timeouts de carga/DDS/offline da tentativa anterior. Preparação x64,
renderização e checagem ADB passaram. Deliver foi corretamente bloqueado.

Restaram os roteiros authentication_flow e medication_calendar_flow: toque fora
da área efetivamente atingível/rota em transição e botão ausente após alteração
do viewport. A tela real já oferece onSubmitted no campo de senha. Os dois
roteiros agora usam uma única ação explícita TextInputAction.done e aguardam o
resultado/navegação confirmados, em vez de um toque posterior durante a transição.
Não chamam ViewModel.submit diretamente nem ignoram erro de toque.
O SDK Flutter fixado documenta que injetar texto/ações com IME real pode alterar
seu estado; não depender de pumpAndSettle isoladamente para concluir a autenticação.

Validação local atual: autenticação PASS em 13 s, incluindo todos os casos de
falha/restauração/revogação; calendário completo PASS em 48 s. Conjunto dos dois
PASS em 1 min 23 s com compilação intermediária. O caminho do botão continua
coberto pelo Widget Test do login. Nenhuma regra do app ou asserção de negócio
foi removida. Próxima CI ainda precisa aprovar as sete jornadas e o artifact.


## Terceira execução — jornadas aprovadas

[41293728173](https://github.com/lari-sh/app-extensao-II/actions/runs/41293728173),
SHA 3e4547a752faacefb36c15b82c45725ed3246dfd: Flutter, backend e Android PASS.
O log confirma 7 testes Android aprovados: catálogo, ficha, autenticação, manejo
clínico, cadastro, calendário e contatos. Os dois roteiros corrigidos passaram,
sem retirar jornadas ou asserções. Contagens confirmadas nos logs: 272 testes
Flutter, 256 testes pgTAP em 12 arquivos, 12 testes de funções HTTP e jornadas
HTTP de manejo/medicações/concorrência aprovadas. Deliver PASS; artifact 13078203574 confirmado, com evidências de fechamento
em validation.md. T110 concluída após a confirmação dos quatro gates.
