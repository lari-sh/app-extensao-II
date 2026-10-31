# Research: adequação à constituição

**Date**: 2026-10-31 | **Feature**: 001-align-app-constitution
**Status**: decisões de desenho resolvidas; nenhum serviço instalado/provisionado
ou teste novo executado por esta pesquisa.

## R1 — MVVM e fronteiras

**Decision**: ChangeNotifier, injeção por construtor, ListenableBuilder e contratos
abstratos por feature. ViewModels calculam validação, filtros, capacidades e mensagens.
Repositories concretos mantêm as chamadas ao SDK em seus próprios arquivos.
**Rationale**: A separação View/VM/Repository é consistente com o guia Flutter;
a constituição exige isolamento mais estrito do que a simples recomendação.
**Alternatives considered**: Provider/Riverpod e services de SDK separados aumentam
dependências ou deslocam queries para fora da fronteira exigida.
**Sources**: [Flutter architecture](https://docs.flutter.dev/app-architecture/guide),
[recommendations](https://docs.flutter.dev/app-architecture/recommendations).

## R2 — Result e teste das implementações reais

**Decision**: Result<T> sealed e AppFailure tipada; streams usam Result nos eventos
e convertem onError. Testar VM com fake de Repository e Repository real com
callbacks de operações controladas, definidos no arquivo da implementação.
**Rationale**: Não requer rede ou bibliotecas de mocking; erros do SDK não chegam
ao domínio ou às Views. Testes backend separados comprovam comportamento externo.
**Alternatives considered**: Catch em Widget e substituir Repository sob teste por
fake não comprovam captura/mapeamento da implementação.
**Sources**: [Result](https://docs.flutter.dev/app-architecture/design-patterns/result),
[layer testing](https://docs.flutter.dev/app-architecture/case-study/testing).

## R3 — Separar público e clínico

**Decision**: Tabela animals contém exclusivamente campos divulgáveis; notas,
cuidados, autoria e membership ficam em tabelas privadas. RLS concede leitura
pública somente a publicado e não adotado, com projeção explícita no Repository.
**Rationale**: RLS protege linhas, não torna colunas privadas por omissão no cliente.
**Alternatives considered**: Uma tabela com tudo e select parcial deixa outros
clientes consultarem colunas internas; views privilegiadas sem security_invoker
podem contornar políticas. Não usar esse atalho.
**Source**: [Supabase RLS](https://supabase.com/docs/guides/database/postgres/row-level-security).

## R4 — Membership e sessão atuais

**Decision**: Membership ativa mantida fora do app e helper de autorização que
confere auth.uid(), session_id válido existente em auth.sessions e membership
atual, por função estreita com search_path fixo. Tratar expiração também pelo JWT
validado. RLS e RPCs protegidas consultam esse helper, não claims de função em cache.
**Rationale**: JWT pode continuar válido após logout até expirar; presença da
sessão no servidor e membership atual evitam conceder acesso com claims antigas.
**Alternatives considered**: Ocultar botão, user_metadata ou role guardada no cliente
não fornecem autorização no servidor. Não há cadastro público de equipe.
**Sources**: [Sessions](https://supabase.com/docs/guides/auth/sessions),
[RLS](https://supabase.com/docs/guides/database/postgres/row-level-security).

## R5 — Revogação de fotos sem depender de CDN

**Decision**: Bucket privado; função animal-photo-read verifica visibilidade ou
autorização atual e entrega bytes com Cache-Control: no-store, private. Não
redirecionar nem emitir URL assinada para o cliente. Nenhum grant direto de Storage
para anon/authenticated. Imagem chega ao VM como bytes, sem URL/backend no Widget.
**Rationale**: A duração de cache pode ser independente da validade do token de URL;
60 segundos de expiresIn sozinho não garante FR-015.
**Alternatives considered**: Bucket público ou signed URL com TTL sem teste de cache
não cumprem a retirada de publicação. Não prometer apagar cópias já baixadas.
**Sources**: [Smart CDN](https://supabase.com/docs/guides/storage/cdn/smart-cdn),
[private-file caching](https://supabase.com/kb/troubleshooting/storage-private-bucket-files-still-accessible-after-remove-access-or-logout).

## R6 — Upload validado e substituição compensável

**Decision**: Upload autenticado por função: autenticar e autorizar antes de ler o
corpo; limitar arquivo a 5.242.880 bytes e multipart a 5.308.416 bytes, contando
cada um separadamente. Detectar JPEG/PNG, decodificar e normalizar com magick-wasm;
se a primeira saída exceder 5 MB, ajustar compressão/resolução preservando proporção
antes de gravar, sem rejeitar por esse aumento isolado. Job criado antes de gravar o objeto. Trocar referência
em transação após upload/validação, com caminho imutável e reconciliação por job.
**Rationale**: Extensão/MIME informados não comprovam conteúdo; banco e Storage não
compartilham transação. O job mantém órfãos rastreáveis e a imagem anterior intacta.
**Alternatives considered**: Sobrescrever objeto atual expõe caches/consistência;
Sharp depende de nativos. WASM é suportado no exemplo oficial. Limites reais de
CPU/memória devem ser ensaiados com imagens válidas antes de aceitar o pipeline.
**Sources**: [Image manipulation](https://supabase.com/docs/guides/functions/examples/image-manipulation),
[standard uploads](https://supabase.com/docs/guides/storage/uploads/standard-uploads),
[function authentication](https://supabase.com/docs/guides/functions/auth).

## R7 — Galeria e ciclo de vida mobile

**Decision**: image_picker 1.2.4 no PhotoRepository, galeria apenas,
requestFullMetadata:false, NSPhotoLibraryUsageDescription em português; sem
permissões de câmera/microfone. retrieveLostData via Repository no startup Android.
**Rationale**: O plugin atende Android 24+/iOS 13+; atividade pode ser destruída
durante o picker. Resultado recuperado nunca dispara upload automático: exigir
sessão validada e seleção/confirmação do animal, sem persistir prontuário/rascunho.
Permissão negada é Failure(permissionDenied), testada no Repository, VM e Widget;
cancelamento é Success(null), sem upload e sem perda do formulário/foto anterior.
**Alternatives considered**: MethodChannel próprio não agrega valor ao escopo.
**Source**: [image_picker](https://pub.dev/packages/image_picker).

## R8 — Favoritos e dependências

**Decision**: Manter shared_preferences 2.5.6 para IDs em favorites_v1;
ignorar demo_animals_v1 e nunca importar fixtures na nuvem. Propor supabase_flutter
2.18.3 estável e image_picker 1.2.4; confirmar resolução conjunta na implementação.
**Rationale**: Favoritos são preferências não críticas; prontuários exigem backend.
As versões candidatas não são resultado de um novo pub get neste comando.
**Alternatives considered**: Migração automática da demonstração arriscaria publicar
animais fictícios; cache clínico/offline está fora do escopo.
**Sources**: [shared_preferences](https://pub.dev/packages/shared_preferences),
[supabase_flutter](https://pub.dev/packages/supabase_flutter).

## R9 — Escrita idempotente e transacional

**Decision**: save_animal RPC com chave de operação estável por submissão,
autor/resultado em tabela privada e atualização de animal/cuidados na mesma
transação. Repetição após perda de resposta consulta operação anterior. Atualização
de formulário usa apenas os campos editáveis, sem sobrescrever photo_id.
**Rationale**: Timeout do cliente não desfaz gravação já aceita; token e unicidade
evitam segundo cadastro. Lock na linha controla troca de foto concorrente.
**Alternatives considered**: Desabilitar botão sozinho não cobre perda de resposta;
três escritas independentes podem salvar metade de um cadastro.
**Source**: [Database functions](https://supabase.com/docs/guides/database/functions).

## R10 — Estado do ambiente e decisões finais

**Decision**: Planejar com SDK Flutter existente; validar Android no CI/dispositivo,
RLS/Storage em Supabase local e iOS em Mac separado. Configuração via valores
públicos de cliente; segredos privilegiados somente no ambiente das funções.
**Rationale**: O projeto atual possui apenas testes iniciais e não há evidência de
integração real. Acesso ao projeto Supabase e SDK Android são pré-requisitos
operacionais para executar os gates, não decisões arquiteturais pendentes.
**Alternatives considered**: Dados demo como fallback e aprovação iOS pelo Windows
produziriam evidência falsa.

Todos os pontos de desenho têm decisão. Não há marcador de esclarecimento pendente.
