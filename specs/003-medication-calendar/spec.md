# Especificação — calendário de medicamentos

Data: 2026-10-31. Branch de trabalho: developer. Estado: especificado; não implementado.
Origem: scope.md e decisões confirmadas pela responsável nesta conversa.

## Jornadas e testes de aceitação

### US1 — Cadastrar o tratamento na ficha (P1)

A equipe cadastra medicamento, instruções, período e uma das recorrências. Ao
salvar, as aplicações aparecem na agenda sem digitação duplicada.
Teste independente: salvar um tratamento numa ficha existente e consultar as
ocorrências em outra sessão da equipe, sem depender da tela de calendário.

1. Dado o período de 01/11/2026 08:00 a 02/11/2026 20:00 no abrigo e horários
   fixos 08:00/20:00, salvar produz quatro aplicações, inclusive os dois limites.
2. Dado início 01/11/2026 20:00, término 02/11/2026 20:00 e intervalo de 8 horas,
   produzir 20:00, 04:00, 12:00 e 20:00, atravessando a meia-noite.
3. Reenviar a mesma operação preserva os IDs; dados inválidos não gravam parte da série.
4. Salvar a descrição clínica antiga não cria nem apaga tratamentos estruturados.

### US2 — Consultar mês e agenda do dia (P1)

A equipe usa a aba Calendário, seleciona um dia e vê cada animal, medicamento,
horário previsto e situação, com os dias que possuem aplicações marcados.
Teste independente: semear tratamentos pelo contrato e navegar mês/dia com dados
reais; Widget Test usa Repository falso.

1. No mesmo horário, duas aplicações de animais diferentes aparecem separadamente.
2. Mês sem aplicações mostra estado vazio; dias de meses de 28/29/30/31 dias são corretos.
3. Mudar o fuso do aparelho não muda o dia/horário do abrigo apresentado.
4. Mais de 100 aplicações no dia permite carregar todas, sem limitar silenciosamente.

### US3 — Registrar aplicação e autoria (P1)

A equipe marca uma aplicação devida como realizada e consulta o funcionário e o
horário real registrado pelo servidor, mantendo o horário previsto.
Teste independente: semear uma aplicação devida e concluí-la em duas sessões.

1. A confirmação exibe autor e horário real; o cliente não escolhe outro autor ou hora.
2. Dois funcionários simultâneos geram uma conclusão; o perdedor recebe conflito e atualiza.
3. Timeout após commit permite consultar a mesma operação, sem nova aplicação.
4. Aplicação futura ou cancelada não pode ser marcada como realizada.

### US4 — Alterar tratamento e corrigir enganos (P2)

A equipe altera/interrompe o tratamento preservando o histórico. Aplicações
atrasadas continuam visíveis. Uma conclusão incorreta pode ser revertida com motivo.
Teste independente: semear aplicações passada, futura e realizada; editar,
interromper e corrigir, verificando eventos e linhas numa segunda sessão.

1. Na alteração, somente pendentes estritamente futuras são canceladas/substituídas;
   realizadas e pendentes vencidas permanecem na revisão original.
2. Na interrupção, futuras são canceladas; atrasadas continuam pendentes para revisão.
3. Correção exige justificativa e cria evento novo; autor/hora anteriores permanecem.
4. Adoção/publicação do animal não apaga nem interrompe tratamento automaticamente.

## Requisitos funcionais

- **003-FR-001**: Calendário mensal real na aba existente, com navegação de mês,
  seleção de dia e indicação de dias com aplicações não canceladas.
- **003-FR-002**: Agenda do dia do abrigo, ordenada por instante previsto e ID,
  contendo animal, medicamento, instruções da revisão e horário/situação; paginação
  completa e separação de aplicações simultâneas.
- **003-FR-003**: Estados persistidos pending/completed/cancelled; atrasada é uma
  pendente com scheduled_at menor que o relógio do servidor. Igual ao instante
  atual já permite conclusão; não é futura. Nunca marcar automaticamente como realizada.
- **003-FR-004**: Gerar toda a série finita ao salvar o tratamento, na mesma
  transação. Não exigir lançamento manual na agenda nem depender de cron.
- **003-FR-005**: Campos estruturados e IDs estáveis separados dos clinical_records
  legados. Não inferir medicação, frequência ou datas de textos livres.
- **003-FR-006**: Tratamentos, aplicações e auditoria privados: apenas equipe ativa
  com sessão válida. Animal publicado não torna esses registros públicos.
- **003-FR-007**: Dois modos exclusivos: fixed_times (horas civis diárias do abrigo)
  e interval (minutos decorridos desde a primeira aplicação). Zona America/Sao_Paulo.
  Instantes inicial e final inclusivos. O intervalo não é recalculado a partir da
  hora efetiva da conclusão, e horários fixos não são somas de 24 horas UTC.
- **003-FR-008**: Ao concluir, derivar autor da sessão e capturar hora real no
  servidor após as travas/rechecagem de acesso; preservar previsão. Sem envio de
  ator ou performed_at pelo cliente e sem conclusão antecipada.
- **003-FR-009**: Alteração/interrupção usa corte do servidor após lock. Cancelar
  somente pending com scheduled_at estritamente maior que o corte. Preservar as
  demais, inclusive atrasadas. Novas ocorrências de uma revisão são posteriores
  ao corte, sem duplicar pendentes/realizadas no mesmo tratamento/instante.
- **003-FR-010**: Correção de completed para pending exige justificativa de 1–500
  caracteres e versão esperada. Auditoria imutável conserva conclusão original e
  registra corretor/hora/motivo; nova conclusão, se necessária, é outro evento.
- **003-FR-011**: Comandos idempotentes, controle de versão e concorrência. Uma
  chave com payload diferente conflita. Repetição retorna a confirmação original;
  estado incerto exige reconciliação, sem prometer sucesso antes da confirmação.
- **003-FR-012**: Nome do medicamento com 1–120 caracteres, instruções opcionais
  até 1.000, período maior que zero e até 366 dias civis inclusivos; fixed_times
  com 1–24 horários distintos HH:mm; interval_minutes inteiro de 1 a 10.080.
  Máximo de 10.000 aplicações por revisão; excesso rejeita tudo, sem truncar.
  Datas de entrada entre 2000 e 2100; datas civis inexistentes/ambíguas por mudança
  de fuso são rejeitadas explicitamente.
- **003-FR-013**: Rascunhos e capacidades controlados por ViewModels; descartar
  dados privados após logout/troca de usuário/revogação. Ignorar respostas antigas
  após mudança de sessão, mês ou animal. Mesmo usuário pode retomar após revalidar.
- **003-FR-014**: Preservar cabeçalho, indicadores, abas, cores, tipografia e cartões.
  Não há artboard do conteúdo do calendário nem editor de recorrência: apresentar
  proposta e obter autorização explícita antes de implementar as novas composições.
- **003-FR-015**: Sem dados fictícios: vazio, carregamento, falha e conflito com
  mensagens em português. Aplicações históricas só surgem por período explicitamente
  cadastrado e ficam pendentes; não presumir que foram administradas. Animal adotado
  mantém agenda até interrupção explícita pela equipe.

## Requisitos de qualidade e verificação

- **003-CR-001**: Constituição v2.0.0 e skill Flutter: MVVM, Freezed, interfaces
  de Repository, Services para SDK, Result, autorização no servidor e nomes em inglês.
- **003-CR-002**: flutter_test para cada regra de VM/Repository/Service e domínio;
  Widget Tests felizes para editor, calendário e detalhes/auditoria, mais 320 px e
  texto ampliado. SQL/HTTP de permissões, concorrência, limites, fuso e replay.
- **003-CR-003**: Android real/emulador com segunda sessão, fixtures locais e CI;
  documentação, commits por contexto na developer e gates completos. Não declarar iOS
  validado por Windows, nem produção implantada por testes locais.
- **003-CR-004**: Nenhum pacote Flutter novo. Sem API externa de calendário,
  notificações locais/push, sincronização Google/Outlook ou execução offline de comandos.
  Refresh ao entrar/voltar e ação de recarregar; cada escrita revalida no servidor.

## Critérios de sucesso

- SC-001: Exemplos de recorrência reproduzidos no servidor sem aplicações duplicadas.
- SC-002: Nenhuma leitura/escrita privada permitida para visitante, não equipe ou sessão revogada.
- SC-003: Concorrência e replay mantêm uma conclusão vigente com autoria/hora verificáveis.
- SC-004: Correção/edição/interrupção preservam integralmente os eventos anteriores e atrasadas.
- SC-005: Três interfaces principais possuem Widget Test feliz; jornadas Android e CI aprovadas.

Entidades: tratamento estável, revisão imutável de programação, aplicação prevista,
evento de auditoria e recibo de operação. Detalhes em data-model.md e contracts/.
