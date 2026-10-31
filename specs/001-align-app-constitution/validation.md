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
