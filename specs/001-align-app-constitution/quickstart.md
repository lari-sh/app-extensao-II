# Quickstart de validação da adequação

**Date**: 2026-10-31.
Este é o roteiro que a implementação deverá tornar executável. Migrations, funções,
novos testes e jobs abaixo ainda não existem; não representam verificações já feitas.
Contratos: [repositories](contracts/repositories.md), [backend](contracts/backend.md).

## 1. Preparar ambiente de desenvolvimento

- Flutter 3.41.1/Dart 3.11, Java 17, Android SDK API 24+ e celular/emulador.
- Supabase CLI compatível fixada no ambiente de desenvolvimento e no CI; Docker
  para Supabase local, Deno para testes das funções. Não é necessário instalar
  novos pacotes Flutter para executar este documento de planejamento.
- iOS exige Mac, Xcode e teste de galeria em dispositivo; não marcar como validado
  com análise ou testes feitos somente no Windows.
- Obter projeto isolado de desenvolvimento/homologação. Criar duas contas
  fictícias pelo responsável: voluntário ativo e usuário autenticado sem staff.
  Cadastro público desabilitado. Nenhuma conta ou animal real nas fixtures.

Após implementar supabase/config.toml, migrations, testes e funções, executar na raiz:

```powershell
supabase start
supabase db reset
supabase status
deno run --allow-env --allow-net --allow-read supabase/tests/fixtures/setup.ts
supabase functions serve --env-file supabase/.env.local
```

`db reset` é apenas para o ambiente local descartável. Não executar contra banco
remoto do abrigo. Seeds locais de teste não são importação automática da demo.
`supabase/.env.local` é ignorado pelo Git, somente servidor; definir chave interna
da limpeza e variáveis exigidas pelo runtime. A configuração Auth/gateway específica
por função deve seguir contracts/backend.md, sem desligar autenticação globalmente.

T006 apenas cria o script. Só executar fixtures após as migrations T018/T019/T021
(com schema/políticas/bucket criados) e antes do gate T023, em ambiente descartável.
O script usa contexto administrativo local controlado, verifica o ambiente alvo e
não depende de save_animal, finalize ou outras RPCs das histórias futuras.

O script de fixtures a implementar em `supabase/tests/fixtures/` prepara animais
publicados, privados, adotados, fotos válidas, conta sem staff e staff ativo.
O plano não fornece senhas reais; valores de teste ficam em ambiente local/CI.

## 2. Configurar somente valores públicos no Flutter

Usar SUPABASE_URL e SUPABASE_PUBLISHABLE_KEY como dart-defines; não incluir
service_role, secret key, tokens de usuários ou credenciais do CI.
Para Android Emulator, o host local normalmente é 10.0.2.2; para celular físico,
usar host acessível na rede de desenvolvimento e configuração de debug adequada.
Não liberar HTTP sem criptografia no manifest de release. Teste de dispositivo
deve preferir HTTPS de homologação quando a rede local não estiver configurada.

```powershell
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter doctor -v
flutter devices
flutter run -d <device-id> --dart-define=SUPABASE_URL=<url-de-desenvolvimento> --dart-define=SUPABASE_PUBLISHABLE_KEY=<chave-publica>
```

Se flutter não estiver no PATH deste computador, usar o executável instalado:
`C:\Users\Larissa\.puro\envs\stable\flutter\bin\flutter.bat`.
Sem configuração, esperar mensagem de serviço indisponível e acesso de demonstração
inexistente; não pode haver login staff ou gravações locais silenciosas de fallback.

## 3. Gates automatizados

```powershell
dart run build_runner build --delete-conflicting-outputs
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test --coverage
supabase test db
deno task --config supabase/functions/deno.json test
flutter build apk --debug --dart-define=SUPABASE_URL=<url-de-desenvolvimento> --dart-define=SUPABASE_PUBLISHABLE_KEY=<chave-publica>
```

O deno task test será definido para Deno.test unitário e testes HTTP com funções
locais, usando variáveis de ambiente do projeto de teste. Testes de banco devem
rodar como papéis de cliente e com JWTs reais quando envolver Auth/Storage; somente
SQL executado com service_role não comprova acesso anônimo.

Rodar também `flutter test integration_test/authorized_animal_flow_test.dart -d
<device-id>` com os mesmos dart-defines e credenciais de teste fornecidas por
configuração de integração exclusiva, nunca embutidas na build distribuída.
Não copiar senhas de teste para documentos versionados.

**Resultados exigidos**:

- Unitários de todas as regras de VMs/Repositories e tratamentos/validações de
  Services, inclusive falhas e autorização; testes de Services usam transportes
  controlados e os de Repository usam Services falsos.
- Oito arquivos de Widget Test da matriz do plano, mais upload no editor.
- Teste de arquitetura híbrida, Provider somente para VMs nas Views e revisão
  manual das fronteiras, mensagens e build. Regenerar .freezed.dart versionados e
  confirmar ausência de diferenças; geração não substitui análise/testes.
- pgTAP com RLS/grants, RPCs, atomicidade, idempotência e privacidade.
- Deno/HTTP com byte-proxy sem cache, validação de imagem e reconciliação/cleanup.
- Build Android e jornada em dispositivo. iOS registrado separadamente em Mac.

## 4. Jornadas manuais reproduzíveis

1. **Visitante**: abrir início/catálogo, combinar filtros, abrir detalhes, copiar
   interesse de animal disponível, marcar favorito e reiniciar. Ver favoritos
   permanecerem; ocultos/adotados não reaparecem nem expõem notas clínicas.
2. **Login**: testar campo inválido e senha errada (mensagem genérica); entrar com
   conta sem staff (sem manejo); entrar com staff ativo e reiniciar (validação de
   sessão antes de conteúdo privado). Expirar a sessão durante edição: editor
   continua montado, mas todo conteúdo privado fica oculto e bloqueado. Reautenticar
   o mesmo usuário autorizado restaura o rascunho; outro usuário, revogação,
   fechamento, cancelamento ou logout o descartam. Sair e pressionar Voltar:
   sem retorno privado.
3. **Cadastro**: salvar animal sem publicar; reabrir em outra sessão autorizada;
   editar notas/cuidados; confirmar que visitante não consegue ler esses campos.
   Simular falha, repetir com a mesma operação e comprovar ausência de duplicação.
4. **Fotos**: selecionar JPEG/PNG válido até 5 MB, publicar animal e verificar
   imagem; substituir com falha e confirmar foto anterior intacta. Cancelar galeria
   e negar sua permissão: mensagem portuguesa, loading encerrado, formulário/foto
   preservados e nenhum upload. Testar arquivo de 5 MB exatos com overhead multipart
   permitido, arquivo de 5 MB + 1 byte e corpo maior que 5.308.416 bytes. Testar
   normalização cuja primeira saída excede 5 MB: ajustar e concluir, preservando
   proporção sem invalidar a entrada por esse aumento. Interromper atividade Android e validar
   recuperação sem upload automático nem associação a outro animal.
5. **Manejo**: alternar Kanban/lista, mudar status e publicação. Conferir totais
   com mais de 50 animais de teste e atualização em outra sessão, sem contar só a página.
6. **Acesso direto**: usar os testes HTTP do backend para consultar notas/fotos com
   anon, não staff e JWT de staff revogado; todas as tentativas restritas falham.
   Despublicar/adotar e fazer novo pedido da imagem: negação sem redirect/cache.
7. **Consistência**: interromper resposta após upload/commit, reconciliar por job,
   rodar dois uploads e depois limpeza; foto atual existe, pendências são rastreadas.
8. **Recuperação**: desconectar rede durante leitura/escrita/login/envio; loading
   termina, mensagem em português e nenhuma confirmação falsa. Configuração vazia
   não carrega animais demo como produção.

## 5. Evidências e entrega

Registrar por gate: comando, ambiente, commit, resultado, requisitos cobertos e
pendências. Não registrar tokens/segredos ou dados reais. SC-001 a SC-008 devem
apontar evidência verificável, não apenas este plano.

Na implementação, ampliar `.github/workflows/flutter.yml` com banco local e
funções; manter geração Freezed/análise/testes/APK e upload do artifact debug. Os jobs não recebem
segredos de produção e a ausência de integração backend não é aceita como sucesso.
Assinatura release, publicação em lojas e criação de equipe no app estão fora do escopo.

Este planejamento termina antes de tasks e implementação. Próximo comando:
`/speckit-tasks`.

## Versões fixadas durante T003

- Supabase CLI: `npx --yes supabase@2.122.0 <comando>`.
- Deno: `npx --yes deno@2.8.3 <comando>`.
- Docker Desktop / Engine: 29.2.0 neste Windows; engine Linux iniciado para testes.
- Não substituir versões por latest no CI. A CLI usa config.toml local; nenhum
  projeto remoto foi vinculado. Autoinscrição global Auth desabilitada e seed vazio. O provider de e-mail fica
  habilitado para login de contas previamente provisionadas: na CLI 2.122.0,
  auth.email.enable_signup controla GOTRUE_EXTERNAL_EMAIL_ENABLED; o bloqueio
  de novos cadastros é auth.enable_signup=false.
- .env.example documenta apenas variáveis de servidor; nenhum segredo vai a dart-defines.
