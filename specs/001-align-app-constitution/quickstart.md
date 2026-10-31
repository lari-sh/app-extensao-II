# Quickstart de validação da adequação

**Date**: 2026-10-31.
Este roteiro combina comandos já disponíveis e cenários de aceitação das etapas
restantes. Migrations 001–006, fixtures locais, leitura de fotos e testes públicos/de
autorização já existem. Cadastro/edição já estão disponíveis; upload e manejo continuam pendentes.
Resultados executados ficam em [validation](validation.md); um cenário descrito
neste roteiro não equivale a um teste aprovado.
Contratos: [repositories](contracts/repositories.md), [backend](contracts/backend.md).

## 1. Preparar ambiente de desenvolvimento

- Flutter 3.41.1/Dart 3.11, Java 21, Android SDK API 36 (mínimo do app API 24) e celular/emulador.
- Supabase CLI compatível fixada no ambiente de desenvolvimento e no CI; Docker
  para Supabase local, Deno para testes das funções. Não é necessário instalar
  novos pacotes Flutter para executar este documento de planejamento.
- iOS exige Mac, Xcode e teste de galeria em dispositivo; não marcar como validado
  com análise ou testes feitos somente no Windows.
- Obter projeto isolado de desenvolvimento/homologação. Criar duas contas
  fictícias pelo responsável: voluntário ativo e usuário autenticado sem staff.
  Cadastro público desabilitado. Nenhuma conta ou animal real nas fixtures.

Para preparar um ambiente local descartável, executar na raiz:

```powershell
supabase start
supabase db reset
# Configurar supabase/.env.local a partir de supabase/.env.example.
# Não compartilhar a saída de status: ela contém chaves locais.
npx --yes deno@2.8.3 task --env-file=supabase/.env.local --config supabase/functions/deno.json fixtures
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

O script de fixtures disponível em `supabase/tests/fixtures/` prepara animais
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
flutter pub run build_runner build --delete-conflicting-outputs
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
flutter pub run build_runner build --delete-conflicting-outputs
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test --coverage
supabase test db
npx --yes deno@2.8.3 task --env-file=supabase/.env.local --config supabase/functions/deno.json test
flutter build apk --debug --dart-define=SUPABASE_URL=<url-de-desenvolvimento> --dart-define=SUPABASE_PUBLISHABLE_KEY=<chave-publica>
```

O deno task test executa os testes disponíveis de Deno.test e HTTP com funções
locais. Carregar as variáveis de servidor com --env-file=supabase/.env.local no
comando Deno; a task não lê esse arquivo automaticamente. Testes de banco devem
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

A execução segue `tasks.md`, na branch `developer`. Marcar tarefas somente após
implementar e comprovar seus critérios; a integração à `main` ocorre por PR.

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

## Ambiente Android instalado e verificado

Em 2026-10-31: Android Studio Rabbit 2 / 2026.2.2, command-line tools 22,
plataforma API 36, Build Tools 35.0.0/36.0.0, NDK 28.2.13676358 e CMake 3.22.1.
Arquivos oficiais de Google e Microsoft conferidos por SHA-256 antes de extrair.
Java Microsoft 21.0.13.0.2 selecionado no Flutter: JBR 25 acompanha o Studio novo,
mas Gradle 8.14 do projeto é executado no Java 21. `flutter doctor -v` aprovou a
toolchain e licenças Android; Android Studio foi aberto conforme solicitado.

A instância local de leitura de foto usa a migration 004_photo_read; migrations
005_auth_session_context foi adicionada para autenticação; migrations
futuras de escrita/finalização/manejo passam a 006/007/008. Iniciar a função:
`npx --yes supabase@2.122.0 functions serve animal-photo-read`.
A configuração verify_jwt=false é específica da leitura pública; o handler aplica
autorização por animal/foto, e o resolver RPC só pode ser invocado pelo servidor.

Teste de jornada pública em emulador local:
`flutter test integration_test/public_catalog_flow_test.dart -d emulator-5554`
com os dart-defines públicos, URL http://10.0.2.2:54321 e ALLOW_LOCAL_HTTP=true.
Preparar fixtures antes do teste. Não executar testes HTTP que ocultam/adotam as
mesmas fixtures em paralelo com a jornada Android.


## Autenticação: estado e operação

A tela inicial oferece “Área do voluntário”. O login exige conta provisionada
fora do aplicativo e membership ativa em staff_members. Não há cadastro público
nem criação de equipe na interface. Metadados do usuário não concedem permissão.
Conta autenticada sem staff continua sem acesso privado.

O Service verifica a identidade no Auth e chama access_context. A RPC retorna
user_id, is_session_current e is_staff_active; a sessão local, sozinha, não
comprova autorização. Ao retomar o app, o SessionViewModel revalida o acesso.

Durante expiração recuperável, o conteúdo privado permanece montado em memória,
mas invisível e inacessível. Só o mesmo usuário novamente autorizado pode retomar.
Saída, revogação, troca de usuário ou cancelamento descartam esse conteúdo.
Se a saída remota falhar, a interface bloqueia o acesso local imediatamente e
informa que é necessário entrar novamente para tentar encerrar a sessão remota.
Não considerar essa falha uma confirmação de revogação no servidor.

A jornada real de login/saída Android passou (T054; ver validation.md).
Para repetir, iniciar `python supabase/tests/fixtures/android_auth_control.py` no
host com fixtures prontas; executar `flutter test
integration_test/authentication_flow_test.dart -d emulator-5554` com os defines
públicos locais. Ao terminar, encerrar o controlador (Ctrl+C). O teste também cobre
não staff, reinicialização do SDK com recuperação da sessão no armazenamento nativo e
revogação de membership; não executar em
paralelo com outros testes que alterem as mesmas contas. Não é teste de reboot.
Senhas de fixtures são fornecidas somente em execução, nunca em dart-defines.


## Cadastro e edição (US3)

Migrations até 006 são necessárias para a área privada. Entrar com fixture staff,
abrir Animais do abrigo e Cadastrar animal. Preencher nome, idade, espécie, sexo e
porte; notas/cuidados ficam restritos à equipe. Novo cadastro tem situação
inicial disponível e permanece privado. Situação e publicação serão alteradas no
manejo da US5; upload pertence à US4.

O formulário só confirma após sucesso remoto. Em falha incerta, não editar nem
criar outro animal para substituir a operação: usar Verificar resultado; se o
servidor ainda não tiver resultado, Tentar salvar novamente reusa o mesmo envio.
Reautenticação recuperável mascara o formulário; saída/revogação o descartam.

Repetir a prova nativa com o controlador local ativo:
`flutter test integration_test/animal_editor_flow_test.dart -d emulator-5554`
e os mesmos defines públicos. O teste cria, edita, consulta em outra sessão e
reabre o registro; não embute senha no APK. Depois remover somente suas fixtures:
`python supabase/tests/fixtures/android_auth_control.py --cleanup-editor`.
Encerrar o controlador após terminar os testes. Nunca executar contra produção.


## Painel de fotos — teste manual Android

Com Supabase local e functions serve ativos, abrir Área do voluntário, entrar com
conta autorizada provisionada e editar um animal salvo. Rolar até Foto do animal,
selecionar JPEG/PNG até 5 MB, conferir a prévia e confirmar o envio. Cancelar a
seleção deve preservar formulário/foto. Substituição só confirma após resposta
remota. Em resultado incerto, usar Verificar envio da foto antes de escolher outra.
A recuperação após interrupção exige confirmar novamente o animal; não há envio
automático. As evidências nativas de galeria e recuperação estão em validation.md.


### Repetir os testes nativos de fotos

Preparar as duas imagens sintéticas: `python integration_test/native_picker_driver.py
--adb <caminho-adb> --serial emulator-5554 --prepare-media`. Iniciar o controlador
local de fixtures e executar `flutter test integration_test/photo_gallery_flow_test.dart
-d emulator-5554` com os defines públicos. Em outro terminal executar o driver sem
--prepare-media; ele cancela uma seleção e escolhe as duas imagens no seletor nativo.
Remover fixtures/objetos com android_auth_control.py --cleanup-editor ao terminar.

Para recuperação, usar um emulador com opções de desenvolvedor já habilitadas
e ADB conectado (o driver não altera a chave geral), instalar o APK normal configurado e executar
`python integration_test/native_photo_recovery_test.py --adb <caminho-adb>
--serial emulator-5554`. O teste ativa a opção nativa Don't keep activities na tela
de desenvolvedor, usa Browse para selecionar a fixture e exige nova inicialização
do SDK. Verifica sessão restaurada, zero jobs antes de confirmar o animal/envio e
persistência após confirmação. Restaura opções e remove a fixture no finally.
Usa somente Supabase local com ALLOW_LOCAL_FIXTURES=true e credenciais fictícias em
execução; não embutir senha/chave administrativa no APK. Encerrar o controlador
após os testes. iOS continua pendente de Mac/Xcode e dispositivo próprio.


Os drivers nativos foram validados em API 37 com sistema em inglês; os rótulos da
interface Flutter permanecem em português. Outro idioma do sistema pode exigir
adequar os seletores do driver, sem alterar o aplicativo. Sem sessão verificável
na recuperação, selecionar novamente a imagem após autenticar.

Login administrativo: as opções “Permanecer logado” e “Esqueci a senha” reproduzem
os controles do protótipo, mas ficam desabilitadas nesta versão, conforme decisão
da responsável em 2026-10-31. A sessão mantém o comportamento já implementado pelo
SDK. Esses controles não devem ser usados como evidência de recuperação de senha
ou de política configurável de persistência; ambos os fluxos seguem pendentes.

Validação local de manejo/publicação: com fixtures já provisionadas e funções
locais em execução, rode `python supabase/tests/fixtures/management_flow.py` e
`npx --yes supabase@2.122.0 test db`. O script aceita somente URL local com
ALLOW_LOCAL_FIXTURES=true, usa credenciais do arquivo ignorado em runtime e limpa
somente o animal/objetos que criou. Não aplicar a ambiente remoto ou produção.
