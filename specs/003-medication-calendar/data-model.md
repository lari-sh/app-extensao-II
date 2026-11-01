# Modelo de dados — agenda privada

Todos os nomes abaixo são novos e propostos; não aplicar DDL nesta etapa.

## medication_treatments

UUID estável; animal_id FK animals com RESTRICT; current_revision integer >=1; treatment_version integer >=1;
status active/stopped; referência (id,current_revision) à revisão vigente com FK
DEFERRABLE INITIALLY DEFERRED para criação atômica; created_by/created_at, updated_by/updated_at; stopped_at
nullable. Não apagar tratamento, animal referenciado ou histórico pelo cliente.
Nome e programação pertencem às revisões. Adoção não altera status automaticamente.

## medication_treatment_revisions

PK (treatment_id, revision); medication_name: 1–120 caracteres após trim;
instructions: opcional até 1.000 caracteres; schedule_mode fixed_times/interval;
timezone: exatamente America/Sao_Paulo; starts_at/ends_at timestamptz com fim
estritamente posterior ao início e até 366 dias civis inclusivos na zona.
Datas de entrada entre 2000 e 2100. fixed_times: 1–24 horários distintos HH:mm,
ordenados/canonizados; interval_minutes: NULL. interval: inteiro de 1 a 10.080,
fixed_times vazio. Autor/hora do servidor. Revisões imutáveis; nova edição cria outra.

Datas civis e horários vêm separados no payload. O servidor resolve a zona e
rejeita gaps/folds. No intervalo de anos suportado, resolver procura candidatos
UTC com offsets em minutos entre -14h e +14h cuja volta à zona reproduza exatamente
o timestamp civil: zero candidatos = inexistente; dois = ambíguo; um = válido.
A implementação pode otimizar/cachear por offset, preservando essa semântica e
os testes das transições de São Paulo. Não usar somente cast, offset fixo ou
roundtrip único, que não detecta ambiguidade. O custo é validado com série limite.

## medication_applications

id UUID; treatment_id e revision FK; scheduled_at timestamptz; state
pending/completed/cancelled; version integer >=1; performed_by/performed_at
ambos preenchidos somente quando completed; cancelled_at/reason quando cancelled.
UNIQUE(treatment_id, revision, scheduled_at). Índice UNIQUE parcial
(treatment_id, scheduled_at) WHERE state IN ('pending','completed'). Índices de
consulta (scheduled_at,id), (treatment_id,scheduled_at) e por estado quando útil.
Animal/medicamento/instruções da aplicação vêm da sua revisão, não da revisão atual.

Gerar no máximo 10.000 aplicações por revisão, em transação única. fixed_times
expande datas civis, resolve cada horário e mantém starts_at <= instante <= ends_at.
interval expande starts_at + n * interval_minutes em duração decorrida até ends_at
inclusivo. Erro ou limite excedido faz rollback de toda a gravação.
Na criação, datas explicitamente passadas geram pendentes, jamais conclusões históricas.

Atrasada é derivada no snapshot: pending e scheduled_at < server_now. Igualdade
permite concluir sem ser atrasada. Estado não é alterado por relógio do aparelho.

## medication_application_events

UUID; application_id; event_type completed/completion_reversed/cancelled;
actor_id; occurred_at capturado no servidor; reason nullable (obrigatório com
1–500 caracteres em completion_reversed); application_version; snapshot do
horário previsto e referência da revisão. Só INSERT por comandos autorizados,
sem UPDATE/DELETE do cliente. Não expor email de auth.users na agenda: retornar
identificador e nome público interno de exibição do funcionário, quando existente;
na ausência, exibir identificação estável do funcionário, nunca fabricar um nome.
A migration de fundação acrescenta display_name opcional (1–120 caracteres após
trim) a staff_members; provisionamento fora do cliente. Eventos guardam também o
rótulo confirmado naquele momento; renomear perfil não reescreve o histórico.
Fixtures A/B possuem nomes claramente identificados como teste.
FKs de autoria preservam histórico (sem cascade destrutivo de contas pelo cliente).

## private.medication_operations

PK (actor_id, operation_key); operation_key com 32 caracteres [A-Za-z0-9_-];
operation_kind save_treatment/stop_treatment/complete_application/reverse_completion;
payload_digest normalizado; result JSONB; created_at. Sem grants ao cliente;
consulta por RPC somente do ator ainda autorizado. Ledger próprio porque
write_operations legado possui CHECK de kinds diferente. Sem misturar os recibos.

## Transações e transições

1. Validar equipe/sessão e payload; serializar actor/key; verificar digest/replay.
2. Ordem global: linha do animal → tratamento → aplicações ordenadas por ID;
   revalidar equipe/sessão após obter locks e antes de escrever.
3. Capturar clock_timestamp após os locks; uma variável serve ao corte da operação.
4. save: expected_revision e expected_treatment_version iguais às atuais (NULL somente em criação). Edição cancela
   pending estritamente futuras e gera nova revisão somente depois do corte; mantém
   pendentes vencidas, realizadas e seus snapshots. Antigas canceladas continuam no histórico.
5. stop: exige ambas as versões atuais, cancela pending futuras, marca stopped e
   incrementa treatment_version, sem criar revisão de programação. Save em stopped é rejeitado. Não cancela atrasadas nem realiza nada.
   Mesmo tratamento stopped ainda permite resolver aplicações passadas devidas.
6. complete: expected_version atual, pending e scheduled_at <= corte; auth.uid e
   corte viram performed_by/performed_at. Incrementa versão e insere evento.
7. reverse: expected_version atual e completed; motivo obrigatório; novo evento
   conserva autor/hora anteriores. Projeção volta a pending, limpa apenas os campos
   correntes performed_*, incrementa versão. Evento original permanece imutável.
8. Escrever recibo na mesma transação. Conflitos/rollback nunca deixam sucesso parcial.

Edição e conclusão concorrentes seguem as mesmas locks. Uma aplicação futura
cancelada não pode ser concluída. Concluída preservada não pode ser reprogramada.
Parada repetida com chave distinta exige expected_revision vigente e retorna o
estado já parado sem recriar aplicações, com recibo próprio.

## private.medication_agenda_state

Uma linha singleton com agenda_version bigint >=0. Cada mutação efetiva incrementa
por UPDATE transacional; replay não incrementa e rollback desfaz o incremento.
Lock da linha vem depois das aplicações, sempre na mesma ordem. Consultas do dia
leem versão e linhas em um único snapshot SQL. Cursor contém dia, ator, versão,
último scheduled_at/id, em representação opaca validada no servidor; tamanho máximo
1.024 bytes. Nova versão entre páginas exige recarregar o dia. Contador privado
não concede acesso aos dados. Usar UPDATE, não sequência não transacional.
