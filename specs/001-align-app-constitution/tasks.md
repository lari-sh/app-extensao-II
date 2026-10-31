# Tasks: Adequação do Abrigo dos Anjos à constituição

**Input**: `specs/001-align-app-constitution/`
**Created**: 2026-10-31
**Prerequisites**: [spec.md](spec.md), [plan.md](plan.md), [research.md](research.md),
[data-model.md](data-model.md), [Repository contracts](contracts/repositories.md),
[backend contracts](contracts/backend.md), [quickstart.md](quickstart.md) e
constituição 1.0.0 em `.specify/memory/constitution.md`.
**Status**: somente tarefas geradas; nenhum código, migration, função ou teste executado por este comando.

## Format and Execution Rules

- Cada linha de tarefa usa `- [ ] TNNN [P?] [USn?] descrição com caminhos e requisitos`.
- Todas começam pendentes. Marcar concluída somente com implementação/evidência
  real; indisponibilidade de Supabase/dispositivo deve ficar explicitamente pendente.
- Testes são **obrigatórios** por pedido e CONST-005/006, apesar do texto opcional
  do template genérico. Usar `flutter_test` para regras e Widgets, pgTAP e Deno/HTTP
  para banco/funções. Escrever os testes da fase primeiro, registrar a falha esperada,
  implementar e só avançar após os testes passarem. Falha de compilação por símbolo
  ainda ausente não substitui demonstrar a falha do comportamento após criar contratos.
- `[P]` indica apenas tarefas de arquivos distintos no mesmo lote de testes, após
  seus pré-requisitos. Não iniciar implementação antes do lote de testes; não
  paralelizar tarefas que alteram o mesmo arquivo, mesmo em histórias diferentes.
- IDs FR/CR/SC referem-se a esta especificação 001; usar qualificação `001-FR-...`
  no commit. Preservar a constituição; conflitos de tarefa/plano bloqueiam o avanço.
- Caminhos indicados são alvos de implementação, não arquivos já existentes.
  Classes/variáveis/arquivos em inglês, interface e mensagens em português.
- As constraints entre aspas são do modelo/plano e devem existir no servidor e no
  ViewModel quando aplicável, com testes de fronteira; não deixar escolhas implícitas.
- Não implantar em produção, cadastrar dados reais, aceitar segredos na build ou
  importar animais fictícios para a nuvem como parte dessas tarefas de adequação.

## Path Conventions

- Flutter: `lib/features/<feature>/ui/`, `domain/`, `data/`; compartilhados em
  `lib/core/`, composição em `lib/app/`.
- Testes seguem módulo/camada em `test/features/`; cenários reais em `integration_test/`.
- Backend: `supabase/migrations/`, `supabase/tests/` e `supabase/functions/`.
- Documentação/evidências: `specs/001-align-app-constitution/`.

## Phase 1: Setup — ambiente e rastreabilidade

**Goal**: Preparar ferramentas e estrutura sem importar dados fictícios ou alterar a constituição.

**Independent Test / Checkpoint**: Ferramentas/versões registradas, configuração de teste isolada e dependências limitadas ao plano.

- [ ] T001 Registrar baseline e evidências dos testes existentes em `specs/001-align-app-constitution/validation.md`, incluindo gaps atuais, requisitos FR/CR e regra de commits `tipo(escopo): descrição no imperativo [001-CR-007]` com IDs reais; não reescrever commits históricos. [CR-006, CR-007]
- [ ] T002 Resolver somente as dependências justificadas em `pubspec.yaml` e `pubspec.lock`: supabase_flutter 2.18.3 candidata, image_picker 1.2.4, SDK integration_test; manter shared_preferences 2.5.6/flutter_lints 6.0.0 e registrar resolução compatível com Flutter 3.41.1/Dart 3.11, sem adicionar pacotes não previstos. [CR-006]
- [ ] T003 Criar configuração local isolada em `supabase/config.toml`, `.gitignore` e `supabase/.env.example`, desabilitando cadastro público de contas, separando valores públicos Flutter de segredos exclusivamente servidor e documentando CLI/Deno/Docker fixados em `specs/001-align-app-constitution/quickstart.md`. [FR-004, FR-020, FR-021, CR-005]
- [ ] T004 Criar estrutura de composição em `lib/app/app_dependencies.dart` e diretórios `lib/features/{home,auth,animals,favorites,photos}/{ui,domain,data}/`, conforme a árvore do plano; não introduzir ViewModels dependentes de data ou Supabase. [CR-001]
- [ ] T005 Configurar runtime das funções em `supabase/functions/deno.json` e `supabase/functions/deno.lock`, fixando @supabase/supabase-js v2 e @imagemagick/magick-wasm v0 em versões exatas, com tarefas Deno de teste e permissões mínimas para teste local. [FR-013, CR-006]
- [ ] T006 Criar fixtures isoladas em `supabase/tests/fixtures/setup.ts` e `supabase/tests/fixtures/README.md` com visitante, conta sem staff, staff ativo, sessão revogável, mais de 50 animais e imagens válidas/inválidas; nesta tarefa apenas criar/documentar o script, sem provisionar registros. Executá-lo em T021 somente após T016/T017/T019, usando contexto administrativo local/homologação e sem depender das RPCs futuras; nunca importar demo_animals_v1 ou credenciais reais. [FR-005, FR-009, FR-020, CR-005]

**Checkpoint**: não avançar apresentando esta fase como concluída sem os testes e evidências acima.

---

## Phase 2: Foundational — contratos, Result e segurança base

**Goal**: Estabelecer fronteiras comuns e políticas fail-closed antes de conectar jornadas.

**Independent Test / Checkpoint**: Contratos compilam; Result/configuração/IDs e regras de acesso têm testes; backend não concede acesso administrativo por padrão.

- [ ] T007 [P] Escrever testes de sucesso/falha tipada, mensagens sem exceção bruta e eventos de stream em `test/core/result_test.dart`; usar flutter_test e nenhum serviço real. [FR-017, CR-002, CR-003]
- [ ] T008 [P] Escrever testes de configuração ausente/inválida e chave de operação estável por submissão em `test/core/app_config_test.dart` e `test/core/operation_id_test.dart`; garantir bytes aleatórios e ausência de segredos na apresentação. [FR-016, FR-021, CR-003]
- [ ] T009 [P] Escrever verificação de fronteiras em `test/architecture/layer_boundaries_test.dart`: proibir SDK externo nos Widgets, data/SDK nos VMs e domain, queries no bootstrap e lógica de negócio em build; validar módulos migrados durante a transição e todo o app após retirar o legado, sem conceder exceção na entrega final; permitir somente inicialização/injeção no bootstrap e planejar revisão manual complementar. [CR-001, CR-006]
- [ ] T010 Implementar Result sealed, Unit e AppFailure em `lib/core/result.dart` e `lib/core/app_failure.dart` com códigos validation/unauthenticated/forbidden/notFound/network/timeout/conflict/cancelled/permissionDenied/configuration/unknown, fieldErrors e retryable, sem objeto de exceção de SDK no contrato. Fazer os testes de Result passarem. [CR-002]
- [ ] T011 Implementar configuração em `lib/core/config/app_config.dart` e IDs em `lib/core/operation_id.dart`: operation_key com '24 bytes aleatórios em base64url', Random.secure, retenção da chave até reconciliação e URL/chave pública por dart-defines; nenhum service_role no app. [FR-016, FR-021, CR-006]
- [ ] T012 Criar entidades SDK-free em `lib/features/animals/domain/animal.dart`, `clinical_record.dart`, `animal_draft.dart` e `animal_query.dart`: PublicAnimal separado de ManagedAnimal; UUID do servidor, sem IDs demo; enums species 'dog ou cat', sex 'female ou male', size 'small, medium ou large', status 'available, treatment, quarantine ou adopted'; nome/idade 'texto, trim, 1–80 caracteres', descrição pública 'texto, 0–3.000 caracteres', primary_photo_id 'uuid opcional'. [FR-002, FR-003, FR-007, FR-008]
- [ ] T013 Definir interfaces em `lib/features/animals/domain/animals_repository.dart`, `lib/features/auth/domain/auth_repository.dart`, `session_access.dart`, `lib/features/favorites/domain/favorites_repository.dart`, `lib/features/photos/domain/photo_repository.dart`, `photo_candidate.dart`, `photo_content.dart`, `photo_selection_request.dart`, `photo_upload_state.dart` e `lib/features/home/domain/adoption_message_repository.dart`, incluindo motivo de interrupção de sessão tipado (expiração recuperável ou perda definitiva; causa desconhecida descarta rascunho), cobrindo todas as operações dos contratos, Future<Result<T>>, Stream<Result<SessionAccess>> e cancelamento Success(null). [CR-001, CR-002]
- [ ] T014 Criar fakes manuais dos contratos em `test/support/fakes/fake_animals_repository.dart`, `fake_auth_repository.dart`, `fake_favorites_repository.dart`, `fake_photo_repository.dart` e `fake_adoption_message_repository.dart`, com controle de Completers, falhas e streams; não substituir a implementação real nos testes de Repository. [CR-003, CR-004]
- [ ] T015 [P] Escrever pgTAP de grants/RLS, select=* e ausência de notas/autoria nos dados públicos em `supabase/tests/database/authorization.test.sql`; testar anon, autenticado sem staff, staff ativo e sessão/membership revogados. [FR-003, FR-005, FR-006, CR-005]
- [ ] T016 Criar schema em `supabase/migrations/202610310001_animal_schema.sql`: animals com dados públicos apenas, is_published 'boolean, default false', is_vaccinated/is_neutered 'boolean, default false'; animal_internal_details com animal_id 'uuid, chave primária e referência a animals (1:1)', clinical_notes 'texto até 3.000 caracteres, default vazio'; clinical_records com animal_id obrigatório (1:N), kind 'vaccination, deworming ou medication', description 'trim, 1–1.000 caracteres'; timestamps/autoria do servidor nas tabelas internas. Repetir constraints no banco. [FR-003, FR-007, FR-008, FR-011]
- [ ] T017 Criar autorização em `supabase/migrations/202610310002_authorization.sql`: staff_members.user_id 'uuid, chave primária e referência a auth.users', active 'boolean, default false'; helper private com search_path vazio, auth.uid/session_id/auth.sessions e membership atual; RLS de todas as tabelas e access_context somente do próprio ator; revogar DML direto/EXECUTE PUBLIC e proibir autoaprovação e listagem da equipe. Fazer pgTAP passar. [FR-004, FR-005, FR-006, CR-005]
- [ ] T018 Definir bootstrap seguro em `lib/app/bootstrap.dart` e `lib/main.dart`: inicializar Supabase/injetar Repositories sem queries fora deles, estado explícito de configuração indisponível e nenhum acesso administrativo ou carga de demo como fallback; conectar telas somente após seus VMs estarem disponíveis nas fases seguintes. [FR-020, FR-021, CR-001]
- [ ] T019 Preparar infraestrutura de foto privada em `supabase/migrations/202610310003_photo_jobs.sql`: bucket animal-photos JPEG/PNG até '5.242.880 bytes', jobs id UUID do servidor, animal/actor/session verificados, operation_key única por ator, caminhos imutáveis, byte_size '1–5.242.880 bytes', state 'pending, validated, attached, cleanup_needed, cleaned ou failed', previous_photo_id opcional; payload_digest e detected_mime definidos pelo servidor, created_at/updated_at e error_code internos; fila com job_id/object_path únicos, attempts/next_attempt_at/last_error_code/completed_at e motivos failed_candidate/superseded; negar Storage direto a anon/authenticated. [FR-013, FR-014, FR-015]
- [ ] T020 Extrair tema e componentes puramente visuais em `lib/core/theme/app_theme.dart`, `lib/core/widgets/animal_portrait.dart` e `status_badge.dart`, preservando `assets/images/logo.png`, vermelho/marrom e Image.memory/placeholder; dados e rótulos/capacidades vêm prontos dos VMs. [FR-019, CR-001]
- [ ] T021 Após aplicar as migrations T016/T017/T019, executar e verificar o script de fixtures de T006 em `supabase/tests/fixtures/setup.ts`, sem RPCs futuras nem produção; então executar testes de fundação, comprovar policies e registrar resultados em `specs/001-align-app-constitution/validation.md`; falhas de ambiente bloqueiam comprovação backend, não podem ser marcadas como PASS por mocks. Validar contratos e fronteiras antes de iniciar as histórias. [CR-003, CR-005, CR-007]

**Checkpoint**: não avançar apresentando esta fase como concluída sem os testes e evidências acima.

---

## Phase 3: User Story 1 — Conhecer os animais sem criar conta (P1)

**Goal**: Entregar catálogo público, favoritos e detalhes sem credenciais.

**Independent Test / Checkpoint**: Visitante usa filtros, paginação, detalhes e favoritos persistentes; ocultos/adotados não fornecem dados privados. Foto de fixture validada é servida pelo proxy; upload real pertence à US4.

### Tests — obrigatórios, antes da implementação

- [ ] T022 [P] [US1] Escrever testes da leitura pública real do Repository em `test/features/animals/data/supabase_animals_repository_test.dart`, com callbacks controlados: combinações de filtros antes de paginar, ordenação name/id, mais de 50 itens, total, favorito inválido, notFound oculto e captura PostgrestException/rede/timeout. [FR-001, FR-002, FR-003, CR-003]
- [ ] T023 [P] [US1] Escrever testes de persistência de IDs/falha local em `test/features/favorites/data/local_favorites_repository_test.dart` e de Clipboard em `test/features/home/data/clipboard_adoption_message_repository_test.dart`, testando implementações reais por operações injetadas. [FR-001, FR-018, CR-003]
- [ ] T024 [P] [US1] Escrever testes de HomeViewModel/AboutViewModel em `test/features/home/ui/home_view_model_test.dart` e `about_view_model_test.dart`, incluindo eventos de navegação e mensagens em português sem lógica de negócio na View. [FR-001, FR-019, CR-003]
- [ ] T025 [P] [US1] Escrever testes de filtro, reinício de cursor, loading/erro/empty e respostas tardias em `test/features/animals/ui/catalog_view_model_test.dart`; nenhuma filtragem limitada à página corrente. [FR-001, FR-002, FR-016, FR-021, CR-003]
- [ ] T026 [P] [US1] Escrever testes de interseção com animais visíveis e alteração de favoritos em `test/features/favorites/ui/favorites_view_model_test.dart`, incluindo falha de preferências e IDs legados sem importação. [FR-001, FR-020, CR-003]
- [ ] T027 [P] [US1] Escrever testes de detalhes, canAdopt somente published/available, foto ausente e cópia de interesse sem envio em `test/features/animals/ui/animal_detail_view_model_test.dart`. [FR-002, FR-003, FR-018, FR-021, CR-003]
- [ ] T028 [P] [US1] Escrever Widget Tests felizes de início e sobre em `test/features/home/ui/home_screen_test.dart` e `about_screen_test.dart`, verificando logo, conteúdo em português e navegação com VMs reais/fakes de Repository. [FR-019, CR-004]
- [ ] T029 [P] [US1] Escrever Widget Tests de busca combinada e favorito em `test/features/animals/ui/catalog_screen_test.dart` e `test/features/favorites/ui/favorites_screen_test.dart`. [FR-001, CR-004]
- [ ] T030 [P] [US1] Escrever Widget Test feliz de detalhe e cópia em `test/features/animals/ui/animal_detail_screen_test.dart`, sem notas privadas ou envio real de adoção. [FR-003, FR-018, CR-004]
- [ ] T031 [P] [US1] Escrever testes Deno/HTTP de leitura pública/privada atual, negação de caminho arbitrário, no-store, sem 304/redirect e negação imediata de novo pedido após despublicar/adotar em `supabase/functions/tests/photo_read_test.ts`; usar fixtures e acesso Storage direto negativo. [FR-015, CR-005]
- [ ] T032 [P] [US1] Escrever testes de readPrimary do PhotoRepository em `test/features/photos/data/supabase_photo_read_repository_test.dart`: bytes tipados, 401/403/404, foto corrompida/ausente, até quatro pedidos concorrentes e invalidação por refresh/sessão. [FR-015, FR-021, CR-003]
### Implementation and Validation

- [ ] T033 [US1] Implementar listPublic/getPublic/getVisibleByIds em `lib/features/animals/data/supabase_animals_repository.dart` com projeção pública, filtros parametrizados combinados, páginas de 50, cursor name/id e total; mapeamento/captura de erros em Result somente nessa implementação. [FR-001, FR-002, FR-003, FR-017]
- [ ] T034 [US1] Implementar favoritos em `lib/features/favorites/data/local_favorites_repository.dart` e Clipboard em `lib/features/home/data/clipboard_adoption_message_repository.dart`: usar favorites_v1 para IDs, ignorar IDs demo inválidos, confirmar estado só após persistência e não importar animais. [FR-001, FR-018, FR-020]
- [ ] T035 [US1] Implementar `supabase/functions/animal-photo-read/index.ts` e helpers em `supabase/functions/_shared/photo_access.ts`: verificar publicação/não adopted ou sessão+staff atuais, servir somente primary_photo_id associado, bytes com Cache-Control no-store/private e Pragma no-cache; sem URL assinada/redirect; configurar gateway somente dessa função para leitura de visitante. [FR-015, CR-005]
- [ ] T036 [US1] Implementar readPrimary e pontos de injeção em `lib/features/photos/data/supabase_photo_repository.dart`, retornando PhotoContent em bytes via função, limitando quatro pedidos simultâneos e sem Storage URL em Widgets; manter futuros métodos de upload indisponíveis de modo explícito até US4. [FR-015, FR-021, CR-001]
- [ ] T037 [US1] Implementar VMs públicos em `lib/features/home/ui/home_view_model.dart`, `about_view_model.dart`, `lib/features/animals/ui/catalog_view_model.dart`, `animal_detail_view_model.dart` e `lib/features/favorites/ui/favorites_view_model.dart`, com estados/capacidades, favoritos, mensagens e descarte de respostas antigas. [FR-001, FR-002, FR-016, FR-017, FR-018]
- [ ] T038 [US1] Construir Views em `lib/features/home/ui/home_screen.dart`, `about_screen.dart`, `lib/features/animals/ui/catalog_screen.dart`, `animal_detail_screen.dart` e `lib/features/favorites/ui/favorites_screen.dart`; ligar por `lib/app/abrigo_app.dart` e rotas públicas em `lib/app/app_router.dart`, consumindo VMs apenas e sem criar acesso privado provisório. [FR-001, FR-019, CR-001, CR-004]
- [ ] T039 [US1] Executar os testes US1 e jornada anônima com fixtures de mais de 50 animais, imagem pública e favorito após reinício; registrar evidência em `specs/001-align-app-constitution/validation.md`, incluindo falta de ambiente real como pendência, não sucesso. [SC-001, FR-002, FR-003, FR-015, CR-007]

**Checkpoint**: não avançar apresentando esta fase como concluída sem os testes e evidências acima.

---

## Phase 4: User Story 2 — Entrar e sair com acesso autorizado (P1)

**Goal**: Substituir a entrada de demonstração por autenticação e autorização verificadas.

**Independent Test / Checkpoint**: Conta autorizada entra e restaura sessão; não staff/credenciais inválidas/revogação são negados; logout limpa o privado e Voltar não o restaura.

### Tests — obrigatórios, antes da implementação

- [ ] T040 [P] [US2] Escrever unitários das operações AuthRepository em `test/features/auth/data/supabase_auth_repository_test.dart`: signIn, restoreAccess, currentAccess, watchAccess e signOut; AuthException, stream onError, timeout, sessão inválida e membership revogada sem SDK no resultado. [FR-004, FR-005, FR-006, FR-017, CR-003]
- [ ] T041 [P] [US2] Escrever testes de login e sessão em `test/features/auth/ui/login_view_model_test.dart` e `session_view_model_test.dart`: validação, mensagem genérica, checking fail-closed, não staff, resume, bloqueio duplicado, logout e respostas tardias; expiração preserva somente rascunho mascarado, retorno exige mesmo usuário e staff revalidado, revogação/troca de usuário/cancelamento descarta tudo. [FR-004, FR-005, FR-006, FR-016, CR-003]
- [ ] T042 [P] [US2] Escrever Widget Test feliz em `test/features/auth/ui/login_screen_test.dart` e teste de pilha/guarda em `test/app/app_router_test.dart`: sem conteúdo privado antes da verificação e sem retorno após logout; reautenticação por expiração mantém editor montado mas oculto e bloqueado, sem Voltar revelar dados. [FR-004, FR-006, CR-004]
- [ ] T043 [P] [US2] Escrever HTTP/pgTAP negativo com JWT ainda válido mas sessão removida ou staff desativado em `supabase/functions/tests/auth_access_test.ts` e `supabase/tests/database/session_access.test.sql`; validar ausência de autoaprovação via metadata. [FR-005, FR-006, CR-005]
### Implementation and Validation

- [ ] T044 [US2] Implementar `lib/features/auth/data/supabase_auth_repository.dart` com signIn/restore/current/watch/signOut, validação remota de usuário e access_context, conversão de erros e operações injetáveis no mesmo arquivo; falha remota de logout não reabre estado privado. [FR-004, FR-005, FR-006, CR-002]
- [ ] T045 [US2] Implementar `lib/features/auth/ui/login_view_model.dart` e `session_view_model.dart` com checking/visitor/authenticatedWithoutStaff/authorized/unavailable, capacidades prontas, validações portuguesas e revalidação antes de ações privadas/em resume. [FR-004, FR-005, FR-006, FR-016, FR-017]
- [ ] T046 [US2] Criar `lib/features/auth/ui/login_screen.dart` sem inscrição pública, recuperação de senha ou lógica de autorização em build; conectar sucesso/erro ao VM e remover a rota de exploração administrativa de `lib/screens/home.dart` assim que a nova rota estiver ligada. [FR-004, FR-020, CR-001]
- [ ] T047 [US2] Conectar sessão em `lib/app/bootstrap.dart`, `app_dependencies.dart` e `app_router.dart`: na expiração recuperável manter tela/EditorViewModel montados com máscara integral e ações/Voltar bloqueados, invalidar operações em voo e pedir login; retomar só após mesmo userId/staff revalidados. Em logout, revogação, outro usuário, causa desconhecida, fechamento ou cancelamento, descartar rascunho/dados/fotos/listeners e substituir pilha privada; manter entrada pública disponível. [FR-005, FR-006, FR-021]
- [ ] T048 [US2] Validar login, restore, não staff, revogação e logout em sessão real de teste; registrar resultados e ausência de bypass em `specs/001-align-app-constitution/validation.md`. [SC-002, FR-004, FR-005, FR-006, CR-007]

**Checkpoint**: não avançar apresentando esta fase como concluída sem os testes e evidências acima.

---

## Phase 5: User Story 3 — Cadastrar e manter animais na nuvem (P1)

**Goal**: Salvar/editar identificação, descrições e cuidados atomicamente e sem duplicações.

**Independent Test / Checkpoint**: Salvar, reiniciar e ler em outra sessão conserva dados; falhas preservam edição, não vazam notas e não criam animais duplicados.

### Tests — obrigatórios, antes da implementação

- [ ] T049 [P] [US3] Escrever pgTAP de save_animal em `supabase/tests/database/animal_save.test.sql`: constraints, rollback animal/notas/cuidados, autoria servidor, reautorização, chave repetida com mesmo payload e conflito com payload diferente. [FR-003, FR-007, FR-008, FR-009, FR-016, CR-005]
- [ ] T050 [P] [US3] Escrever testes de getManagement/listManagement/saveAnimal/getOperation da implementação real em `test/features/animals/data/supabase_animals_write_repository_test.dart`, incluindo PostgrestException, status negado, timeout após commit e reconciliação sem nova chave. [FR-005, FR-009, FR-016, FR-017, CR-003]
- [ ] T051 [P] [US3] Escrever testes de AnimalEditorViewModel em `test/features/animals/ui/animal_editor_view_model_test.dart`, cobrindo nome/idade 0/1/80/81, descrições 3000/3001, cuidados 0/1/1000/1001, enums, duplo clique, rascunho em memória com expiração/reauth do mesmo usuário autorizado, máscara sem acesso a dados privados e descarte em logout/revogação/outro usuário/fechamento/cancelamento. [FR-006, FR-007, FR-008, FR-016, CR-003]
- [ ] T052 [P] [US3] Escrever Widget Test de cadastro/edição em `test/features/animals/ui/animal_editor_screen_test.dart`: preencher campos, adicionar/remover cuidados, salvar e mostrar confirmação apenas após sucesso; upload será acrescentado na US4. [FR-007, FR-008, FR-009, CR-004]
### Implementation and Validation

- [ ] T053 [US3] Criar `supabase/migrations/202610310004_animal_writes.sql` com write_operations: 'actor_id, operation_key: chave única composta', operation_kind 'save_animal, set_status ou set_publication', digest normalizado/resultado privado e completed_at do servidor; save_animal transacional e get_write_operation somente do ator reautorizado. [FR-009, FR-016]
- [ ] T054 [US3] Implementar validações de save_animal em `supabase/migrations/202610310004_animal_writes.sql`: nome/idade 'texto, trim, 1–80 caracteres', descrição pública 'texto, 0–3.000 caracteres', clinical_notes 'texto até 3.000 caracteres, default vazio', kind 'vaccination, deworming ou medication', description de cuidado 'trim, 1–1.000 caracteres'; UUIDs/autoria/timestamps gerados no banco, novo animal privado e nenhuma escrita de primary_photo_id pelo formulário. [FR-007, FR-008, FR-009, FR-011]
- [ ] T055 [US3] Implementar consultas privadas, saveAnimal e getOperation em `lib/features/animals/data/supabase_animals_repository.dart`, com DTOs públicos/privados distintos, Result tipado, operação estável e métodos privados autorizados; não gravar preferências de prontuários ou impor sync offline. [FR-003, FR-005, FR-009, FR-017]
- [ ] T056 [US3] Implementar validação e comandos em `lib/features/animals/ui/animal_editor_view_model.dart`: regras iguais ao servidor, registros descritivos sem prescrição, chave retida após timeout, somente campos editáveis; rascunho somente em memória do editor mantido montado e integralmente mascarado durante reautenticação por expiração; retomar edição apenas para o mesmo usuário autorizado. Descartar rascunho em logout explícito, revogação, outro usuário, causa desconhecida, fechamento ou cancelamento; nenhuma persistência local. [FR-006, FR-007, FR-008, FR-016]
- [ ] T057 [US3] Criar `lib/features/animals/ui/animal_editor_screen.dart` com estados prontos do VM, sem validator de regra de negócio no Widget, consumo apenas de VM e criação/edição autenticada nas rotas em `lib/app/app_router.dart`. [FR-007, FR-008, FR-009, CR-001]
- [ ] T058 [US3] Comprovar atualização entre duas sessões e rollback/repetição pós-resposta perdida; registrar resultados em `specs/001-align-app-constitution/validation.md`, verificando que dados clínicos e demo locais nunca aparecem em leitura pública. [SC-003, FR-003, FR-009, FR-020, CR-007]

**Checkpoint**: não avançar apresentando esta fase como concluída sem os testes e evidências acima.

---

## Phase 6: User Story 4 — Adicionar e substituir a foto (P2)

**Goal**: Integrar galeria e upload validado, rastreável e autorizado, sem perda da imagem anterior.

**Independent Test / Checkpoint**: JPEG/PNG válido aparece após confirmação; cancelamento/falha preserva foto; bytes inválidos, acessos indevidos e duplicação são rejeitados.

### Tests — obrigatórios, antes da implementação

- [ ] T059 [P] [US4] Escrever testes de seleção/envio/reconciliação reais do Repository em `test/features/photos/data/supabase_photo_upload_repository_test.dart`: Success(null), retrieveLostData, size antes de leitura, permissão de galeria negada (incluindo PlatformException) convertida em Failure(permissionDenied), falhas StorageException/FunctionException/rede, operação estável e ausência de XFile/SDK no resultado. [FR-013, FR-014, FR-016, FR-017, CR-003]
- [ ] T060 [P] [US4] Escrever testes de PhotoUploadViewModel em `test/features/photos/ui/photo_upload_view_model_test.dart` e de PhotoRecoveryViewModel em `photo_recovery_view_model_test.dart`: nenhum upload automático recuperado, nova autorização/confirmação do animal, cancelamento Success(null), permissão negada com loading encerrado/mensagem portuguesa/formulário e foto anterior preservados/zero upload, foto anterior preservada e três consultas 1/2/4 s sem loading infinito ou nova chave prematura. [FR-005, FR-013, FR-014, FR-016, CR-003]
- [ ] T061 [P] [US4] Escrever testes Deno de upload em `supabase/functions/tests/photo_upload_test.ts`: bytes '1–5.242.880', arquivo de 5 MB exatos aceito com overhead multipart até 65.536 bytes, arquivo +1 byte rejeitado, corpo total acima de 5.308.416 bytes rejeitado, entrada válida cuja primeira saída normalizada ultrapassa 5 MB aceita após ajuste preservando proporção, extensão falsa, JPEG/PNG corrompido, metadata removida, falha pré/pós-commit, JWT não staff/revogado, corpo limitado e validação antes de associação. [FR-013, FR-014, FR-015, CR-005]
- [ ] T062 [P] [US4] Escrever pgTAP de finalização/idempotência em `supabase/tests/database/photo_finalize.test.sql`: job validated do ator, lock de animal, troca atômica, associação única e não reativação de job substituído por replay; nenhum cliente pode escrever job ou primary_photo_id diretamente. [FR-014, FR-015, FR-016, CR-005]
- [ ] T063 [P] [US4] Escrever testes de limpeza e concorrência em `supabase/functions/tests/photo_cleanup_test.ts`: job pending antigo, Storage remove falha/retry, dois workers e dois uploads; foto atual nunca é apagada e órfãos permanecem rastreáveis. [FR-014, CR-005]
- [ ] T064 [US4] Ampliar o Widget Test em `test/features/animals/ui/animal_editor_screen_test.dart` para selecionar foto, confirmar envio, ver a nova imagem e retornar a anterior em falha, usando PhotoUploadViewModel real e fake de PhotoRepository; simular também permissão de galeria negada e verificar mensagem portuguesa, loading encerrado, foto e formulário preservados e zero chamadas de upload. [FR-013, FR-014, CR-004]
### Implementation and Validation

- [ ] T065 [US4] Criar finalização privilegiada e fila em `supabase/migrations/202610310005_photo_finalize.sql`: validar ator/sessão/membership de novo, lock em animal, FK de foto atual para job associado, enfileirar previous_photo_id somente após nova associação e negar execução de finalize ao cliente. Job substituído torna-se cleanup_needed com motivo superseded, sem criar enum incompatível. [FR-005, FR-014, FR-015]
- [ ] T066 [US4] Implementar upload e GET de reconciliação em `supabase/functions/animal-photo-upload/index.ts`: autenticar antes do corpo, contar bytes do arquivo (máximo 5.242.880) separadamente do multipart (máximo 5.308.416, até 65.536 de overhead e apenas campos previstos), verificar animal/ator, criar job antes do objeto, object_path único do servidor, mesma chave com mesmos bytes reconcilia e payload divergente conflita. [FR-013, FR-014, FR-016]
- [ ] T067 [US4] Implementar decodificação/normalização em `supabase/functions/_shared/image_validation.ts`: detectar assinatura/MIME JPEG/PNG, rejeitar conteúdo não decodificável, remover metadados com magick-wasm; aceitar origem válida até '5.242.880 bytes' sem contar overhead multipart e, se a primeira saída exceder esse tamanho, ajustar compressão e reduzir resolução apenas se necessário, preservando proporção/transparência e sem ampliar, até caber no bucket; não rejeitar pela expansão inicial; testar CPU/memória no runtime sem inventar restrição de dimensões não prevista. [FR-013, CR-005]
- [ ] T068 [US4] Implementar limpeza em `supabase/functions/animal-photo-cleanup/index.ts` e helpers `supabase/functions/_shared/photo_cleanup.ts`: invocação interna autenticada a cada 15 minutos, pending com mais de 15 minutos, fila/backoff e Storage API, sem SQL direto em storage.objects; excluir só após bloqueio contra futura reassociação e confirmação de não referência atual. [FR-014, FR-015]
- [ ] T069 [US4] Completar pickFromGallery/recoverLostSelection/uploadPrimary/getUpload em `lib/features/photos/data/supabase_photo_repository.dart`, com callbacks SDK/plugin no próprio arquivo, galeria requestFullMetadata:false, conteúdo validado preliminar e Result tipado, capturando falha de permissão do plugin como permissionDenied sem exceção bruta; reusar readPrimary sem duplicar fonte de verdade. [FR-013, FR-014, FR-017, CR-001]
- [ ] T070 [US4] Implementar `lib/features/photos/ui/photo_upload_view_model.dart` e `photo_recovery_view_model.dart`, com submitting/reconciling/success/failure, confirmação explícita do candidato recuperado, permissionDenied com mensagem portuguesa/loading encerrado/rascunho e foto preservados/zero upload, correlação segura e descarte por sessão/dispose; não oferecer cancelamento que finja reverter upload já aceito. [FR-005, FR-006, FR-013, FR-014, FR-016]
- [ ] T071 [US4] Integrar painel de foto em `lib/features/photos/ui/photo_upload_panel.dart`, editor em `lib/features/animals/ui/animal_editor_screen.dart` e recuperação no `lib/app/bootstrap.dart`; Views recebem VMs e bytes, sem galeria/Supabase/queries em build. [FR-013, FR-019, CR-001]
- [ ] T072 [US4] Configurar galeria/plataformas em `ios/Runner/Info.plist`, `ios/Runner.xcodeproj/project.pbxproj` e `android/app/build.gradle.kts`: NSPhotoLibraryUsageDescription em português, iOS 13+ e Android API 24+, sem permissões de câmera/microfone fora do escopo. [FR-013, FR-019]
- [ ] T073 [US4] Executar prova HTTP real de foto privada/pública, URL direta/listagem/createSignedUrl negadas, dois uploads e resposta perdida; registrar em `specs/001-align-app-constitution/validation.md` os testes de recuperação Android, recursos WASM e preservação da imagem anterior. [SC-004, FR-014, FR-015, CR-005, CR-007]

**Checkpoint**: não avançar apresentando esta fase como concluída sem os testes e evidências acima.

---

## Phase 7: User Story 5 — Acompanhar manejo e publicação (P2)

**Goal**: Organizar por situação, publicar com segurança e apresentar totais reais.

**Independent Test / Checkpoint**: Kanban/lista e contadores refletem dados globais; publicar/ocultar/adotar muda leitura pública após atualização e falha não confirma estado fictício.

### Tests — obrigatórios, antes da implementação

- [ ] T074 [P] [US5] Escrever pgTAP em `supabase/tests/database/animal_management.test.sql` para set_animal_status/set_animal_publication/get_animal_status_counts, locks/idempotência, ausência de staff, is_published=false no cadastro novo e negação de publicação de adopted. [FR-005, FR-010, FR-011, FR-012, CR-005]
- [ ] T075 [P] [US5] Escrever testes da implementação real em `test/features/animals/data/supabase_animals_management_repository_test.dart`, cobrindo totais globais, paginação por coluna, falhas e confirmação dos estados retornados. [FR-010, FR-011, FR-012, FR-017, CR-003]
- [ ] T076 [P] [US5] Escrever testes de DashboardViewModel em `test/features/animals/ui/dashboard_view_model_test.dart`: Kanban/lista, capacidades, status/publicação, empty/loading/failure, 401/403 e total de mais de 50 animais, sem contagem baseada só na página carregada. [FR-005, FR-010, FR-011, FR-012, FR-016, CR-003]
- [ ] T077 [P] [US5] Escrever Widget Test em `test/features/animals/ui/dashboard_screen_test.dart`: alternar Kanban/lista, menu de situação sem arraste obrigatório, publicar e confirmar contadores após sucesso. [FR-010, FR-011, FR-012, CR-004]
### Implementation and Validation

- [ ] T078 [US5] Criar `supabase/migrations/202610310006_animal_management.sql` com RPCs estreitas e contadores; estados 'available, treatment, quarantine ou adopted', publicação independente de status, negar nova publicação de adopted e reautorizar cada ação sem grants de DML direto. [FR-005, FR-010, FR-011]
- [ ] T079 [US5] Completar setStatus/setPublication/getStatusCounts e paginação privada em `lib/features/animals/data/supabase_animals_repository.dart`, usando operationKey, Result e estado confirmado sem sobrescrever foto ou notas por mudança de status. [FR-010, FR-011, FR-012, FR-016]
- [ ] T080 [US5] Implementar `lib/features/animals/ui/dashboard_view_model.dart` com colunas/lista, contadores globais, comandos confirmados, autorização pronta e revalidação/descartar estado privado em 401/403; nenhuma regra correspondente em build. [FR-005, FR-006, FR-010, FR-011, FR-012]
- [ ] T081 [US5] Construir `lib/features/animals/ui/dashboard_screen.dart`, conectar edição/publicação/status no editor e `lib/app/app_router.dart`, preservando Kanban e alternativa por menu; aplicar somente estados/capacidades fornecidos pelos VMs. [FR-010, FR-011, FR-012, FR-019, CR-001]
- [ ] T082 [US5] Validar duas sessões, catálogo após publicação/adoção/ocultação e negação de novo pedido de foto/detalhes; registrar totais e resultados negativos em `specs/001-align-app-constitution/validation.md`. [SC-006, FR-002, FR-015, CR-005, CR-007]

**Checkpoint**: não avançar apresentando esta fase como concluída sem os testes e evidências acima.

---

## Phase 8: User Story 6 — Recuperação e ausência de regressões (P2)

**Goal**: Comprovar falhas recuperáveis e retirar definitivamente a arquitetura da demonstração.

**Independent Test / Checkpoint**: Cada falha prevista encerra loading, mostra português e mantém apenas dados autorizados; oito telas e todas as regras possuem evidência.

### Tests — obrigatórios, antes da implementação

- [ ] T083 [P] [US6] Acrescentar matriz parametrizada de rede/timeout/configuração/notFound e respostas tardias aos testes em `test/features/animals/ui/catalog_view_model_test.dart` e `animal_editor_view_model_test.dart`, incluindo rascunho protegido, dispose e consultas de reconciliação limitadas. [FR-016, FR-017, FR-021, CR-003]
- [ ] T084 [P] [US6] Acrescentar regressão de logout/revogação durante upload/login em `test/features/photos/ui/photo_upload_view_model_test.dart` e `test/features/auth/ui/session_view_model_test.dart`, provando descarte de bytes privados e nenhuma confirmação após perda de acesso; diferenciar expiração com editor montado/oculto e restauração somente para o mesmo usuário autorizado de logout/revogação/outro usuário/fechamento/cancelamento com descarte de rascunho. [FR-005, FR-006, FR-014, FR-016, CR-003]
- [ ] T085 [P] [US6] Criar teste de atualização da demonstração em `test/app/legacy_upgrade_test.dart` para ignorar demo_animals_v1, manter somente IDs favoritos válidos/indisponíveis, não criar registros remotos nem liberar rota de demonstração. [FR-020, FR-021, CR-003]
- [ ] T086 [P] [US6] Criar jornada real em `integration_test/authorized_animal_flow_test.dart`: visitante, login autorizado, cadastro privado, edição, foto, publicação, atualização em segunda sessão e logout, com fixture/configuração exclusiva de teste e nenhum segredo na build distribuída. [SC-001, SC-002, SC-003, SC-004, SC-006, CR-005]
### Implementation and Validation

- [ ] T087 [US6] Completar tratamento de falhas/estados vazios e mensagens portuguesas nos VMs em `lib/features/auth/ui/session_view_model.dart`, `lib/features/animals/ui/catalog_view_model.dart`, `animal_detail_view_model.dart`, `animal_editor_view_model.dart` e `lib/features/photos/ui/photo_upload_view_model.dart`; timeout dados/Auth 20 s, upload 60 s, reconciliação 1/2/4 s, sem promessa de rollback remoto por timeout. [FR-016, FR-017, FR-021]
- [ ] T088 [US6] Remover implementação antiga de `lib/data/animal_store.dart`, `lib/models/animal.dart`, `lib/screens/home.dart`, `catalog.dart`, `detail.dart`, `dashboard.dart`, `editor.dart`, `lib/theme.dart` e `lib/widgets/animal_tile.dart` somente após verificar todos os imports migrados; atualizar `test/widget_test.dart` para smoke do novo app, sem duas fontes de verdade. [FR-020, CR-001]
- [ ] T089 [US6] Retirar dependência direta shared_preferences_platform_interface de `pubspec.yaml`, atualizar `pubspec.lock` e consolidar VMs/Repositories no `lib/app/bootstrap.dart`; preferências exclusivamente em FavoritesRepository, dados clínicos somente na nuvem, nenhum mock de produção quando falta configuração. [FR-020, FR-021, CR-006]
- [ ] T090 [US6] Reexecutar oito Widget Tests e todas as suítes de VMs/Repositories, arquitetura e backend; registrar matriz de regra→teste e tela→teste em `specs/001-align-app-constitution/validation.md`, sem substituir unitários por Widget ou mock por prova de RLS. [SC-005, SC-007, SC-008, CR-003, CR-004, CR-005]

**Checkpoint**: não avançar apresentando esta fase como concluída sem os testes e evidências acima.

---

## Phase 9: Polish & Cross-Cutting Concerns — gates e entrega

**Goal**: Concluir CI, evidências e validação de plataforma sem exceções à constituição.

**Independent Test / Checkpoint**: Gates automatizados e backend comprovados; limitações de plataforma e ambiente reportadas; código publicável sem demo administrativa.

- [ ] T091 Ampliar `.github/workflows/flutter.yml` com jobs reproduzíveis Flutter, Supabase local/pgTAP e Deno/HTTP, integração em Android quando disponível, versões fixas e APK debug; zero segredo de produção, jobs falhos não podem ser omitidos como sucesso. [CR-005, CR-007]
- [ ] T092 Executar `dart format --output=none --set-exit-if-changed lib test`, `flutter analyze`, `flutter test --coverage`, `supabase test db` e tarefas Deno; registrar comando/ambiente/commit/resultado por gate em `specs/001-align-app-constitution/validation.md`, incluindo novas migrations/funções não validadas como pendência. [CR-003, CR-005, CR-007]
- [ ] T093 Gerar/testar APK debug com configuração pública em Android real/emulador, incluindo retorno da galeria e navegação; registrar evidência em `specs/001-align-app-constitution/validation.md` e artefato no workflow `.github/workflows/flutter.yml`. Não distribuir chaves privilegiadas ou contas de teste na build. [FR-013, FR-019, CR-007]
- [ ] T094 Validar build/galeria iOS em Mac com Xcode e dispositivo, verificando `ios/Runner/Info.plist` e registrando resultado ou dependência externa em `specs/001-align-app-constitution/validation.md`; nunca declarar iOS validado por testes Windows. [FR-019, CR-007]
- [ ] T095 Executar revisão manual de dependências/imports/regras em build/segredos/mensagens e dos dez princípios em `specs/001-align-app-constitution/validation.md`; revisar novos commits no padrão permitido e IDs FR/CR reais; qualquer conflito exige corrigir plano/tarefa antes de avançar. [CR-001, CR-002, CR-006, CR-007]
- [ ] T096 Atualizar `README.md` e `specs/001-align-app-constitution/quickstart.md` para o app adequado, provisionamento fora do cliente, configuração pública, limpeza agendada, escopo e instruções de validação; relatar limitações reais e vincular SC-001 a SC-008 às evidências em `validation.md`. [FR-004, FR-019, FR-021, CR-007]

**Checkpoint**: não avançar apresentando esta fase como concluída sem os testes e evidências acima.

---

## Dependencies & Execution Order

### Phase Dependencies

| Etapa | Tarefas | Pré-requisito | Saída verificável |
|---|---|---|---|
| Setup | T001–T006 | Nenhum | Gate da fase aprovado |
| Foundation | T007–T021 | Setup | Gate da fase aprovado |
| US1 | T022–T039 | Foundation | US1 testada e documentada |
| US2 | T040–T048 | Foundation; US1 somente para integrar rotas públicas | US2 testada e documentada |
| US3 | T049–T058 | US2; contratos e fundação | US3 testada e documentada |
| US4 | T059–T073 | US2 + US3; leitura de foto da US1 | US4 testada e documentada |
| US5 | T074–T082 | US2 + US3; US4 para validar revogação de foto | US5 testada e documentada |
| US6 | T083–T090 | US1 a US5 | US6 testada e documentada |
| Polish | T091–T096 | Todas as histórias | Gates e evidências finais |

### Dependency Graph

```text
Setup → Foundation ─→ US1 (catálogo + favoritos + leitura de foto)
                  └→ US2 (autenticação) → US3 (cadastro)
                                         ├→ US4 (upload)
                                         └→ US5 (manejo)
US4 → validação de revogação de fotos da US5
US1 + US2 + US3 + US4 + US5 → US6 → Polish / gates de entrega
```

A ordem numérica é a execução padrão e evita conflitos em bootstrap, router e
SupabaseAnimalsRepository. US2 pode ser desenvolvida como componente após a
fundação, mas suas mudanças de rotas são serializadas após US1. US5 depende de
US4 apenas na verificação ponta a ponta de revogação de fotos; suas regras de manejo
podem ser testadas com fakes depois da US3. Não há dependência circular.

### Fixture Execution Dependency

T006 prepara somente os arquivos. A execução é T016 → T017 → T019 → fixtures de
T006 executadas em T021 → testes/gate de T021. T018 trata bootstrap, sem dependência
para popular o banco. Não inserir fixtures antes de existir schema nem exigir
save_animal/finalize/set_status das fases seguintes para preparar os dados de teste.

### Within Each User Story

1. Contratos/fakes e segurança compartilhada da fundação já disponíveis.
2. Escrever testes unitários, Widget e backend do lote; demonstrar falha esperada.
3. Implementar operações/modelos/RPCs e Repositories antes de conectar VMs/Views.
4. Implementar VMs com regras/validações/capacidades e depois Views sem regras de negócio.
5. Executar validação independente da história e registrar evidências; simulação de
   serviço não comprova a segurança real do backend.
6. Nas histórias privadas, cenários unitários/Widget usam conta/Repository fake;
   o happy path do login pode usar destino protegido injetado no teste. O fluxo
   completo login → painel real é validado ao integrar US5, sem criar bypass produtivo.

## Parallel Opportunities and Examples

Todos os exemplos abaixo pressupõem a fundação pronta e pertencem ao lote de
**escrita de testes**, não autorizam iniciar implementação dependente em paralelo.

| História | Exemplo de tarefas paralelas | Por que não conflitam |
|---|---|---|
| US1 | T022, T023, T024 | Arquivos de teste distintos; contratos/fakes previamente fixados |
| US2 | T040, T041, T042 | Arquivos de teste distintos; contratos/fakes previamente fixados |
| US3 | T049, T050, T051 | Arquivos de teste distintos; contratos/fakes previamente fixados |
| US4 | T059, T060, T061 | Arquivos de teste distintos; contratos/fakes previamente fixados |
| US5 | T074, T075, T076 | Arquivos de teste distintos; contratos/fakes previamente fixados |
| US6 | T083, T084, T085 | Arquivos de teste distintos; contratos/fakes previamente fixados |

As implementações de animals/auth/photos e a composição compartilham arquivos:
serializar essas tarefas. Também serializar migrations conforme seus prefixos e
execuções que usam o mesmo banco de teste; fixtures não podem ser alteradas por
testes paralelos não isolados. `[P]` é uma oportunidade técnica, não solicitação
para criar subagentes automaticamente.

## Independent Acceptance by Story

| História | Critério de aceitação independente | Escopo |
|---|---|---|
| US1 | Visitante filtra/busca em mais de uma página, abre somente detalhe público, vê foto autorizada e mantém favorito após reinício | Sem conta; backend com fixtures públicas isoladas |
| US2 | Credenciais válidas concedem somente o acesso autorizado; restore, revogação, não staff e logout se comportam corretamente | Auth e navegação verificadas; sem exigir cadastro público |
| US3 | Um cadastro/edição atômico sobrevive a reinício e aparece na segunda sessão; timeout/repetição não duplica | Conta staff provisionada como fixture; nenhuma nota em leitura anônima |
| US4 | Foto válida é confirmada; cancelamento/erro preserva anterior; retry e concorrência não apagam foto atual | Animal e sessão válidos, proxy e bucket privado |
| US5 | Kanban/lista, contadores globais e publicação/status ficam consistentes; ocultar/adotar remove acesso público após refresh | Fixtures privadas/públicas; sem depender apenas do que a UI esconde |
| US6 | Falhas previstas terminam loading, mensagem é portuguesa, dados privados são limpos e oito telas mantêm jornadas | Todas as histórias e testes reais de backend |

## Implementation Strategy

### MVP First

O primeiro incremento demonstrável é **Setup + Foundation + US1**: catálogo público
real, favoritos e leitura de foto de fixture pelo proxy, sem manejo administrativo
de demonstração. Não inclui upload ou cadastro real pelo usuário e **não equivale
à adequação completa**. Completar US2/US3 entrega o núcleo autenticado P1; US4/US5/US6
e gates finais continuam obrigatórios para concluir esta feature.

### Incremental Delivery

Manter cada incremento testável e protegido. Acrescentar autenticação, cadastro,
fotos e manejo conforme o grafo. Um stub de método futuro deve retornar falha
explícita de indisponibilidade, nunca gravar demo como se fosse serviço real.
Retirar stubs/legado antes da entrega final. Nenhum incremento com políticas
incompletas deve ser distribuído como versão pronta para dados reais.

### Evidence and External Dependencies

Criar `validation.md` somente durante a implementação para registrar resultados.
Distinguir teste planejado de teste executado. Falta de projeto Supabase,
contas autorizadas, Docker, SDK/dispositivo Android ou Mac para iOS deve constar
como dependência operacional; concluir trabalho independente sem inventar aprovação.
Nunca marcar tarefa de execução concluída somente por escrever o comando.

## Traceability and Completion Gates

- FR-001 a FR-021, CR-001 a CR-007 e SC-001 a SC-008 estão associados a tarefas;
  os dez princípios permanecem obrigatórios para todas as fases.
- CONST-001/002/003/004: fundação, contratos, VMs e revisão de fronteiras.
- CONST-005/006: unitários por regra/Repository e oito Widget Tests felizes;
  upload incluído no editor.
- CONST-007: Result, captura de PostgrestException/AuthException/StorageException/
  FunctionException, falhas de rede e mensagens portuguesas.
- CONST-008/009/010: dependências previamente justificadas, nomes em inglês,
  apresentação portuguesa e commits rastreáveis no padrão estrito.
- Critério final: formatação, análise, Flutter unitário/Widget, backend SQL/HTTP/
  funções e plataforma registrados separadamente. Nenhum gate é substituído por outro.
- Próximo comando recomendado: `/speckit-analyze`; corrigir inconsistências antes
  de `/speckit-implement`. Esta lista não inicia a implementação.
