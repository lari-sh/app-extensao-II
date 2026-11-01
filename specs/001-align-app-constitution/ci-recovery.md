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
