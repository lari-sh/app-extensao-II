# Implementation Plan: Adequação do Abrigo dos Anjos

**Branch**: `developer` (implementação; integração à main por PR) | **Date**: 2026-10-31 | **Spec**: [spec.md](spec.md)
**Feature ID**: `001-align-app-constitution`
**Input**: `specs/001-align-app-constitution/spec.md`
**Constitution**: versão 2.0.0, ratificada em 2026-10-31.
**Status**: fundação e histórias US1–US6 implementadas e validadas localmente; CI e artifact Android aprovados na execução 41259640949; validação iOS depende de Mac/Xcode.

## Summary

Migrar a demonstração para uma aplicação com catálogo público, manejo autenticado,
fotos reais e persistência compartilhada. Preservar a experiência vermelha/marrom
sem carregar o canvas do protótipo. Seguir a skill Flutter instalada e a constituição
2.0.0: UI organizada por feature, data/domain por tipo, ViewModels ChangeNotifier,
interfaces de Repository e Result tipado. Services sem estado de negócio encapsulam
Supabase/plugins; Repositories consomem Services e transformam DTOs em modelos de
domínio. A composição registra as dependências com Provider e injeção por construtor.

Separar fisicamente dados públicos e clínicos. Aplicar autorização de voluntário
ativo no banco e no backend de fotos; sessão autenticada sozinha não basta.
Fotos ficam em bucket privado e são entregues por função que valida cada pedido,
sem URLs diretas nem cache. Tratar gravação como transação e foto como operação
compensável rastreada, sem perder a imagem anterior em falhas.

## Technical Context

**Language/Version**: Dart 3.11 / Flutter 3.41.1, existentes; SQL PostgreSQL e
TypeScript no runtime Deno das Edge Functions, somente no backend.
**Primary Dependencies**: supabase_flutter 2.18.3 como versão candidata estável;
image_picker 1.2.4; shared_preferences 2.5.6 já resolvido; provider 6.1.5+1;
freezed_annotation 3.1.0; freezed 3.2.5 e build_runner 2.10.5 (dev); Flutter SDK e
flutter_localizations. Novas versões são candidatas exatas, não resolução executada. Resolver e travar versões compatíveis na implementação,
sem alegar que o novo conjunto já passou por pub get.
**Storage**: Supabase PostgreSQL para animais, autorização e cuidados; Storage
privado para imagens; preferências locais apenas para IDs de favoritos.
**Testing**: flutter_test para regras de VM/Repository/Service e Widgets; fakes manuais;
Services falsos para Repositories reais; Repositories falsos para VMs reais; pgTAP para banco/RLS;
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
| supabase_flutter 2.18.3 candidata | Adicionar para Auth, PostgreSQL, funções e Storage nos Services, mediados por Repositories. Exceção constitucional explícita. | SDK Flutter não fornece cliente Supabase; implementar protocolo próprio duplica autenticação e contratos. |
| image_picker 1.2.4 | Adicionar somente para galeria (FR-013), encapsulado em GalleryService e mediado por PhotoRepository. | Flutter SDK não possui seletor multiplataforma de galeria. MethodChannels próprios ampliariam código nativo e testes Android/iOS. |
| shared_preferences 2.5.6 | Manter para IDs locais de favoritos; somente FavoritesStorageService importa o pacote; FavoritesRepository o consome. | dart:io exige tratamento separado de diretórios/plataformas; plugin existente atende o dado não crítico. Não armazenar prontuários, fotos ou rascunhos clínicos. |
| flutter_lints 6.0.0 | Manter dependência de desenvolvimento e regras existentes. | Recriar regras manualmente não melhora o escopo; análise é um gate constitucional. |
| shared_preferences_platform_interface | Remover dependência direta de teste após migrar testes para contratos/fakes. | Os novos testes não precisam testar a plataforma por dentro; o plugin pode continuar como dependência transitiva. |
| flutter, flutter_localizations, flutter_test, integration_test | SDK; manter os existentes e adicionar integration_test apenas para execução em dispositivo. | Dependências nativas dispensadas de justificativa, responsabilidades registradas. |
| provider 6.1.5+1 | Adicionar para registrar Services/Repositories/ChangeNotifiers e gerenciar escopo/dispose na composição. | Injeção manual é possível, mas a skill priorizada recomenda container; Provider evita service locator global e mantém construtores testáveis. Não adicionar get_it simultaneamente. |
| freezed_annotation 3.1.0 | Adicionar para declarar modelos de domínio e snapshots imutáveis. | Classes manuais são possíveis, mas a skill priorizada pede freezed ou built_value. Selecionar Freezed para igualdade/copyWith/coleções protegidas. Não adicionar built_value em paralelo. |
| freezed 3.2.5 (dev) | Gerar os modelos anotados, mantendo-os sem tipos do Supabase e sem fromJson. | SDK não gera o contrato Freezed. A versão 4 exige SDK mais novo; usar candidata compatível com Dart 3.11. |
| build_runner 2.10.5 (dev, exata) | Executar a geração Freezed e validar arquivos gerados no CI. | Exigido pelo fluxo de geração escolhido. Versões posteriores podem conflitar em build/analyzer com Freezed 3.2.5; não usar caret até resolver o conjunto. |

Fixar candidatos e lockfile na implementação após pub get. Nenhuma dependência nova
é instalada neste planejamento. Não adicionar riverpod, get_it, built_value,
go_router, mockito, mocktail, uuid, image, http direto, dotenv, json_annotation ou
json_serializable sem nova justificativa. DTOs têm mapeamento manual em data/models,
sem serialização JSON gerada nos modelos de domínio.

Provider só obtém/observa ViewModels nas Views; não permite acesso a Services ou
Repositories pelo Widget. Inicializar operações de VM em bootstrap/fábrica de rota
ou evento de ciclo de vida, nunca como efeito de leitura de Provider em build.
Usar ListenableBuilder e Navigator do SDK. IDs de operações vêm de Random.secure +
base64url; UUIDs persistidos vêm do banco. ClipboardService envolve Flutter Services,
AdoptionMessageRepository o consome e o VM emite o comando.

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
| CONST-001 Flutter híbrido MVVM | PASS-DESIGN: seguir skill priorizada | PASS-DESIGN: UI por feature; data/domain por tipo; ChangeNotifier e Freezed |
| CONST-002 Views isoladas | PASS-DESIGN: Views consomem apenas VM | PASS-DESIGN: contratos e testes de importação; composição em app/bootstrap.dart |
| CONST-003 Regras nos VMs | PASS-DESIGN: mover filtros, validação e capacidades | PASS-DESIGN: matriz de responsabilidades e testes de canEdit/canAdopt/estados |
| CONST-004 Services/Repositories | PASS-DESIGN: contratos sem SDK | PASS-DESIGN: SDK só em data/services e inicialização no bootstrap; Repositories recebem Services |
| CONST-005 Testes unitários | PASS-DESIGN: obrigatórios | PASS-DESIGN: cada VM/Repository e regra de Service com sucesso/falha/validação/autorização aplicáveis |
| CONST-006 Widget Tests | PASS-DESIGN: oito telas | PASS-DESIGN: oito arquivos vinculados às telas; upload no editor |
| CONST-007 Result | PASS-DESIGN: contrato único | PASS-DESIGN: failures tipadas; nenhuma exceção de SDK na UI; stream de sessão protegido |
| CONST-008 Dependências | PASS-DESIGN: nenhum pacote adicionado agora | PASS-DESIGN: Provider/Freezed/build_runner justificados; remoção de dependência direta obsoleta |
| CONST-009 Inglês/português | PASS-DESIGN: padrão obrigatório | PASS-DESIGN: arquivos/classes ingleses; mensagens e validações portuguesas nos VMs |
| CONST-010 Commits | PASS-DESIGN: rastrear por requisito | PASS-DESIGN: exemplo feat(auth): implemente login autorizado [001-FR-004]; revisão do histórico novo |

Não há dispensas. Se uma tarefa ou uma limitação posterior violar um gate, corrigir
este plano antes de avançar; não enfraquecer a constituição. A constituição 2.0.0
foi sincronizada com este desenho; não há relatório transitório pendente.

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

`tasks.md` é regenerado neste realinhamento; tarefas anteriores ainda não foram executadas.

### Source Code (repository root)

```text
lib/
  main.dart
  app/
    bootstrap.dart
    app_dependencies.dart
    public_dependencies.dart
    abrigo_app.dart
    app_router.dart
  config/app_config.dart
  utils/
    result.dart
    app_failure.dart
    operation_id.dart
  data/
    models/
      animal_dto.dart
      clinical_record_dto.dart
      session_dto.dart
      photo_dto.dart
    services/
      auth_service.dart
      supabase_auth_service.dart
      animals_service.dart
      supabase_animals_service.dart
      photo_api_service.dart
      supabase_photo_api_service.dart
      gallery_service.dart
      image_picker_gallery_service.dart
      favorites_storage_service.dart
      shared_preferences_favorites_service.dart
      clipboard_service.dart
      flutter_clipboard_service.dart
    repositories/
      auth_repository_impl.dart
      animals_repository_impl.dart
      photo_repository_impl.dart
      favorites_repository_impl.dart
      adoption_message_repository_impl.dart
  domain/
    models/
      animal.dart
      clinical_record.dart
      animal_draft.dart
      animal_query.dart
      session_access.dart
      photo_candidate.dart
      photo_content.dart
      photo_selection_request.dart
      photo_upload_state.dart
    repositories/
      auth_repository.dart
      animals_repository.dart
      photo_repository.dart
      favorites_repository.dart
      adoption_message_repository.dart
    # use_cases/ somente se complexidade/reuso justificar; sem use case vazio.
  ui/
    core/
      view_models/public_list_view_model.dart
      widgets/public_animal_list.dart
      theme/app_theme.dart
      widgets/animal_portrait.dart
      widgets/status_badge.dart
    features/
      home/
        views/home_screen.dart
        views/about_screen.dart
        view_models/home_view_model.dart
        view_models/about_view_model.dart
      auth/
        views/login_screen.dart
        view_models/login_view_model.dart
        view_models/session_view_model.dart
      animals/
        views/catalog_screen.dart
        views/animal_detail_screen.dart
        views/dashboard_screen.dart
        views/animal_editor_screen.dart
        view_models/catalog_view_model.dart
        view_models/animal_detail_view_model.dart
        view_models/dashboard_view_model.dart
        view_models/animal_editor_view_model.dart
      favorites/
        views/favorites_screen.dart
        view_models/favorites_view_model.dart
      photos/
        views/photo_upload_panel.dart
        view_models/photo_upload_view_model.dart
        view_models/photo_recovery_view_model.dart
test/
  utils/
  app/
  architecture/layer_boundaries_test.dart
  domain/models/
  data/models/
  data/services/
  data/repositories/
  ui/features/<feature>/view_models/
  ui/features/<feature>/views/
  support/fakes/
integration_test/public_catalog_flow_test.dart
integration_test/authorized_animal_flow_test.dart
supabase/
  config.toml
  migrations/
  tests/database/
  functions/_shared/
  functions/animal-photo-read/index.ts
  functions/animal-photo-upload/index.ts
  functions/animal-photo-cleanup/index.ts
  functions/tests/
  functions/deno.json
  functions/deno.lock
```

**Structure Decision**: Services encapsulam SDKs e DTOs; Repositories recebem
interfaces desses Services por construtor e retornam modelos de domínio/Result.
Views observam VMs, não a camada de dados. Freezed para modelos/snapshots imutáveis;
gerar .freezed.dart após cada mudança anotada e antes dos testes de cada incremento;
versionar saídas determinísticas. DTOs manuais ficam em data.
Services não têm estado de negócio ou cache; o cliente SDK injetado pode gerenciar
sua conexão/sessão. Mapeamento puro de dados e exceções nos Services tem teste.
Repositories mantêm a fonte de verdade e a orquestração/reconciliação sem executar
queries. Use Cases só surgem se houver regra complexa ou reuso entre VMs demonstrado;
não criar camada adicional para CRUD simples.

Provider registra Services, contratos de Repository e VMs no escopo apropriado.
ChangeNotifierProvider gerencia dispose; manter injeção por construtor. Não iniciar
I/O em fábricas lazy acionadas por build. AppRouter recebe eventos/capacidades de
SessionViewModel: em expiração recuperável mantém editor montado e oculto inclusive
na acessibilidade; perda definitiva descarta rascunho/pilha. PhotoUploadViewModel
compõe editor e PhotoRecoveryViewModel trata retorno da galeria sem SDK na UI.

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
- Services: interfaces testáveis e implementações sem estado de negócio; chamadas
  ao SDK Supabase/plugin e DTOs exclusivamente em data/services e data/models.
  Converter falhas externas para resultado tipado, sem lançar ao Widget. Testes de
  Services usam operações/transportes controlados dentro dessa fronteira.
- Repositories: fonte de verdade, mapeamento DTO → domínio, cache permitido e
  orquestração de transações/reconciliação através de Services. Testar implementação
  real com Services falsos; não manter query, singleton do SDK ou plugin aqui.
  FlutterServicesClipboard não se confunde com a camada Services: o wrapper
  FlutterClipboardService é chamado pelo Repository e nunca por Widget.
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

1. Criar contratos/Result e fakes, esqueleto híbrido e composição com Provider/Services; manter
   logo/tema. Caracterizar fluxos atuais antes de remover o store global.
2. Construir banco/políticas e ambiente local isolado, sem importar demo_animals_v1.
   Preparar o script de fixtures no Setup, mas só executá-lo após as migrations
   T018/T019/T021 e antes de T023. Fixtures não podem depender de RPCs futuras;
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
| Início | test/ui/features/home/views/home_screen_test.dart | exibe logo e navega ao catálogo por comando do VM |
| Catálogo/busca | test/ui/features/animals/views/catalog_screen_test.dart | combina filtros, mostra resultado e abre detalhe |
| Favoritos | test/ui/features/favorites/views/favorites_screen_test.dart | mostra favorito ainda visível e permite remover |
| Detalhes | test/ui/features/animals/views/animal_detail_screen_test.dart | exibe campos públicos e copia interesse sem envio |
| Sobre | test/ui/features/home/views/about_screen_test.dart | exibe conteúdo e volta pelo fluxo previsto |
| Login | test/ui/features/auth/views/login_screen_test.dart | credenciais de teste autorizadas levam ao painel |
| Painel | test/ui/features/animals/views/dashboard_screen_test.dart | alterna Kanban/lista e confirma alteração de status |
| Cadastro/edição | test/ui/features/animals/views/animal_editor_screen_test.dart | valida, salva, seleciona e confirma foto por fake |

Cada VM, Repository e Service com tratamento/validação tem suíte própria com flutter_test, sem rede:
validação de fronteira (0/1/80/81 e 3000/3001, cuidados 1000/1001), loading,
sucesso/falha/timeout, sessão e permissões, dispose/resposta tardia, mapeamento,
PostgrestException/AuthException/StorageException/FunctionException,
preferências, cancelamento e foto anterior preservada. Testar orquestração real
do Repository com Services falsos; testar Services reais com SDK/transportes controlados.
Não substituir a classe sob teste por um fake.

Gate de arquitetura varre imports, arquivos e tokens de acesso SDK: proibir pacotes
de infraestrutura em Widgets (permitir provider apenas para VMs); data em VMs;
consultas fora de data/services; UI/Supabase em domain;
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
| CR-001, CR-002 | árvore híbrida, Services, contratos, Result | architecture test + revisão de responsabilidades |
| CR-003, CR-004 | matriz de testes | unitários por regra de VM/Repository/Service + oito telas |
| CR-005, CR-006, CR-007 | backend, dependências, gates | testes reais de autorização + revisão de plano/commits |

A próxima fase de tasks deve ordenar fundação → segurança/Auth → catálogo/manejo →
fotos → regressão/plataformas e mapear cada tarefa a estes requisitos. Não criar
etapas de implementação dentro deste comando.

## Complexity Tracking

Nenhuma violação da constituição 2.0.0 autorizada. Funções de fotos e jobs de compensação
são complexidade necessária para FR-013, FR-014, FR-015, não justificativa para violar
isolamento, testes ou segurança. Não criar exceções por conveniência.

## Validation and Delivery Gates

Executar geração Freezed e o roteiro em [quickstart.md](quickstart.md). Distinguir quatro resultados:
formatação/análise, unitários/Widgets, segurança backend e plataforma. Nenhum gate
faltante é compensado pelos demais. A CI atual só executa Flutter; a implementação
DEVE acrescentar jobs SQL/Edge e integração local/homologação antes de declarar
SC-002/004/006 concluídos. Fixar versões de ferramenta/lockfiles na implementação.

Pendências operacionais: disponibilizar projeto Supabase de desenvolvimento,
provisionar contas de teste fora do app e configurar SDK Android/dispositivo.
Windows não valida build iOS. Essas dependências não mudam decisões arquiteturais
e não impedem gerar tasks; impedem declarar integração real ou build aprovados.

## Ajuste de implementação US1 — transporte HTTP controlado

`http` 1.6.0 passa a ser dependência direta justificada: já transitiva de
supabase_flutter, permite reconhecer ClientException como falha de rede nos
Services e injetar MockClient do próprio pacote para testar o SDK real sem rede.
A alternativa SDK puro com HttpServer exige sockets e não fornece um Client
compatível com o construtor SupabaseClient; fakes de Repository não testariam as
queries reais do Service. Não usar http em Views, VMs ou Repositories.
As operações Supabase continuam encapsuladas nos Services e usam o SDK.

A leitura de fotos usa resolve_photo_read service-only para checar atomicamente
visibilidade/vínculo ou staff/sessão antes de consultar Storage, pois auth.sessions
não é exposta no PostgREST. O ator e a sessão são verificados pelo handler, nunca
aceitos da query do cliente. Migration 004; futuras migrations de escrita,
finalização e manejo passam a 005/006/007 para preservar ordenação única.
O SDK functions_client recebe octet-stream por negociação Accept para preservar
bytes; requisições HTTP comuns recebem image/png ou image/jpeg. Nenhuma URL assinada.

### Storage: garantia por RLS restritiva

A inspeção local mostrou grants SELECT padrão no Storage mesmo após o REVOKE
inicial. A garantia de privacidade não depende de ausência de grants de tabela:
policies restritivas por bucket negam todas as operações anon/authenticated em
animal-photos, inclusive se surgir uma policy permissiva adicional. O servidor
usa service_role para entregar o proxy autorizado. Testes SQL simulam allow amplo,
e HTTP comprova negação de download/createSignedUrl; listagem expõe zero objetos.

## Ajuste US2 — validação de sessão e saída

access_context passa a retornar is_session_current, além de user_id/is_staff_active,
para distinguir conta sem staff de JWT cuja sessão foi revogada. Helper privado
verifica auth.sessions, usuário, prazo da sessão e expiração da claim; metadata
editável não concede staff. Migration 005_auth_session_context; as futuras escritas,
finalização e manejo passam a 006/007/008.

O SDK instalado apaga a sessão local antes de tentar revogação remota no logout.
Em falha remota, a UI continua pública e informa que só a saída local foi confirmada.
Não guardar tokens de retry fora do SDK nem apresentar retry vazio como sucesso:
o responsável pode entrar novamente e executar logout global para repetir a
revogação. Services permanecem sem cache de negócio; Repository serializa mutações
e impede conclusões antigas após logout. Não há nova dependência.

A rota protegida inicial apresenta apenas a confirmação de acesso autorizado.
O painel de manejo efetivo pertence à US5. A guarda aceita um conteúdo protegido
criado pela composição, testado com editor em memória, preservando montagem com
Offstage/ExcludeSemantics/IgnorePointer na expiração recuperável; logout/revogação/
outro usuário/cancelamento recriam ou removem o escopo. A integração do editor real
é verificada novamente na US3/US6, sem inventar funcionalidade de cadastro na US2.


## US3 — detalhe de implementação das RPCs

Consulta privada usa get_managed_animal/list_managed_animals para ler o agregado
completo em uma chamada e validar staff no servidor. A lista usa cursor name,id,
página 50 e total global; não é o painel por situação da US5. Salvamento usa lock
por ator/chave e digest SHA-256 do payload normalizado, com resultado privado em
write_operations. O SDK permanece somente no Service. Nenhuma nova dependência.
Funções SECURITY DEFINER têm search_path vazio e EXECUTE explícito, conforme
https://supabase.com/docs/guides/database/functions .


## US3 — integração de apresentação

A composição fornece callbacks de autorização e época de acesso aos VMs de editor
/listagem privada. Cargas iniciais agendadas após a montagem evitam notificar o
Provider raiz durante build. Widgets não consultam Services/Repositories.
FormVersion no snapshot imutável renova o estado interno dos campos ao receber um
agregado carregado/salvo, inclusive quando a resposta termina antes do próximo frame;
edições locais não renovam a versão nem perdem foco/texto. Cuidados novos têm identidade
local transitória para manter os controladores corretos ao remover um item; esses
identificadores não são enviados como IDs/autoria de banco.

Após timeout, o VM mantém rascunho e chave, bloqueia edição e permite consultar o
resultado. Ausência confirmada habilita reenvio do mesmo payload/chave. Um erro de
reconsulta não prova ausência nem libera nova submissão. Na expiração recuperável,
o mesmo escopo fica montado, oculto e bloqueado; resultados de épocas antigas são
ignorados. Logout/revogação/troca de usuário descartam VMs e pilha privada.


## US4 — empacotamento e fila

O WASM fixado de @imagemagick/magick-wasm 0.0.45 será incluído como static_file
versionado com checksum e licenças originais, sem fetch remoto durante uma requisição.
A configuração segue https://supabase.com/docs/guides/functions/wasm . Inicialização
compartilhada por isolate; processamento serial evita chamadas concorrentes ao heap.
Normalização mantém formato JPEG/PNG, remove metadados e ajusta tamanho de saída.
Jobs têm token de processamento privado e prazo de 15 minutos; limpeza marca o
estado terminal antes da remoção e usa leases de 5 minutos com retry persistente.
Cron chama função interna a cada 15 minutos via pg_net; URL/segredo ficam no Vault,
fora de migrations e builds. Sem Vault configurado, o agendamento não faz requisição;
provisionamento e prova local devem constar nas evidências antes de marcar concluído.


## Calendário — planejamento solicitado em 2026-10-31

Preservar a aba Calendário do protótipo. Sua implementação fica em etapa posterior
à US5: definir primeiro eventos reais, datas, fuso, permissões e relação com os
cuidados clínicos; especificar ações e estados, testes unitários/Widget e migrations
antes de implementar. Não gerar eventos ou datas a partir de textos livres de cuidados.
A responsável definiu uma agenda de medicamentos: calendário com compromissos por
animal, datas/horários e conclusão como lista de tarefas, alimentada automaticamente
por tratamentos estruturados da ficha. Escopo e decisões em
[calendário de medicações](../003-medication-calendar/plan.md), com especificação,
contratos e 50 tarefas em ../003-medication-calendar/tasks.md.
Até essa etapa, a aba informa que está em planejamento, sem exibir calendário fictício.
Não confundir esta inclusão no plano com funcionalidade entregue.
