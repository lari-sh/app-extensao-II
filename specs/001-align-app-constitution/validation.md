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
