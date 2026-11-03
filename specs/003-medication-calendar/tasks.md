# Tarefas — calendário de medicamentos

Branch: developer. Origem: spec.md, plan.md, research.md, data-model.md e contracts/rpc.md.
Implementação autorizada; marcar somente tarefas comprovadas. Testes são obrigatórios.
C001–C007 de scope.md são resumos históricos; esta é a lista executável e autoritativa.

## Fase 1 — preparação

- [x] T001 Apresentar e registrar aprovação explícita da composição do calendário, editor de recorrência e detalhes em specs/003-medication-calendar/design-approval.md; comparar screen-5/screen-6 do protótipo e preservar topo/abas/cores. Bloqueia somente as Views novas. [003-FR-014]
- [x] T002 Conferir estrutura e fronteiras em test/architecture/layer_boundaries_test.dart e lib/app/public_dependencies.dart; usar dependências existentes sem alterar pubspec.yaml; registrar baseline em specs/003-medication-calendar/validation.md. [003-CR-001, 003-CR-004]
- [x] T003 Preparar fixtures/fakes locais e relógio injetável em test/support/fakes/fake_medications_repository.dart e test/support/fakes/fake_medications_service.dart, sem dados privados persistidos ou credenciais compiladas. [003-CR-002, 003-CR-003]

## Fase 2 — fundação e segurança

- [x] T004 [P] Escrever testes de validação em test/domain/models/medication_schedule_test.dart: nome “1–120”, instruções “até 1.000”, “até 366 dias civis inclusivos”, anos “2000 e 2100”, horários “1–24” distintos HH:mm, intervalo “1 a 10.080” e máximo “10.000 aplicações por revisão”; limites exatos e inválidos. [003-FR-007, 003-FR-012]
- [x] T005 [P] Escrever testes de autorização/schema em supabase/tests/database/medication_foundation.test.sql: anon, não equipe, sessão ausente/expirada/revogada, RLS, DML direto negado, eventos/ledger privados, tratamento com FK RESTRICT e animal publicado sem acesso público. [003-FR-006, 003-FR-005]
- [x] T006 Criar modelos Freezed/validadores em lib/domain/models/medication_treatment.dart, medication_schedule.dart, medication_application.dart e medication_agenda.dart; estados e versões integer >=1, modos exclusivos, datas/limites de T004 e domínio sem SDK/UI; gerar arquivos imutáveis. [003-FR-012, 003-CR-001]
- [x] T007 Criar migration aditiva supabase/migrations/202610310011_medication_foundation.sql com tratamentos/revisões/aplicações/eventos, display_name opcional “1–120 caracteres após trim” em staff_members, FKs deferidas para a revisão vigente, índices únicos (tratamento/revisão/instante e parcial pending/completed), RLS, ledger privado e contador agenda_version bigint >=0 transacional; sem mudar migrations antigas/write_operations legado. [003-FR-005, 003-FR-006, 003-FR-011]
- [x] T008 Definir MedicationsRepository Future<Result<T>> em lib/domain/repositories/medications_repository.dart e contrato Service em lib/data/services/medications_service.dart, incluindo leitura, gravação, conclusão, interrupção, correção, histórico e recibo, conforme contracts/rpc.md. [003-CR-001, 003-FR-011]
- [x] T009 Escrever testes DTO/Result em test/data/models/medication_dto_test.dart e test/data/services/supabase_medications_service_test.dart: tipos/enum/data malformados, versões, respostas legadas inválidas, SQL/SDK/timeout sanitizados, nenhum ator/hora real no payload. [003-CR-001, 003-CR-002, 003-FR-008]
- [x] T010 Implementar DTOs e esqueleto Supabase Service em lib/data/models/medication_dto.dart e lib/data/services/supabase_medications_service.dart, reutilizando serviceResult e validando campos/limites das respostas; SDK somente nesse Service/composição. [003-CR-001]

## Fase 3 — US1: cadastrar e gerar aplicações (P1)

Aceitação independente: ver a jornada US1 em spec.md; semear dependências pela RPC para testar isoladamente.

- [x] T011 [P] [US1] Escrever supabase/tests/database/medication_schedule.test.sql: horários fixos 08h/20h, intervalo 480 minutos, limites inclusivos, meia-noite/mês/ano, gaps/folds históricos de São Paulo, duplicados, 10.000/excesso, payload desconhecido, rollback e replay normalizado. [003-FR-004, 003-FR-007, 003-FR-012]
- [x] T012 [P] [US1] Escrever test/data/repositories/medications_repository_test.dart: gravação/mapeamento real com Service falso, validação de limites, Result, mesma chave, conflito e timeout; preservar dados públicos/privados separados. [003-CR-001, 003-FR-011]
- [x] T013 [P] [US1] Escrever test/ui/features/medications/view_models/medication_editor_view_model_test.dart: ambos os modos, validação, animal ainda não salvo, carregar, sucesso/erro/incerto, rascunho na revalidação e descarte por troca/revogação. [003-FR-005, 003-FR-013, 003-CR-002]
- [x] T014 [US1] Implementar resolvedor IANA, geração finita e save/list/getOperation em supabase/migrations/202610310012_medication_treatments.sql: ledger próprio, auth antes/depois dos locks, animal→tratamento→aplicações→contador, versão esperada, limites integrais e rollback; permitir somente criação nesta fase, rejeitando edição até US4. [003-FR-004, 003-FR-007, 003-FR-011, 003-FR-012]
- [x] T015 [US1] Implementar chamadas de tratamentos no lib/data/services/supabase_medications_service.dart e lib/data/repositories/medications_repository_impl.dart: trim/canonização, DTO→domínio, validação e mapRepositoryResult, sem duplicar recorrência IANA no app. [003-FR-004, 003-CR-001]
- [x] T016 [US1] Implementar MedicationEditorViewModel em lib/ui/features/medications/view_models/medication_editor_view_model.dart: rascunho imutável, seleção do modo, capacidades e validação; reconciliação por operação estável, ignorando respostas de outro animal/sessão. [003-FR-011, 003-FR-013]
- [x] T017 [US1] Escrever Widget Test feliz e erro em test/ui/features/medications/views/medication_editor_panel_test.dart: selecionar animal salvo, preencher cada modo e confirmar; manter binding ao salvar ficha geral. Depende de T001 para expectativas visuais. [003-CR-002, 003-FR-014]
- [x] T018 [US1] Integrar lib/ui/features/medications/views/medication_editor_panel.dart nos cartões da ficha lib/ui/features/animals/views/animal_editor_screen.dart, somente após T001; salvar medicação separadamente, preservando tratamentos ao salvar o animal. [003-FR-005, 003-FR-014]
- [x] T019 [US1] Registrar Service/Repository/VM em lib/app/public_dependencies.dart e lib/app/app_router.dart com ProtectedScope, listeners/dispose, authorize/accessEpoch/privateGeneration; binding por animal_id, não formVersion. [003-FR-013, 003-CR-001]
- [x] T020 [US1] Validar US1 com testes e duas sessões locais em supabase/tests/fixtures/medication_flow.py e registrar specs/003-medication-calendar/validation.md; publicar contexto aprovado na developer com IDs reais. [003-CR-003, 003-FR-004]

## Fase 4 — US2: mês e agenda do dia (P1)

Aceitação independente: ver a jornada US2 em spec.md; semear dependências pela RPC para testar isoladamente.

- [x] T021 [P] [US2] Escrever supabase/tests/database/medication_agenda.test.sql: mês/dia civil, contagens, ordenação scheduled_at/id, 100 itens/página, cursor <=1.024 bytes vinculado a ator/dia/snapshot, PT409 após mutação e nenhuma exposição pública. [003-FR-001, 003-FR-002, 003-FR-006]
- [x] T022 [P] [US2] Escrever test/ui/features/medications/view_models/medication_calendar_view_model_test.dart: 28/29/30/31 dias, fuso do aparelho, simultâneos, vazio/erro, paginação completa, conflito de snapshot e respostas antigas de mês/sessão. [003-FR-001, 003-FR-002, 003-FR-013]
- [x] T023 [US2] Implementar RPCs mês/dia/histórico em supabase/migrations/202610310013_medication_agenda.sql com snapshot SQL único de versão/linhas, contagens completas indexadas, limite 100 eventos/página ordenados por application_version/id e civis/UTC calculados pelo servidor; tratamentos 50/página. [003-FR-001, 003-FR-002, 003-FR-006]
- [x] T024 [US2] Estender test/data/services/supabase_medications_service_test.dart e test/data/repositories/medications_repository_test.dart para leituras paginadas, conversões civis e erros de cursor; implementar no Service/Repository existentes de medicações. [003-FR-002, 003-CR-002]
- [x] T025 [US2] Implementar MedicationCalendarViewModel em lib/ui/features/medications/view_models/medication_calendar_view_model.dart: células/labels/capacidades prontos, selecionar mês/dia, refresh/retorno, paginação e atraso por referência do servidor, sem timezone fixo. [003-FR-001, 003-FR-002, 003-FR-003, 003-FR-013]
- [x] T026 [US2] Escrever test/ui/features/medications/views/medication_calendar_panel_test.dart e ampliar test/ui/features/animals/views/dashboard_screen_test.dart: navegar mês, escolher dia, lista, vazio e regressões Kanban/Lista; 320 px e texto ampliado. Depende de T001. [003-FR-014, 003-CR-002]
- [x] T027 [US2] Implementar lib/ui/features/medications/views/medication_calendar_panel.dart e integrar DashboardMode/callback em lib/ui/features/animals/view_models/dashboard_view_model.dart, dashboard_screen.dart e lib/app/app_router.dart; preservar topo/abas, iniciar cargas fora de build. Depende de T001. [003-FR-001, 003-FR-014]
- [x] T028 [US2] Validar US2 sem depender da conclusão: fixtures de agenda, todas as páginas e revisão visual aprovada; registrar specs/003-medication-calendar/validation.md e publicar contexto na developer. [003-CR-003]

## Fase 5 — US3: aplicação e autoria (P1)

Aceitação independente: ver a jornada US3 em spec.md; semear dependências pela RPC para testar isoladamente.

- [x] T029 [US3] Escrever supabase/tests/database/medication_completion.test.sql e concorrência em supabase/tests/fixtures/medication_flow.py: duas sessões, ator/hora forjados negados, futura/cancelada negada, clock_timestamp após lock, mesmo recibo/replay e revogação após espera. [003-FR-008, 003-FR-011, 003-FR-006]
- [x] T030 [US3] Estender test/data/repositories/medications_repository_test.dart e test/ui/features/medications/view_models/medication_calendar_view_model_test.dart: conclusão/incerto/conflito, sem estado otimista falso, preservar ator/instante no replay, impedir ação quando não pode. [003-FR-003, 003-FR-008, 003-FR-011]
- [x] T031 [US3] Implementar complete_medication_application em supabase/migrations/202610310014_medication_completion.sql: versões, locks/rechecagem de equipe, hora capturada após espera, evento e recibo na mesma transação, contador atualizado somente em mutação. [003-FR-008, 003-FR-011]
- [x] T032 [US3] Integrar conclusão ao lib/data/services/supabase_medications_service.dart, lib/data/repositories/medications_repository_impl.dart e lib/ui/features/medications/view_models/medication_calendar_view_model.dart; revalidar acesso, reconciliar mesma chave/payload, atualizar snapshots. [003-FR-008, 003-FR-011, 003-FR-013]
- [x] T033 [US3] Escrever test/ui/features/medications/view_models/medication_application_view_model_test.dart e test/ui/features/medications/views/medication_application_details_sheet_test.dart: detalhes, autor/horário previsto/real, paginação de eventos e mensagens amigáveis. Depende de T001 para composição. [003-FR-008, 003-CR-002]
- [x] T034 [US3] Implementar MedicationApplicationViewModel e lib/ui/features/medications/views/medication_application_details_sheet.dart após T001; a View exibe estado pronto sem SDK/Repository ou regra de autorização em build. [003-FR-008, 003-FR-014, 003-CR-001]
- [x] T035 [US3] Ampliar test/ui/features/medications/views/medication_calendar_panel_test.dart para concluir uma aplicação devida e ver funcionário/horário confirmados; timeout/conflito sem duplicar e 320 px sem overflow. [003-FR-003, 003-FR-008, 003-CR-002]
- [x] T036 [US3] Validar US3 via duas sessões reais em supabase/tests/fixtures/medication_flow.py e registrar specs/003-medication-calendar/validation.md; publicar contexto na developer. [003-CR-003]

## Fase 6 — US4: revisões, interrupção e correção (P2)

Aceitação independente: ver a jornada US4 em spec.md; semear dependências pela RPC para testar isoladamente.

- [x] T037 [US4] Escrever supabase/tests/database/medication_revision_audit.test.sql: corte após locks, pending futura cancelada, atrasada/realizada preservada, índice ativo sem duplicar, edição parada negada, stop repetido e conclusão concorrente. [003-FR-009, 003-FR-011, 003-FR-015]
- [x] T038 [US4] Escrever casos de correção no supabase/tests/database/medication_revision_audit.test.sql: motivo “1–500 caracteres”, versão esperada, completed→pending, evento anterior imutável, corretor/hora reais e nova conclusão distinta. [003-FR-010]
- [x] T039 [US4] Estender testes de Repository/Service e VMs em test/data/repositories/medications_repository_test.dart, test/ui/features/medications/view_models/medication_editor_view_model_test.dart e medication_application_view_model_test.dart: interromper/editar/corrigir, conflito, sessão e estado incerto. [003-FR-009, 003-FR-010, 003-FR-013]
- [x] T040 [US4] Implementar save com revisão, stop e reverse em supabase/migrations/202610310015_medication_revision_audit.sql: treatment_version separado de revisão, motivo, histórico append-only, atrasadas preservadas, nova série somente após corte e sem mudança automática por adoção. [003-FR-009, 003-FR-010, 003-FR-015]
- [x] T041 [US4] Integrar os comandos em lib/data/services/supabase_medications_service.dart, lib/data/repositories/medications_repository_impl.dart e VMs medication_editor_view_model.dart/medication_application_view_model.dart; manter versões/recibos e não apagar auditoria. [003-FR-009, 003-FR-010, 003-FR-011]
- [x] T042 [US4] Ampliar test/ui/features/medications/views/medication_editor_panel_test.dart e medication_application_details_sheet_test.dart com interrupção, correção justificada e histórico original; plugar controles apenas da composição aprovada em T001. [003-FR-009, 003-FR-010, 003-FR-014, 003-CR-002]
- [x] T043 [US4] Ampliar supabase/tests/fixtures/medication_flow.py: edição/stop/conclusão simultâneos, timeout após commit, revogação, animal publicado/adotado e save_animal sem alterar identidades/aplicações. [003-FR-005, 003-FR-006, 003-FR-009, 003-FR-010, 003-FR-015]
- [x] T044 [US4] Validar US4 e registrar evidências em specs/003-medication-calendar/validation.md; revisar preservação das atrasadas e publicar contexto aprovado na developer. [003-CR-003]

## Fase 7 — entrega e regressões

- [x] T045 Implementar integration_test/medication_calendar_flow_test.dart: ambos os modos, mês/dia, segunda sessão, autoria/hora, interrupção/correção, privacidade e retorno ao app; usar controlador supabase/tests/fixtures/android_auth_control.py com fixtures exclusivas A/B com nomes de teste sem credenciais na build. [003-CR-003]
- [x] T046 Ampliar .github/scripts/android_management.sh para jornada de medicações e .github/workflows/flutter.yml somente se necessário para executar os novos SQL/HTTP; confirmar gates remotos e artifact, sem omitir falha. [003-CR-003]
- [x] T047 Executar geração determinística, formato, analyze, flutter test, pgTAP e HTTP; revisar test/architecture/layer_boundaries_test.dart, nomes PT/inglês, erros Result, limites de 10.000 aplicações e ausência de dados privados em catálogo/favoritos. Registrar specs/003-medication-calendar/validation.md. [003-CR-001, 003-CR-002, 003-FR-012]
- [x] T048 Validar Android, comparar visual com aprovação T001, reinstalar/abrir APK normal e registrar link CI/artifact em specs/003-medication-calendar/validation.md; iOS separado depende de Mac/Xcode. [003-FR-014, 003-CR-003]
- [x] T049 Atualizar README.md, specs/003-medication-calendar/quickstart.md e validation.md com uso real, limitações, dados privados e evidências; não apresentar notificações/API externa como disponíveis. [003-CR-004, 003-CR-003]
- [x] T050 Revisar git status/commits por contexto na developer e marcar somente tarefas comprovadas em specs/003-medication-calendar/tasks.md; preservar main e não aplicar produção implicitamente. [003-CR-003]

## Dependências e execução

T002/T003 → fundação T004–T010 → US1 T011–T020 → US2 T021–T028 → US3 T029–T036 → US4 T037–T044 → entrega T045–T050.
T001 é gate visual independente: bloqueia T017/T018, T026/T027, T033/T034 e as novas composições em T042. Não bloqueia modelos, testes de contrato ou backend. Não obter aprovação por silêncio.
Na US1, fundação deve estar pronta antes dos testes dependentes. Escrever testes antes das implementações correspondentes; testes vermelhos esperados não contam como entrega validada.
T011/T012/T013 podem ser escritos em paralelo após fundação; T021/T022 também após US1. Nenhuma mutação em migrations/Service/Repository compartilhados é paralela. Marcador [P] não autoriza agentes sem a instrução aplicável.
US3 depende dos DTOs/snapshots de US2, mas pode ser validada com fixtures sem navegar mês; US4 depende dos eventos de US3, também validável via RPC.

## Estratégia incremental

MVP funcional: US1 + US2 para cadastrar e consultar a agenda; US1 isolada já entrega persistência e geração verificável pela RPC. US3 completa a lista de tarefas; US4 entrega gestão/correções. Não declarar o calendário inteiro pronto antes de US4 e dos gates finais.
Após cada contexto aprovado, atualizar evidências e fazer commit/push na developer no padrão tipo(escopo): imperativo [003-FR/CR real]. Não acumular contextos nem marcar tarefas por mera existência de código.

Total: 50 tarefas. Distribuição: transversal: 16, US1: 10, US2: 8, US3: 8, US4: 8.

## Ajuste adicional autorizado — navegação visível

- [x] T051 Adicionar Voltar onde ausente no login, painel de manejo e telas internas, sem remover Fechar existente; preservar guards/reautenticação, refletir a adição no protótipo e validar Widgets/Android. Solicitação expressa do usuário em 2026-11-01; item independente das fases restantes. [003-FR-014, 003-CR-002, 003-CR-003]

## Correção de interação na agenda

- [x] T052 Fazer o cartão inteiro da aplicação abrir os detalhes ao tocar no nome, medicamento ou área livre, mantendo a seta, o design e a confirmação explícita de conclusão. Validar regressão Widget, analyze, suíte Flutter e abertura/conclusão no Android com animal fictício; registrar evidências e commit na developer. [003-FR-008, 003-FR-014, 003-CR-002, 003-CR-003]


## Situação automática por medicação — decisão de 2026-11-02

- [x] T053 Registrar 003-FR-015 e decisões: quarentena preservada, pendências impedem liberação, agendamentos futuros e múltiplos tratamentos; planejar execução no servidor. [003-FR-015]
- [x] T054 Implementar migration/rotina agendada e testes SQL de início, término, interrupção, pendências, correção, quarentena/adotado, manual sem medicação, múltiplos tratamentos e acesso negado. [003-FR-015, 003-CR-002]
- [x] T055 Validar integração HTTP/concorrência e Android com os novos exemplos com fotos; preservar dados manuais, atualizar documentação e commit por contexto na developer. [003-FR-015, 003-CR-003]

- [ ] T056 Acompanhar CI remota da automação e da jornada local documentada; distinguir perfil manual com oito fotos da suíte descartável da CI. [003-FR-015, 003-CR-003]
