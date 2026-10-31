# Evidências de implementação

Data: 2026-10-31. Branch: `developer`.
Baseline: `52c03e2abe04a447af3617c23013da5927427616`.

## T001 — Baseline [CR-006, CR-007]

- Comando: `flutter test --reporter expanded`, Flutter 3.41.1/Dart 3.11 no Windows.
- Resultado: PASS, 3 testes existentes (persistência local, catálogo/favoritos e formulário demo).
- O primeiro acesso restrito ao SDK retornou acesso negado; execução com acesso ao cache autorizada passou.
- Estes testes caracterizam a demonstração; não comprovam Supabase, autenticação, upload, MVVM ou RLS.
- Gaps: AnimalStore global, SDK/plugin nas telas, regras em Widgets, acesso administrativo demo; ainda sem Services/Repositories/VMs e oito testes de telas adequadas.
- Commits novos: `tipo(escopo): descrição no imperativo [001-FR-NNN]` ou `[001-CR-NNN]`, usando IDs reais. Nenhum histórico reescrito.
- Tipos permitidos: feat, fix, docs, style, refactor, test, chore. Integração à main somente por PR.

## Ambiente

- Docker CLI 29.2.0 instalado; engine desktop-linux indisponível na inspeção inicial.
- Supabase CLI e Deno não encontrados no PATH inicial.
- Testes backend, Android e iOS ainda não executados.

## Setup T002–T006

- T002: flutter pub get passou e pubspec.lock fixa as versões justificadas;
  Flutter test após resolução: PASS, mesmos 3 testes. Pacotes transitivos do
  gerador (built_value/json_annotation) não são escolhas diretas adicionais.
- T003: CLI 2.122.0 inicializou config.toml; Auth/email sem signup, sem seed demo,
  autoexposição desativada; segredos ignorados; Docker Engine 29.2.0 iniciado.
- T004: fronteira AppDependencies e árvore híbrida criadas; nenhum I/O ou nova regra.
- T005: Deno 2.8.3, supabase-js 2.118.0 e magick-wasm 0.0.45 fixados com deno.lock.
- T006: fixtures locais preparadas e verificadas por deno check (PASS).
  Primeira checagem detectou quatro erros de inferência das uniões Auth; corrigidos.
  Não executadas: dependem de T018/T019/T021; nenhuma conta ou registro criado.
- A inicialização completa da instância Supabase está baixando imagens e ainda
  não comprova execução de políticas/testes backend.

## Fundação T007–T023

- T007–T011: fase vermelha com seis falhas de comportamento em contratos compiláveis;
  implementação de Result/streams, configuração fail-closed e operation_key de 24
  bytes seguros. Nove testes de utilitários/arquitetura passaram após implementação.
- T012–T015: nove modelos Freezed e contratos independentes do SDK, DTOs manuais;
  duas falhas de limites de formulário comprovadas antes da implementação.
  Cinco testes de modelos/DTOs passaram depois, incluindo separação público/privado.
- T016: fakes manuais com handlers assíncronos, chamadas registradas e streams,
  permitindo Completers/falhas sem substituir a classe real sob teste.
- T017–T019/T021: três migrations aplicadas exclusivamente com `migration up --local`.
  pgTAP: PASS, 23 testes de tabelas, grants/RLS, anon/não staff/staff,
  autoaprovação, membership e sessão revogadas e session_id malformado.
  Execução antes das migrations demonstrou ausência de tabelas (fase vermelha).
- T020: entrada main passa por bootstrap seguro e Provider; sem configuração,
  não inicia SDK nem apresenta demo. Dois testes de inicialização passaram.
  Services/Repositories das jornadas serão registrados conforme suas implementações
  em T036/T049 e seguintes; não há fallback produtivo para AnimalStore.
  O código antigo foi isolado em legacy_demo.dart para manter os três testes de
  caracterização até sua retirada em T100. A entrada configurada ainda mostra
  indisponibilidade até a integração das jornadas; não constitui app concluído.
- T022: tema vermelho/marrom extraído; componentes recebem bytes/rótulos prontos.
- T023: fixtures executadas após as três migrations: 60 animais, três contas e duas
  fotos locais. Nenhuma RPC futura utilizada; nenhuma credencial versionada.
- Testes HTTP reais Deno: PASS, 3 testes; signup bloqueado, login provisionado,
  notas e escritas protegidas, download/assinatura negados e revogação de JWT.
  Storage list devolve lista vazia sob RLS; isso não expõe objetos. O teste exige
  zero objetos e negação explícita de download/createSignedUrl, sem supor HTTP 403
  para toda listagem.
- Correção de configuração comprovada: na CLI 2.122.0 o flag email.enable_signup
  habilita o provider. Manter true para login e auth.enable_signup=false para negar
  novas contas. HTTP verificou ambas as propriedades após reinício com backup local.
- Geração neste Puro: `flutter pub run build_runner build --delete-conflicting-outputs`
  (PASS). `dart run` direto não reconheceu flutter_test SDK; não é falha de modelos.
- Gate Flutter: `flutter test --reporter expanded`: PASS, 19 testes, incluindo três
  legados. Não equivale aos oito caminhos felizes finais, ainda pendentes.
- Android/dispositivo/iOS e jornadas completas Supabase ainda pendentes.

## Gate do primeiro incremento

- `dart format --output=none --set-exit-if-changed lib test`: PASS, 78 arquivos,
  nenhuma mudança após formatação. Um desvio de formato do DTO foi corrigido.
- `flutter analyze`: PASS, sem problemas. Lints de chaves e uso de anonKey
  obsoleto corrigidos; bootstrap usa publishableKey conforme SDK resolvido.
- `flutter test --coverage --reporter expanded`: PASS, 19 testes; lcov local ignorado.
- Regeneração: PASS, hashes dos dez .freezed.dart idênticos antes/depois.
- `supabase test db` após fixtures: PASS, 23 testes. A primeira repetição revelou
  contagens dependentes de banco vazio; testes agora filtram seus próprios UUIDs
  e alteram somente o ator do cenário, sem apagar nem depender de fixtures externas.
- Deno check: PASS; Deno HTTP: PASS, 3 testes. Fixtures repetidas com sucesso;
  PNG de teste possui chunks/CRC gerados segundo o formato PNG.
- `flutter doctor -v`: Flutter 3.41.1/Dart 3.11; SDK Android não encontrado.
  Build/APK e dispositivo Android não executados. iOS depende de Mac/Xcode.
- Hooks: .specify/extensions.yml ausente; nenhum hook before/after_implement.
- Este é o primeiro incremento. T024–T108 continuam pendentes; catálogo real,
  login nas telas, cadastro, upload, manejo e oito Widgets principais não foram
  declarados concluídos. A inicialização configurada ainda não conecta jornadas.

- Revisão Git: o gerador Freezed 3.2.5 emite espaços em linhas vazias nos arquivos
  .freezed.dart. Mantidas as saídas originais para preservar a regeneração exata;
  `git diff --cached --check -- . ':(exclude)*.freezed.dart'` verifica os arquivos
  mantidos manualmente. Isso não é falha de análise ou teste Dart.

## US1 — Catálogo público T024–T043 [FR-001, FR-002, FR-003, FR-015, FR-018]

Base do incremento: 31326e20a453bc55f69476ec9dfdb189ec2fd13d. Código e evidências
validados antes da entrega. Commit de código: 5497313713a951772dbe30a345c53b3010b7cacc;
a presente atualização documental vincula os resultados a esse código.

- Services reais com SDK e MockClient: filtros combinados antes de paginar,
  busca literal, ordem ascendente name/id, páginas de 50 e total global, cursor,
  notFound, rede/HTTP e respostas binárias. Compartilhamento de http 1.6.0
  justificado previamente no plano; não é usado em VMs/Views/Repositories.
- Repositories reais com Services falsos: mapeamento DTO/domínio/Result, captura
  inesperada, favoritos inválidos e batches 50/50/21, persistência confirmada,
  falha local sem sucesso falso, duas mudanças concorrentes, cópia sem envio e
  quatro pedidos de fotos simultâneos, sem cache entre novas consultas.
- VMs: filtros invalidam cursor, resposta antiga/dispose não sobrescrevem estado,
  loading encerra em falha, seleção/favoritos/adoção calculados fora do Widget.
- Cinco Widgets felizes: início, catálogo, favoritos, detalhes e sobre. Rotas
  criam VMs e iniciam operações antes de montar; Provider gerencia dispose.
- Primeiras execuções comprovaram falhas dos stubs de Services/Repositories,
  carregamento do VM e cinco telas vazias antes de completar as implementações.
- Erros do SDK encontrados nos testes: MockClient deve preencher response.request;
  ordenação precisa ascending:true explícito; maybeSingle pode preservar HTTP 403
  em vez de 42501. Corrigidos sem expor mensagens brutas à interface.
- Função animal-photo-read e resolver service-only: bytes apenas do job atual
  attached, vínculo ao animal e autorização atual, sem redirect/URL assinada/cache.
- Inspeção SQL encontrou SELECT padrão em storage.objects; a garantia foi tornada
  explícita com RLS RESTRICTIVE por bucket, inclusive contra policy permissiva
  adicional. A migration 004 ainda não publicada foi reaplicada por db reset
  **somente local**, com fixtures reconstruídas. Nenhum banco remoto foi vinculado.

### Gates executados

- `flutter analyze`: PASS, nenhum problema.
- `flutter test --no-pub --coverage --reporter expanded`: PASS, **59 testes**,
  incluindo cinco Widgets principais e três testes legados de caracterização.
- `dart format --output=none --set-exit-if-changed lib test integration_test`:
  PASS, 126 arquivos sem alteração.
- `supabase test db`: PASS, **29 testes** em dois arquivos; grants do resolver,
  RLS de notas/sessões e negação de leitura/insert mesmo sob allow amplo.
- `deno check` do handler/testes: PASS. Testes HTTP: PASS, **5 testes**; público,
  privado, membership/sessão revogadas, animal/foto incompatíveis, caminho
  arbitrário, download/listagem/assinatura diretos e cache/304/redirect.
- Android: `flutter test integration_test/public_catalog_flow_test.dart -d
  emulator-5554` com URL 10.0.2.2 e chave pública local: PASS, **1 jornada real**.
  Conectou a 60 fixtures, exibiu 58 públicas em duas páginas, filtrou um nome,
  exibiu PNG real, copiou interesse, negou detalhe privado e recuperou favorito
  após destruir/recriar a árvore do app com novos Repositories e armazenamento
  nativo. Isso comprova recriação do app; não equivale a reboot físico do aparelho.
- As duas primeiras tentativas Android encontraram problemas do teste: alvo fora
  da viewport e busca por texto ambígua entre campo e cartão. Corrigidos com
  rolagem até hitTestable e seleção do texto dentro do Card; execução final PASS.
- APK normal debug também compilado; APK de integration_test é temporário e não
  deve ser confundido com artefato normal. Configuração de backend só por defines
  públicos; não há service_role ou senha de fixture na build.
- iOS e dispositivo físico continuam não validados. Autenticação nas telas,
  escrita, upload e manejo correspondem às histórias seguintes, ainda pendentes.
- Sem hooks: .specify/extensions.yml ausente. Checklist de requisitos 19/19
  revisado, sem alterar marcações durante implementação.

## Instalação Android solicitada [FR-019]

- Android Studio Rabbit 2 / 2026.2.2 instalado no perfil da usuária e aberto.
  A janela foi conferida por computer-use; posteriormente o projeto estava aberto
  no Studio, sem alteração da sessão de trabalho pela automação.
- CLI Android 22, API 36, Build Tools 35/36, NDK 28.2.13676358, CMake 3.22.1,
  Java Microsoft 21.0.13.0.2 e licenças aprovadas; flutter doctor aprovou toolchain.
- Downloads Google/Microsoft conferidos por SHA-256 oficial antes de extrair;
  JDK 21 usado pelo Gradle 8.14, JBR do Studio mantido para a própria IDE.
- SDK/JDK/Flutter configurados no perfil; novos terminais carregam o PATH atualizado.
- Emulador Medium_Phone_API_37.0, WHPX, usado em modo de teste sem janela e
  read-only. Testes não alteram a imagem persistente do dispositivo virtual.
- Fonte: https://developer.android.com/studio e
  https://learn.microsoft.com/en-us/java/openjdk/download ; compatibilidade:
  https://docs.gradle.org/current/userguide/compatibility.html .

### Persistência após encerramento real do processo

PASS adicional no APK normal configurado para o Supabase local do emulador.
Salvo o favorito pela interface, confirmado o estado “Remover ... dos favoritos”,
executado `adb shell am force-stop` e reaberta MainActivity com `am start -W`.
O Android confirmou **LaunchState: COLD**. Ao abrir Favoritos novamente, a interface
mostrou Animal de teste 01, comprovado pela árvore de acessibilidade do Android.

A primeira tentativa de comparar com a instalação do APK de integration_test
retornou lista vazia: inspeção de flutter_tools/src/test/integration_test_device.dart
confirmou que kill() desinstala o aplicativo de testes e remove seus dados. A prova
válida foi refeita salvando no APK normal e reiniciando sem desinstalar. Não foi
necessária mudança no armazenamento do aplicativo.

Último APK em build/app/outputs/flutter-apk/app-debug.apk é o **APK normal de debug**
com configuração pública para http://10.0.2.2:54321, exclusivo deste ambiente local
no emulador. Não contém senha ou service_role; requer Supabase local em execução.
Geração Freezed refeita: PASS, hashes de todos os arquivos gerados preservados.
43/108 tarefas concluídas; US2 e seguintes continuam pendentes.


## Autenticação — validação parcial em 2026-10-31 [FR-005, FR-006]

Estado: incremento de autenticação preparado para commit na branch developer;
a validação nativa desta etapa permanece pendente. O marco anterior de 43/108 tarefas permanece histórico; US2 não está
concluída enquanto T054 e a revisão dos critérios não forem encerradas.

- Nova execução de flutter analyze: PASS, nenhum problema encontrado.
- Nova execução de flutter test --no-pub --reporter compact: PASS, **81 testes**.
  Inclui testes dos Services/Repositories de autenticação, ViewModels de login e
  sessão, login/guard como Widgets, composição Provider e remoção de rotas privadas
  após saída, além da regressão da jornada pública e caracterização legada.
- SQL executado nesta etapa: PASS, **36 testes**, incluindo sete novos casos de
  contexto de sessão. HTTP executado nesta etapa: PASS, **6 testes**, incluindo
  metadados sem concessão de staff e sessão revogada. Estes resultados são de
  backend local; não substituem a jornada de autenticação em dispositivo.
- Migration 005_auth_session_context implementada/aplicada localmente. Escrita,
  finalização de fotos e manejo serão migrations 006/007/008, ainda pendentes.
- O conteúdo da área autorizada é uma confirmação de acesso. Não comprova cadastro,
  edição, upload ou dashboard de manejo, que pertencem às histórias seguintes.
- T054: login/saída reais no Android e restauração após reinício ainda pendentes.
  Nenhum resultado nativo novo de autenticação é declarado neste registro.
- iOS continua pendente de Mac/Xcode e testes próprios de plataforma.

README, quickstart e contrato backend atualizados para separar recursos existentes,
cenários futuros e resultados executados. Nenhuma credencial incluída nos documentos.


## US2 — jornada Android aprovada [SC-002]

Em 2026-10-31, branch developer, incremento após 3483890:
`flutter test integration_test/authentication_flow_test.dart -d emulator-5554`
com URL local 10.0.2.2, chave pública e ALLOW_LOCAL_HTTP=true: **PASS, 1 jornada**.
Contas fictícias: senha inválida negada, não staff negado, staff autorizado,
restauração após recriar árvore/composição usando a sessão persistida pelo SDK,
logout com pilha privada removida e membership revogada negada em resume.
A restauração deste teste não equivale a reboot físico ou reinício do processo.
A revogação de sessão, separadamente, possui prova HTTP/SQL da etapa anterior.

O controlador `supabase/tests/fixtures/android_auth_control.py` fornece senha de
fixture somente em execução via loopback, restrito ao Supabase local descartável;
chaves administrativas ficam no host. Não há senha nem service_role no APK.
Restaura a membership no finally do teste e ao encerrar normalmente o controlador.
Não executar em homologação/produção nem deixá-lo ativo após os testes.

A primeira tentativa perdeu conexão com o emulador e não concluiu. Após reiniciar
o emulador, a execução completa passou em 22 s (mais build/instalação). A asserção
de Voltar verifica canPop=false na raiz após logout, sem fechar a Activity.
T044–T054 encerradas: **54/108 tarefas concluídas**. CI/CD detalhada na T103,
conforme solicitação; execução mantida para a fase de entrega após as histórias.


## US3 — backend de cadastro/edição [FR-007, FR-008, FR-009, SC-003]

Incremento após e0ec083, Supabase local descartável, 2026-10-31:
- Testes escritos antes: SQL falhou pela ausência de save_animal; nove testes de
  Service/Repository falharam com configuration nos métodos ainda não implementados.
- Migration 006_animal_writes aplicada localmente. `supabase test db`: **58 PASS**,
  sendo 22 casos de escrita. Inclui limites exatos de caracteres Unicode, rejeição
  de campos privilegiados, autoria servidor, chave repetida/conflitante e negação
  após revogação. Trigger de teste provoca falha depois da atualização do animal;
  animal, notas e cuidados anteriores são preservados pelo rollback da transação.
- `deno task --env-file=supabase/.env.local --config supabase/functions/deno.json test`:
  **7 PASS**. Nova prova HTTP usa duas sessões reais; cria privado, edita em outra
  sessão, relê atualização, reconcilia resposta perdida e dispara dois saves
  concorrentes com a mesma chave: ambos retornam o mesmo UUID. Replay após edição
  devolve o resultado original sem reverter os dados atuais. Visitante não lê notas
  nem o novo animal; escrita direta do cliente é negada. Fixtures criadas são limpas.
- Service/Repository: **9 novos testes PASS**; transporte real do SDK controlado,
  Result sanitizado, campos editáveis, autorização e chave preservada no timeout.
- Gate de desenvolvimento do conjunto: `flutter analyze` sem problemas e
  `flutter test --no-pub --coverage --reporter expanded`: **97 PASS**. Inclui editor
  em desenvolvimento; sua entrega nativa será registrada separadamente.

T055/T056/T057/T060–T063/T066 encerradas: **62/108 tarefas**. T058/T059/T064/T065
aguardam fechamento da integração da tela. Upload/publicação/manejo continuam nas
histórias seguintes. Banco remoto de produção não foi vinculado ou alterado.


## US3 — formulário e integração Android concluídos [SC-003, FR-006–FR-009]

Incremento após ba81951 em 2026-10-31, somente developer e backend local:
- **105 testes Flutter PASS** com cobertura; análise estática sem problemas.
  Editor: validação nos limites, enum obrigatório, duplo clique, timeout/reconsulta/
  reenvio com a mesma chave, autorização e descarte de respostas antigas, falha de
  carga sem cadastro acidental e retry. Lista: paginação, falhas e época de acesso.
- Widgets: cadastro/edição, adicionar/remover cuidado, confirmação remota,
  lista→edição e editor real preservado mas invisível/bloqueado na expiração;
  mesmo usuário retoma e logout descarta VM/rascunho. Raiz Provider cobre a montagem
  e a remoção de todas as rotas privadas, não apenas da confirmação de acesso.
- Geração Freezed repetida com hashes preservados: **PASS**.
- `flutter test integration_test/animal_editor_flow_test.dart -d emulator-5554`:
  **PASS, 1 jornada (22 s + build/instalação)**. Cria privado, registra cuidado e
  nota, outra sessão verifica, edita sem trocar UUID e fecha/reabre a rota lendo
  os valores persistidos. Fixture removida pelo controlador --cleanup-editor.
- Jornada de autenticação repetida, agora com dispose/reinitialize do SDK:
  **PASS, 1 jornada (13 s + build/instalação)**. Recupera a sessão do armazenamento
  nativo e revalida remotamente antes de exibir privado. Não é reboot físico.
- Backend segue **58 SQL PASS / 7 HTTP PASS**. HTTP ampliado: o transporte consome
  uma resposta bem-sucedida de save e devolve falha ao cliente; outra sessão
  confirma o commit por get_write_operation e reenvio com a mesma chave é seguro.

As execuções Android anteriores encontraram interações de teste com teclado,
rolagem de campos fora da árvore e helper Back em inglês. Corrigidas. Também
revelaram dois defeitos de integração: notificação de sessão durante montagem e
campos mantendo initialValue antigo após carga rápida. Ambos receberam teste de
regressão que falhou antes da correção e passou depois. Carga inicial agora ocorre
após montagem, e formVersion atualiza os campos ao carregar/salvar o agregado.
Não tratar as tentativas anteriores como evidência aprovada.

T058/T059/T064/T065 encerradas: **66/108 tarefas concluídas (US1–US3)**.
Upload, publicação/painel por situação, remoção do legado e gates finais permanecem
pendentes nas histórias seguintes. CI/CD registrada na **T103**; nenhuma execução
de GitHub Actions nova foi declarada aprovada. iOS segue dependente de Mac/Xcode.
Sem hooks after_implement: .specify/extensions.yml ausente.


### Encerramento da etapa

Revisão final de Widgets/rotas/arquitetura: **7 PASS**, incluindo remoção de cuidado
após aguardar a atualização do layout. Nenhuma alteração de dependências.
Fixtures temporárias do editor removidas, membership de teste restaurada e
controlador de loopback encerrado ao terminar as jornadas. Credenciais de servidor
permanecem apenas no ambiente ignorado pelo Git.


APK normal de debug recompilado com sucesso após as jornadas, em
build/app/outputs/flutter-apk/app-debug.apk, com URL 10.0.2.2 e chave pública local.
Substitui o APK temporário de integration_test nesse caminho. Não contém senha,
service_role ou assinatura de publicação; requer Supabase local em execução.


## US4 — incremento de galeria (parcial)

Seleção e recuperação isoladas em ImagePickerGalleryService, mediadas pelo
PhotoRepositoryImpl. Sem nova dependência. Testes antes da implementação falharam
por ausência do Service/argumento gallery; gate final: **8 testes PASS** (quatro
novos + leitura/arquitetura), análise sem problemas. Cancelamento retorna null,
permissão negada retorna failure, tamanho é consultado antes de ler arquivo e MIME
preliminar vem da assinatura. A recuperação apenas devolve um candidato; não envia
fotos automaticamente. A integração da tela e o endpoint ainda estão em andamento.
T067/T068/T078/T079 serão encerradas somente com o conjunto de seus critérios.


## US4 — backend e transporte validados (incremento)

2026-10-31, developer, somente Supabase local:
- Migration 007: finalização transacional, replay sem reassociar foto antiga,
  conflito por digest, FK animal/foto, fila/lease/backoff e cron de 15 minutos.
  Testes antes da implementação falharam por RPC ausente; versão final **78 SQL PASS**
  (20 novos casos), incluindo retry e proteção contra dois workers.
- **12 testes Deno/HTTP PASS**: arquivo válido de exatamente 5.242.880 bytes com
  overhead multipart aceito, arquivo/corpo acima do limite e campos duplicados
  negados, conteúdo corrompido negado, normalização JPEG/PNG e remoção de metadados.
  O teste de ajuste de saída usa orçamento menor com imagem real para exercitar
  a redução; não é um benchmark de todos os tamanhos/dimensões possíveis.
- HTTP no Edge Runtime local: upload concorrente, foto antiga preservada em falha,
  replay com resultado original/current_photo_id separados, resposta descartada e
  reconciliação, público/privado sem cache, URL assinada negada e dois workers de
  limpeza sem apagar a foto atual. Fixtures temporárias removidas ao terminar.
- Transporte Dart e Repository: **9 testes PASS**, incluindo multipart, erros
  403/409/413/415/422/503, GET e chave preservada. Upload tem timeout de 60 s;
  demais operações mantêm 20 s. Nenhuma dependência nova.
- Vault local provisionado com URL interna e segredo de limpeza; invocação por
  pg_net retornou **HTTP 200**. Segredo somente no ambiente/Vault, nunca migration,
  APK ou documentação. Cron usa o segredo atual do Vault; provisionar separadamente
  em qualquer ambiente remoto, que não foi vinculado ou alterado.
- WASM 0.0.45 incluído como static_file com licenças: SHA256
  54629cbcf06dd10db38b4d87fa6ab241b248c09c94f2d9689506e5f994ac5f0c.
  Inicialização compartilhada e acesso serial ao heap. Prova funcional no runtime
  local não equivale a teste de carga/exaustão de memória de produção.

Integração do painel, testes de Widgets e jornada Android ainda em andamento.
Não declarar US4 concluída antes desse gate. Nenhum segredo foi versionado.

As licenças/NOTICE de terceiros são preservadas como distribuídas; o gate de whitespace exclui MAGICK_NOTICE, que contém espaços finais originais, além dos arquivos gerados Freezed. Não há exclusão dos fontes de implementação.


## US4 — painel integrado e emulador disponibilizado (parcial)

Painel conectado ao editor por VMs/Provider, sem Services ou Repositories na View.
Galeria em Service; candidato recuperado exige conta revalidada e confirmação do
animal, nunca dispara upload automático. Formulário novo precisa ser salvo antes
 de enviar foto. A foto atual só é trocada depois da confirmação; candidato tem
prévia e botão de envio separado. Saída/revogação descartam escopos privados.

Gate direcionado: nove testes de painel/VM/rotas PASS. Widget de permissão negada
comprova loading encerrado, foto e rascunho preservados e zero upload. iOS 13 já
configurado; adicionada descrição de fotos em português. Android mínimo 24 explícito,
sem permissões de câmera/microfone. iOS não foi executado neste Windows.

APK normal com configuração pública local compilado e instalado; MainActivity
aberta com LaunchState COLD no emulador visível Medium_Phone_API_37.0, conforme
pedido da usuária para testar. Docker/Supabase e funções locais retomados sem reset.
Abertura do app não equivale à validação completa do seletor/upload no Android;
essa jornada e a recuperação após destruição de Activity continuam pendentes.
O aparelho ficou disponível para os testes manuais da usuária, sem automação nativa
concorrente. Os testes Flutter desta etapa rodam fora do emulador.

Gate da integração: 125 testes Flutter PASS; análise estática sem problemas. Dois testes adicionais reproduziram e protegeram a troca de animal durante seleção e uma consulta pendente após ausência inicial, evitando loading preso e reenvio prematuro.


## US4 — jornada de galeria nativa Android aprovada

Após 3e17055: `flutter test integration_test/photo_gallery_flow_test.dart -d
emulator-5554` com o controlador local e native_picker_driver.py: **PASS, 1 jornada**.
Photo Picker real do Android 37: cancelar preserva rascunho; duas imagens sintéticas
selecionadas, prévia sem upload automático, confirmação, download da foto atual,
substituição com novo UUID e verificação no Supabase. Notas não salvas continuam em
memória do formulário, sem alteração remota; logout remove painel privado.

O driver foi adaptado aos controles Compose/Done e pacote com.google.android.photopicker.
A primeira execução completou em 3m55s, incluindo a adaptação do driver em execução;
isto não é benchmark do tempo de upload. Testes Flutter seguem 125 PASS, análise
sem problemas. As fixtures criadas e seus objetos foram removidos pelo helper local.
Recuperação após destruição de Activity/processo será validada em prova separada.


## US4 — recuperação nativa e fechamento [SC-004, FR-013–FR-016]

2026-10-31, developer, APK normal e Supabase local:
- `native_photo_recovery_test.py`: **PASS**. Opção nativa Don't keep activities
  acionada pela interface de desenvolvedor; Browse abre DocumentsUI e permite a
  destruição da Activity. Nova inicialização de Flutter/Supabase comprovada pelo
  log; sessão restaurada, foto recuperada oferecida somente no editor autorizado.
  Antes da confirmação explícita do animal/envio, primary_photo_id permaneceu null
  e não havia job de upload. Após confirmar, foto persistiu e UI mostrou sucesso.
- As tentativas com SIGKILL e alteração somente do valor via settings não
  demonstraram o ciclo suportado de destruição/recuperação e NÃO foram contadas
  como sucesso. Na prova aprovada, opções são restauradas após confirmar o envio;
  sair novamente para Settings antes disso destruiria também o candidato em memória.
- Fixture exclusiva e objetos removidos ao final. Configuração temporária de
  destruição de Activities restaurada. O driver usa senha apenas em execução,
  não imprime credenciais e não modifica código de produção para simular recuperação.
- Gate final: **128 testes Flutter PASS**, com cobertura; análise sem problemas;
  Freezed regenerado com hashes preservados. **78 SQL PASS / 12 Deno/HTTP PASS**.
  Novos unitários comprovam descarte de bytes/resultado tardio em logout,
  identidade desconhecida e revogação durante confirmação de recuperação.
- Cron local observado com execução succeeded e invocação interna HTTP 200.
  URL/segredo no Vault local. Sem deploy remoto, assinatura release ou validação iOS.

T067–T083 encerradas: **83/108 tarefas concluídas (US1–US4)**. Próximas: manejo e
publicação (US5), regressão/remoção do legado (US6), CI/CD T103 e entrega/plataformas.
O checklist de requisitos permanece 19/19 e não foi alterado. Sem hooks pós-execução:
.specify/extensions.yml ausente. CI/CD continua planejada, não declarada executada.


Na restauração das opções do sistema, o ADB ficou indisponível. A conexão ADB do emulador está em restauração para uso manual; o APK normal
permanece gerado, com as provas acima concluídas. Isso ocorreu após as provas aprovadas e não substitui
as evidências de Activity recriada. Imagens sintéticas podem ser preparadas novamente
com --prepare-media; dados de servidor/fixtures não foram resetados.

### Recuperação do emulador para teste manual — 2026-10-31

- Servidor ADB reiniciado; `adb devices -l` confirmou `emulator-5554 device`.
- AVD isolado `Abrigo_Anjos_Test_API37`, preservando o AVD anterior.
- APK debug normal instalado com sucesso; `am start -W` retornou `Status: ok`,
  `LaunchState: COLD`. `dumpsys activity activities` confirmou MainActivity como
  `topResumedActivity`. App aberto para teste manual, sem credenciais na build.
- As evidências anteriores de 128 testes Flutter, 78 SQL e 12 Deno/HTTP permanecem
  referentes à etapa de fotos. Esta recuperação não representa validação de US5.

### Correção visual das telas públicas 01 e 02 — 2026-10-31

Referência lida diretamente do arquivo local do Open Design
`abrigo-dos-anjos-figma.html`, artboards screen-1 e screen-2. A URL local estava
indisponível; o arquivo original foi preservado.

- Entrada: composição central, logo 220 px, textos institucionais do protótipo,
  escolha de acesso e dois botões com rótulos originais. Removidos o cabeçalho,
  chamada editorial e atalhos adicionais que divergiam da referência.
- Catálogo: título Vitrine / Conheça nossos anjos, filtros compactos em linha,
  cartões em duas colunas e navegação Buscar/Favoritos/Início/Sobre.
- Navegação e filtros seguem os ViewModels e dados reais. Nenhum animal fictício
  foi inserido para reproduzir os cartões do protótipo. As imagens de teste já
  existentes no backend local continuam sendo exibidas como dados desse ambiente.
- Diferença ainda aberta: filtro Idade não implementado no contrato de consulta;
  busca permanece por nome e filtros de espécie/porte/sexo. Tipografia usa serif
  do sistema, sem incorporar uma fonte externa. Não declarar equivalência pixel a pixel.
- Widget Tests verificam composição da entrada, grade, títulos, navegação e busca
  combinada. Rótulos dos drivers de integração atualizados; jornadas nativas completas
  não reexecutadas nesta correção. Suíte no workspace: 134 PASS (inclui seis novos
  testes de Service/Repository de manejo, publicados em incremento separado).
- flutter analyze: sem problemas. APK debug gerado e instalado; entrada e vitrine
  inspecionadas visualmente no emulador. SQL novo de manejo ainda não aplicado.
