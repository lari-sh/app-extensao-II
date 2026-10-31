# Implementation Plan: Adequação do Abrigo dos Anjos

**Branch**: `main` (branch Git real) | **Date**: 2026-10-31 | **Spec**: [spec.md](spec.md)
**Feature ID**: `001-align-app-constitution`
**Input**: `specs/001-align-app-constitution/spec.md`
**Constitution**: versão 1.0.0, ratificada em 2026-10-31.
**Status**: desenho técnico concluído; implementação e validação ainda não executadas.

## Summary

Migrar a demonstração para uma aplicação com catálogo público, manejo autenticado,
fotos reais e persistência compartilhada. Preservar a experiência vermelha/marrom
sem carregar o canvas do protótipo. Usar módulos feature-first, ViewModels com
ChangeNotifier, interfaces de Repository e Result tipado. Isolar Supabase nas
implementações de Repository e na composição inicial; não criar uma camada de
serviços Dart que espalhe queries fora desses Repositories.

Separar fisicamente dados públicos e clínicos. Aplicar autorização de voluntário
ativo no banco e no backend de fotos; sessão autenticada sozinha não basta.
Fotos ficam em bucket privado e são entregues por função que valida cada pedido,
sem URLs diretas nem cache. Tratar gravação como transação e foto como operação
compensável rastreada, sem perder a imagem anterior em falhas.

## Technical Context

**Language/Version**: Dart 3.11 / Flutter 3.41.1, existentes; SQL PostgreSQL e
TypeScript no runtime Deno das Edge Functions, somente no backend.
**Primary Dependencies**: supabase_flutter 2.18.3 como versão candidata estável;
image_picker 1.2.4; shared_preferences 2.5.6 já resolvido; Flutter SDK e
flutter_localizations. Resolver e travar versões compatíveis na implementação,
sem alegar que o novo conjunto já passou por pub get.
**Storage**: Supabase PostgreSQL para animais, autorização e cuidados; Storage
privado para imagens; preferências locais apenas para IDs de favoritos.
**Testing**: flutter_test para regras e Widgets; fakes manuais; pgTAP para banco/RLS;
Deno.test para funções; integration_test do SDK para jornada em dispositivo;
validação real de REST/Storage com anon, conta sem autorização e voluntário ativo.
**Target Platform**: Android API 24+ prioritário; iOS 13+ preparado e validado no Mac.
**Project Type**: aplicativo mobile para um abrigo, backend gerenciado.
**Performance Goals**: atender SC-001 a SC-008 sem sucesso falso ou loading infinito;
leituras com paginação de 50 itens e carregamento incremental; imagens sob demanda
com limite de quatro pedidos simultâneos. Timeout de 20 s para dados/Auth e 60 s
para upload; timeout não prova que uma escrita foi revertida, exigindo reconciliação.
Esses limites são decisões técnicas, não novas promessas de latência de negócio.
**Constraints**: sem escrita offline, sem cadastro público de voluntários, sem
importar dados fictícios; nenhuma chave privilegiada no cliente; publicação privada
por padrão; JPEG/PNG até 5.242.880 bytes; leitura de fotos reautorizada em cada pedido.
**Scale/Scope**: oito telas principais, um abrigo, dois contextos de UI; autorização
administrada fora do app. Conjunto de validação inclui mais de uma página de animais
para comprovar filtros, totais e paginação sem pressupor tamanho máximo do abrigo.

### Dependências e justificativas prévias (CONST-008)

| Dependência | Decisão e finalidade | Alternativa avaliada e motivo |
|---|---|---|
| supabase_flutter 2.18.3 candidata | Adicionar para Auth, PostgreSQL, funções e Storage através dos Repositories. Exceção constitucional explícita. | SDK Flutter não fornece cliente Supabase; implementar protocolo próprio duplica autenticação e contratos. |
| image_picker 1.2.4 | Adicionar somente para galeria (FR-013), encapsulado em PhotoRepository. | Flutter SDK não possui seletor multiplataforma de galeria. MethodChannels próprios ampliariam código nativo e testes Android/iOS. |
| shared_preferences 2.5.6 | Manter para IDs locais de favoritos; somente FavoritesRepository importa o pacote. | dart:io exige tratamento separado de diretórios/plataformas; plugin existente atende o dado não crítico. Não armazenar prontuários, fotos ou rascunhos clínicos. |
| flutter_lints 6.0.0 | Manter dependência de desenvolvimento e regras existentes. | Recriar regras manualmente não melhora o escopo; análise é um gate constitucional. |
| shared_preferences_platform_interface | Remover dependência direta de teste após migrar testes para contratos/fakes. | Os novos testes não precisam testar a plataforma por dentro; o plugin pode continuar como dependência transitiva. |
| flutter, flutter_localizations, flutter_test, integration_test | SDK; manter os existentes e adicionar integration_test apenas para execução em dispositivo. | Dependências nativas dispensadas de justificativa, responsabilidades registradas. |

Não adicionar provider, riverpod, get_it, go_router, mockito, mocktail, uuid, image,
http direto ou dotenv. Injeção por construtor, ListenableBuilder e Navigator do SDK
são suficientes. IDs de operações vêm de Random.secure + base64url de dart:math/
dart:convert; UUIDs persistidos são gerados no banco. Clipboard fica atrás de um
contrato local, chamado pelo ViewModel, usando Flutter Services na implementação.

No backend, usar @supabase/supabase-js v2 e @imagemagick/magick-wasm v0, com versões
exatas e deno.lock fixados na implementação. O primeiro é necessário ao acesso
servidor Auth/Storage; o segundo decodifica e normaliza JPEG/PNG em WASM. Conferir
assinatura/MIME sem decodificação não rejeita imagem corrompida nem remove metadados.
Não usar Sharp: depende de bibliotecas nativas não suportadas nesse ambiente.
Não são dependências pubspec e nunca são chamadas por Widgets.

## Constitution Check

*GATE antes da pesquisa e repetido após o desenho. PASS-DESIGN significa que o
plano satisfaz a regra; NÃO significa que o aplicativo atual já está conforme.*

| Princípio | Antes da pesquisa | Após o desenho e evidência planejada |
|---|---|---|
| CONST-001 Feature-first MVVM | PASS-DESIGN: substituir estrutura horizontal | PASS-DESIGN: árvore abaixo; ui/domain/data em cada módulo; ChangeNotifier |
| CONST-002 Views isoladas | PASS-DESIGN: Views consomem apenas VM | PASS-DESIGN: contratos e testes de importação; composição em app/bootstrap.dart |
| CONST-003 Regras nos VMs | PASS-DESIGN: mover filtros, validação e capacidades | PASS-DESIGN: matriz de responsabilidades e testes de canEdit/canAdopt/estados |
| CONST-004 Repositories/Supabase | PASS-DESIGN: interfaces sem SDK | PASS-DESIGN: contratos; SDK só em data/*_repository.dart e bootstrap sem queries |
| CONST-005 Testes unitários | PASS-DESIGN: obrigatórios | PASS-DESIGN: cada VM/Repository com sucesso, falha, validação e autorização aplicáveis |
| CONST-006 Widget Tests | PASS-DESIGN: oito telas | PASS-DESIGN: oito arquivos vinculados às telas; upload no editor |
| CONST-007 Result | PASS-DESIGN: contrato único | PASS-DESIGN: failures tipadas; nenhuma exceção de SDK na UI; stream de sessão protegido |
| CONST-008 Dependências | PASS-DESIGN: nenhum pacote adicionado agora | PASS-DESIGN: tabela acima e pesquisa; remoção de dependência direta obsoleta |
| CONST-009 Inglês/português | PASS-DESIGN: padrão obrigatório | PASS-DESIGN: arquivos/classes ingleses; mensagens e validações portuguesas nos VMs |
| CONST-010 Commits | PASS-DESIGN: rastrear por requisito | PASS-DESIGN: exemplo feat(auth): implemente login autorizado [001-FR-004]; revisão do histórico novo |

Não há dispensas. Se uma tarefa ou uma limitação posterior violar um gate, corrigir
este plano antes de avançar; não enfraquecer a constituição. O relatório transitório
de sincronização da constituição permanece para revisão e deve ser retirado antes
de um commit dela, sem alterar seu conteúdo normativo neste comando.

## Project Structure

### Documentation (this feature)

```text
specs/001-align-app-constitution/
  spec.md
  plan.md
  research.md
  data-model.md
  quickstart.md
  checklists/requirements.md
  contracts/repositories.md
  contracts/backend.md
```

`tasks.md` será produzido somente pelo próximo comando speckit-tasks.

### Source Code (repository root)

```text
lib/
  main.dart
  app/
    bootstrap.dart
    app_dependencies.dart
    abrigo_app.dart
    app_router.dart
  core/
    result.dart
    app_failure.dart
    operation_id.dart
    config/app_config.dart
    theme/app_theme.dart
    widgets/animal_portrait.dart
    widgets/status_badge.dart
  features/
    home/
      ui/home_screen.dart
      ui/home_view_model.dart
      ui/about_screen.dart
      ui/about_view_model.dart
      domain/adoption_message_repository.dart
      data/clipboard_adoption_message_repository.dart
    auth/
      ui/login_screen.dart
      ui/login_view_model.dart
      ui/session_view_model.dart
      domain/auth_repository.dart
      domain/session_access.dart
      data/supabase_auth_repository.dart
    animals/
      ui/catalog_screen.dart
      ui/catalog_view_model.dart
      ui/animal_detail_screen.dart
      ui/animal_detail_view_model.dart
      ui/dashboard_screen.dart
      ui/dashboard_view_model.dart
      ui/animal_editor_screen.dart
      ui/animal_editor_view_model.dart
      domain/animal.dart
      domain/clinical_record.dart
      domain/animal_draft.dart
      domain/animal_query.dart
      domain/animals_repository.dart
      data/supabase_animals_repository.dart
    favorites/
      ui/favorites_screen.dart
      ui/favorites_view_model.dart
      domain/favorites_repository.dart
      data/local_favorites_repository.dart
    photos/
      ui/photo_upload_view_model.dart
      domain/photo_repository.dart
      domain/photo_candidate.dart
      domain/photo_content.dart
      data/supabase_photo_repository.dart
      ui/photo_recovery_view_model.dart
      domain/photo_selection_request.dart
      domain/photo_upload_state.dart
      ui/photo_upload_panel.dart
  # domain e data não importam ui; Widgets não recebem Repositories.
test/
  core/
  architecture/layer_boundaries_test.dart
  features/<feature>/ui/<view_model>_test.dart
  features/<feature>/ui/<screen>_test.dart
  features/<feature>/data/<repository>_test.dart
  support/fakes/
integration_test/authorized_animal_flow_test.dart
supabase/
  config.toml
  migrations/
  tests/database/authorization.test.sql
  tests/database/animal_save.test.sql
  functions/_shared/
  functions/animal-photo-read/index.ts
  functions/animal-photo-upload/index.ts
  functions/animal-photo-cleanup/index.ts
  functions/tests/
  functions/deno.json
  functions/deno.lock
```

**Structure Decision**: VMs pertencem a ui, entidades/contratos a domain e acessos
externos a data. PhotoUploadViewModel compõe o editor e PhotoRecoveryViewModel trata
retorno da galeria no startup; ambos usam interfaces, não SDKs. Home/About recebem
VMs mesmo quando apenas exibem conteúdo estático e eventos. AppRouter observa
SessionViewModel e recebe eventos/capacidades prontos do VM: na expiração
recuperável mantém o editor montado, oculto inclusive da acessibilidade, atrás da
reautenticação; na perda definitiva descarta o rascunho e troca a pilha privada por
pública. O Router não contém regra de autorização. Nenhum widget de app/
recebe SupabaseClient; somente o bootstrap faz composição.

### Responsabilidades e estados

- SessionViewModel: checking, visitor, authenticatedWithoutStaff, authorized,
  unavailable; libera conteúdo privado somente após validação remota. LoginViewModel
  valida credenciais; AuthRepository verifica usuário, sessão e membership atual.
- Catalog/FavoritesViewModel: query combinada, paginação, IDs de favoritos e
  interseção com animais visíveis; filtros em consultas do Repository, decisões no VM.
  Não filtrar apenas a página atual nem calcular totais globais por cartões carregados.
- DetailViewModel: dados públicos e foto em bytes; canAdopt já calculado. Clipboard
  passa por AdoptionMessageRepository, sem efeitos em build.
- DashboardViewModel: contadores do servidor, colunas/lista, comandos de mudança;
  atualizar estado confirmado somente após Result.success. Paginar cada coluna.
- EditorViewModel: validações de FR-007, FR-008, mudanças, trava de submissão e token
  idempotente estável por ação. PhotoUploadViewModel: escolha, limites, envio,
  cancelamento e reconciliação; nenhuma regra dentro do formulário Widget.
- Repositories: fonte de verdade, transações, mapeamentos, falhas; callbacks de
  operações injetáveis definidos no próprio arquivo data para teste. Fábrica de
  produção mantém todas as chamadas Supabase dentro da implementação Repository.
  Não mover queries para adapters/services apenas para facilitar mocking.
- Result sealed Success<T>/Failure<T>, AppFailure(code, fieldErrors, retryable,
  correlationId opcional sem segredo), com códigos validation, unauthenticated,
  forbidden, notFound, network, timeout, conflict, cancelled, permissionDenied,
  configuration, unknown.
  VM mapeia para português. Cancelamento do picker é Success(null), não erro;
  permissão de galeria negada é Failure(permissionDenied), sem upload ou perda do formulário.
  Todo comando encerra busy em finally e ignora resposta tardia após dispose/logout.
- Distinguir expiração recuperável de perda definitiva de acesso. Na expiração
  identificada durante edição, manter a tela/EditorViewModel montados, com o rascunho
  apenas em memória; ocultar integralmente conteúdo privado, bloquear ações/Voltar
  para o formulário e pedir login em uma camada de reautenticação. Invalidar a
  geração de operações em voo e não aceitar respostas privadas antigas.
- Só restaurar a edição após validar remotamente o mesmo userId e sua autorização
  atual de staff. Novo usuário, logout explícito, sessão explicitamente revogada,
  autorização revogada, fechamento da tela ou cancelamento da reautenticação
  descartam o rascunho, dados/fotos/listeners privados e a pilha privada. Na causa
  desconhecida, tratar como perda definitiva. Nunca persistir rascunho em preferências.
  A máscara e os eventos de navegação são estados do VM, não decisões de autorização
  no Widget ou no Router.

### Backend, segurança e consistência

- Modelo e permissões em [data-model.md](data-model.md) e [contracts/backend.md](contracts/backend.md).
- RLS para dados públicos/internos; autorização baseada em membership ativa e
  sessão atual no banco, sem confiar em user_metadata ou role em cache.
- RPC save_animal grava identificação, notas e cuidados em uma transação com
  idempotencyKey. Mesma operação repetida retorna o mesmo resultado, não duplica.
- Publicação não representa status clínico; novos cadastros começam privados.
- Bucket privado sem leitura/escrita direta para anon/authenticated. Funções de
  foto verificam identidade e associação; acesso privilegiado só no servidor.
- Download em bytes, sem redirect, Cache-Control: no-store, private e sem CDN de
  URL assinada. VM renderiza Image.memory via estado; após refresh revoga/descarta
  foto não autorizada e não reutiliza cópia persistente. Imagens já baixadas por
  terceiros não podem ser revogadas retroativamente.
- Upload cria job rastreado e caminho imutável; servidor valida bytes, decodifica
  JPEG/PNG com WASM e normaliza removendo metadados. O arquivo selecionado tem
  limite de 5.242.880 bytes, distinto do corpo multipart: reservar até 65.536 bytes
  adicionais para delimitadores/campos, com total máximo de 5.308.416 bytes e limite
  próprio dos campos. O parser conta bytes do arquivo e do corpo separadamente.
  A saída deve caber em 5 MB: se a primeira normalização exceder, ajustar compressão
  e, se necessário, reduzir resolução mantendo proporção e transparência quando
  houver, sem ampliar a imagem. Não rejeitar entrada válida só pelo crescimento
  da primeira saída. Associar em transação apenas após novo teste de autorização.
  Validar consumo de memória/CPU com
  imagens até 5 MB e diferentes dimensões no ambiente alvo. Falha de processamento
  preserva a foto anterior e retorna erro recuperável; não acrescentar silenciosamente
  um limite de dimensões que contradiga os formatos/tamanho aceitos em FR-013.
- Falha mantém foto atual; job pending/cleanup_needed não vira imagem atual.
  Cleanup via Storage API; concorrência controlada por lock na linha do animal,
  com teste para não remover foto referenciada. Resultado perdido é reconciliado
  por job/operationId antes de repetir ou excluir qualquer candidato. Fazer no
  máximo três consultas de reconciliação por tentativa (intervalos 1/2/4 s),
  depois encerrar loading e mostrar resultado ainda não confirmado com ação de
  consultar novamente, preservando a chave; nunca transformar pendente em falha
  definitiva nem criar operação nova enquanto a original estiver sem resolução.

### Migração incremental

1. Criar contratos/Result e fakes, esqueleto feature-first e composição; manter
   logo/tema. Caracterizar fluxos atuais antes de remover o store global.
2. Construir banco/políticas e ambiente local isolado, sem importar demo_animals_v1.
   Preparar o script de fixtures no Setup, mas só executá-lo após as migrations
   T016/T017/T019 e antes de T021. Fixtures não podem depender de RPCs futuras;
   criar dados pelo contexto administrativo local controlado, sem alterar policies.
3. Migrar Auth/Session e remover acesso administrativo de demonstração. Ambiente
   não configurado oferece estado explícito, nunca dados fictícios de fallback.
4. Migrar catálogo, favoritos, detalhes e manejo para VMs/Repositories; preservar
   chave favorites_v1, aceitando IDs legados só como favoritos indisponíveis.
5. Integrar galeria/fotos e controles de publicação; finalizar testes negativos.
6. Remover AnimalStore, modelo/telas antigos e dependência direta de interface
   de preferências quando nenhum import permanecer. Não deixar duas fontes de verdade.

Não fazer mudança de formato/estrutura pela metade no branch publicável; um
incremento não conforme não pode ser apresentado como adequação concluída.

### Matriz obrigatória de testes

| Tela principal | Arquivo alvo de Widget Test | Caminho feliz |
|---|---|---|
| Início | test/features/home/ui/home_screen_test.dart | exibe logo e navega ao catálogo por comando do VM |
| Catálogo/busca | test/features/animals/ui/catalog_screen_test.dart | combina filtros, mostra resultado e abre detalhe |
| Favoritos | test/features/favorites/ui/favorites_screen_test.dart | mostra favorito ainda visível e permite remover |
| Detalhes | test/features/animals/ui/animal_detail_screen_test.dart | exibe campos públicos e copia interesse sem envio |
| Sobre | test/features/home/ui/about_screen_test.dart | exibe conteúdo e volta pelo fluxo previsto |
| Login | test/features/auth/ui/login_screen_test.dart | credenciais de teste autorizadas levam ao painel |
| Painel | test/features/animals/ui/dashboard_screen_test.dart | alterna Kanban/lista e confirma alteração de status |
| Cadastro/edição | test/features/animals/ui/animal_editor_screen_test.dart | valida, salva, seleciona e confirma foto por fake |

Cada VM e cada Repository concreto tem suíte própria com flutter_test, sem rede:
validação de fronteira (0/1/80/81 e 3000/3001, cuidados 1000/1001), loading,
sucesso/falha/timeout, sessão e permissões, dispose/resposta tardia, mapeamento,
PostgrestException/AuthException/StorageException/FunctionException,
preferências, cancelamento e foto anterior preservada. Testar orquestração real
do Repository com callbacks falsos, não substituir a classe sob teste por um fake.

Gate de arquitetura varre imports, arquivos e tokens de acesso SDK: proibir pacotes
externos em Widgets; data em ui/VM; consultas em bootstrap; UI/Supabase em domain;
e regras de filtro/permissão/validação em build. Complementar scanner com revisão
manual, pois busca textual não prova ausência de toda lógica de negócio.

Backend: pgTAP prova grants/RLS/atomicidade/idempotência; Deno.test prova funções,
limites, bytes, expiração/revogação, cleanup e concorrência. Teste real REST/Storage
com JWT válido revogado e membership removida; nunca aceitar somente mock como
prova de segurança. Fixtures exclusivas do ambiente local/homologação.

### Rastreabilidade e sequência de entrega

| Requisitos | Artefatos/áreas responsáveis | Evidência prevista |
|---|---|---|
| FR-001, FR-002 | animals/favorites/home e RLS | Widgets + paginação/filtros + leitura anon |
| FR-003 | tabelas privadas e projeção pública | select=* e tentativas de join sem fuga |
| FR-004, FR-005, FR-006 | auth, router, session helper | unitários + JWT não autorizado/revogado + logout |
| FR-007, FR-008, FR-009 | EditorVM, AnimalsRepository, RPC | fronteiras + rollback + segundo dispositivo |
| FR-010, FR-011, FR-012 | DashboardVM, status/publicação | contadores globais + lista/Kanban + restrições |
| FR-013, FR-014, FR-015 | photos, funções, jobs | decodificação + substituição + acesso sem cache |
| FR-016, FR-017 | Result + todos VMs/Repositories | falhas/duplicação/retry/mensagens portuguesas |
| FR-018 | DetailVM, clipboard repository | canAdopt + cópia sem envio |
| FR-019 | tema/widgets/plataformas | oito Widgets + Android + iOS separado |
| FR-020, FR-021 | bootstrap e retirada do store | zero importação demo + configuração vazia/estados vazios |
| CR-001, CR-002 | árvore, contratos, Result | architecture test + revisão de responsabilidades |
| CR-003, CR-004 | matriz de testes | unitários por regra + oito telas |
| CR-005, CR-006, CR-007 | backend, dependências, gates | testes reais de autorização + revisão de plano/commits |

A próxima fase de tasks deve ordenar fundação → segurança/Auth → catálogo/manejo →
fotos → regressão/plataformas e mapear cada tarefa a estes requisitos. Não criar
etapas de implementação dentro deste comando.

## Complexity Tracking

Nenhuma violação constitucional autorizada. Funções de fotos e jobs de compensação
são complexidade necessária para FR-013, FR-014, FR-015, não justificativa para violar
isolamento, testes ou segurança. Não criar exceções por conveniência.

## Validation and Delivery Gates

Executar o roteiro em [quickstart.md](quickstart.md). Distinguir quatro resultados:
formatação/análise, unitários/Widgets, segurança backend e plataforma. Nenhum gate
faltante é compensado pelos demais. A CI atual só executa Flutter; a implementação
DEVE acrescentar jobs SQL/Edge e integração local/homologação antes de declarar
SC-002/004/006 concluídos. Fixar versões de ferramenta/lockfiles na implementação.

Pendências operacionais: disponibilizar projeto Supabase de desenvolvimento,
provisionar contas de teste fora do app e configurar SDK Android/dispositivo.
Windows não valida build iOS. Essas dependências não mudam decisões arquiteturais
e não impedem gerar tasks; impedem declarar integração real ou build aprovados.
