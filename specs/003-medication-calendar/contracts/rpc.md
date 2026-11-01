# Contrato Supabase e Repository — medicações

Contrato alvo. Criação/listagem/recibo e leituras mês/dia/histórico implementadas
até migration 013, conclusão auditada na 014 e edição/interrupção/correção na 015.
Nenhum endpoint de Google/Outlook é necessário.

## Acesso e mensagens

Funções mutantes security definer, search_path='', nomes qualificados; revogar
PUBLIC/anon, conceder EXECUTE somente authenticated. private.is_staff_current()
antes/depois dos locks e no replay. RLS nas tabelas expostas, SELECT somente equipe
com sessão atual; sem INSERT/UPDATE/DELETE direto. Eventos/ledger sem grants diretos.
Leitura via RPC estreita verifica a mesma autorização. Não adicionar campos privados
à projeção de animals nem às RPCs públicas existentes.

Códigos: 22023 invalid_payload; 42501 staff_required; PT404 not_found;
PT409 operation_conflict/stale_version/already_completed; failures de rede/timeout
permanecem distinguíveis. serviceResult/mapRepositoryResult sanitizam. A UI mostra
mensagens PT, sem SQL, keys ou detalhes de sessão. Campos desconhecidos são rejeitados.

## Comandos

Todos usam p_operation_key e retornam {result, server_now, operation_key}; result
contém as entidades confirmadas com versões e valores civis. O recibo armazena a
resposta original inteira; replay não troca autor/hora pelo segundo pedido.

- save_medication_treatment(p_operation_key text, p_payload jsonb): campos
  treatment_id nullable, animal_id UUID, expected_revision nullable,
  expected_treatment_version nullable, medication_name,
  instructions, schedule_mode, starts_on YYYY-MM-DD, starts_time HH:mm,
  ends_on YYYY-MM-DD, ends_time HH:mm, fixed_times array HH:mm e interval_minutes.
  Modos exclusivos/limites conforme data-model.md. Em criação revision=1; em edição
  mesma animal_id, expected_revision obrigatória e nova revisão. Não aceitar
  autoria, performed_at, timezone arbitrária, eventos ou aplicações no payload.
- stop_medication_treatment(p_operation_key, p_treatment_id, p_expected_revision,
  p_expected_treatment_version):
  aplica corte e interrupção; devolve tratamento/revisão atual e contagem cancelada.
  Revisões de programação são imutáveis e só save as cria. Stop incrementa
  treatment_version independente, exigida também em save, sem criar nova revisão.
- complete_medication_application(p_operation_key, p_application_id, p_expected_version):
  concluir apenas devida/pending; devolve aplicação e evento com autor/hora servidor.
- reverse_medication_completion(p_operation_key, p_application_id, p_expected_version,
  p_reason): motivo 1–500 caracteres; evento novo, projeção pending, original preservado.
- get_medication_operation(p_operation_key): recibo do ator ainda autorizado ou NULL.

## Versão do tratamento

medication_treatments possui treatment_version integer >=1, independente da revisão.
Save recebe também expected_treatment_version (NULL na criação); stop usa
p_expected_treatment_version além de expected_revision. Toda alteração/stop incrementa
essa versão, inclusive primeiro stop; replay da mesma chave não incrementa. Stop de
tratamento já parado não incrementa, mas exige versões atuais. Essa separação evita
inventar uma revisão de programação ao interromper, e protege stop versus edição.
Save de tratamento stopped é rejeitado: não há reativação implícita nesta entrega.

## Leituras

- list_animal_medication_treatments(p_animal_id, p_cursor nullable): ativos e parados,
  50 itens/página ordenados por created_at/id; incluir revisão atual e treatment_version.
- get_medication_calendar_month(p_month YYYY-MM): 1 mês, zona fixa; resposta tem
  server_now, shelter_today, timezone, month e contagens por dia por estado. Marca
  dias com pending/completed; cancelled não produz indicador ativo, mas histórico existe.
- list_medication_day(p_day YYYY-MM-DD, p_cursor nullable): 100 aplicações/página,
  incluindo cancelled; ordem (scheduled_at,id). Retornar server_now, agenda_version
  do snapshot, items e next_cursor. Cursor opaco vinculado ao dia, usuário e snapshot;
  alteração relevante entre páginas devolve PT409 e VM reinicia o dia, sem mesclar
  snapshots. Assim nenhuma página oculta/duplica aplicações silenciosamente.
- get_medication_application_history(p_application_id, p_cursor nullable): 100 eventos
  por página, ordem (application_version,id), com revisão e versão atual. Cursor estável.

Todos retornam instantes RFC3339 com offset/UTC e valores civis calculados pelo
servidor scheduled_local_date/time e performed_local_date/time, quando aplicáveis.
O cliente nunca interpreta timestamps UTC como datas de calendário do aparelho.
Atualizar ao entrar/retomar, trocar mês/dia e após comando; concorrência nunca depende
de Realtime. Snapshot/agenda_version precisa de contador transacional privado,
incrementado a cada mutação de medicação; tabela própria no modelo.

## Interface abstrata Dart

MedicationsRepository em lib/domain/repositories/medications_repository.dart:
listTreatments, saveTreatment, stopTreatment, loadMonth, loadDay, loadApplicationHistory,
completeApplication, reverseCompletion e getOperation. Todos Future<Result<T>>,
DTOs/SDK restritos a Services e implementações; nenhum tipo Supabase na interface.
Argumentos de escrita incluem versões e chave estável. Domínio usa Freezed.

Em estado incerto, o VM bloqueia reenvio alterado, consulta getOperation e só oferece
repetição com mesma chave/payload se não houver recibo. 401/403 revalida acesso sem
expor dados; logout/troca/revogação limpa. Operações in-flight e mês antigo não podem
sobrescrever a seleção/sessão vigente. Não inferir sucesso por estado local.
