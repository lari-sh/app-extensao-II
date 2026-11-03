# APK Android para avaliação na nuvem

Requisito: 006-FR-015. Estado em 03/11/2026: **preparação local validada;
projeto remoto, implantação e APK conectado ainda pendentes**. A responsável
informou que ainda não tem projeto e está acessando sua conta Supabase.
O APK local anterior usa loopback e não serve para avaliação independente.

## Conta e projeto de avaliação

Entrar em https://supabase.com/dashboard com a conta da responsável e criar um
projeto de avaliação, separado do ambiente local. Conferir organização, região e
plano antes de criar; não contratar plano pago. Guardar a senha do banco em
gerenciador de senhas, fora de chats, Git e configuração Flutter.
Registrar aqui URL pública, referência do projeto e migrations aplicadas somente
depois de realmente provisionar. Nunca registrar senha, token de gestão ou chave
administrativa. O projeto pode conter apenas os exemplos fictícios autorizados;
não copiar usuários, sessões, dados pessoais ou backups do ambiente local.

## Implantação pendente

Com Supabase CLI autenticado e o projeto explicitamente identificado:

```powershell
npx --yes supabase@2.122.0 link --project-ref <referencia-do-projeto>
npx --yes supabase@2.122.0 db push --dry-run
npx --yes supabase@2.122.0 db push
npx --yes supabase@2.122.0 migration list
npx --yes supabase@2.122.0 functions deploy animal-photo-read --project-ref <referencia-do-projeto>
npx --yes supabase@2.122.0 functions deploy animal-photo-upload --project-ref <referencia-do-projeto>
npx --yes supabase@2.122.0 functions deploy animal-photo-cleanup --project-ref <referencia-do-projeto>
npx --yes supabase@2.122.0 functions deploy team-invitation --project-ref <referencia-do-projeto>
```

Revisar as 21 migrations existentes em ordem; não usar reset, seed ou scripts de
fixtures locais no projeto remoto. Conferir JWT/autorizações dos handlers e o
arquivo WASM de upload incluído na implantação. Confirmar que o bucket de fotos
continua privado. Configurar PHOTO_CLEANUP_SECRET exclusivo no servidor; não
reaproveitar credenciais locais nem colocar o segredo em dart-defines. As Functions
atuais utilizam variáveis SUPABASE_* de servidor, nunca enviadas ao aplicativo.
Operações remotas permanecem pendentes até o projeto estar acessível.

Auth: conferir políticas de cadastro e autorização, recuperação e a lista exata
de redirect URLs `br.org.abrigodosanjos.app://auth/invite` e
`br.org.abrigodosanjos.app://auth/recovery`. Não assumir que o email padrão
entrega convites/recuperações a qualquer destinatário: conferir as restrições do
provedor e configurar SMTP quando necessário. Não enviar mensagens ao professor
automaticamente. Provisionar primeiro administrador pelo fluxo de bootstrap
existente, depois acesso de funcionário de avaliação, com senha exclusiva e
permissões reais. Nunca tornar todos os usuários administradores.

## Configuração pública e build

Criar `.env.cloud.json` na raiz (ignorado pelo Git). Somente estas duas entradas:

```json
{
  "SUPABASE_URL": "https://<referencia-de-20-caracteres>.supabase.co",
  "SUPABASE_PUBLISHABLE_KEY": "sb_publishable_<chave-publica-do-projeto>"
}
```

Os valores acima são placeholders, não uma configuração utilizável.
Não adicionar senha de avaliação, service_role, sb_secret, token de gestão,
ALLOW_LOCAL_HTTP ou Flutter Driver. A chave pública não substitui as políticas RLS.
O helper também aceita anon JWT legado com role anon e referência do mesmo projeto.

```powershell
python scripts/build_cloud_apk.py --config .env.cloud.json --check-only
python scripts/build_cloud_apk.py --config .env.cloud.json --flutter <caminho-do-flutter.bat>
```

Usar SDK Flutter 3.41.1, JDK/Android SDK configurados e dependências do lockfile
previamente instaladas. O helper não implanta recursos nem popula banco. Confere
HTTPS e acesso anônimo às colunas públicas atuais antes de compilar. Catálogo vazio
pode passar nessa verificação: isso não comprova dados, fotos ou login prontos.
Build usa `--release --target=lib/main.dart`, sem instalação automática no celular.
O Gradle atual assina release com a chave de teste Android; essa entrega é para
instalação manual de avaliação, não para publicação na Play Store.

Saída após build bem-sucedido:

- `.tools/apk/cloud/abrigo-dos-anjos-avaliacao.apk` — arquivo a compartilhar.
- `.tools/apk/cloud/validation.json` — hash, tamanho, URL pública e validações
  remotas/no celular inicialmente pendentes, mesmo quando o build termina.
- `.tools/apk/cloud/build.log` — log local.

Nenhum desses arquivos existe como entrega concluída nesta preparação.

## Aceitação antes de enviar

1. Conferir migrations, Functions, Storage privado e RLS. Anônimo não pode acessar
   informações clínicas, equipe ou medicações nem gravar dados. Funcionário não
   pode administrar equipe; administrador mantém suas capacidades existentes.
2. Criar exemplos fictícios com fotos ilustrativas pelos endpoints normais;
   conferir leitura pública das fotos e correspondência nome/imagem.
3. Instalar APK normal e remover ADB reverse. Validar catálogo, ficha e fotos,
   login de avaliação, busca nos modos, cadastro/edição, upload e agenda usando
   internet no celular. O computador não pode servir nenhuma dependência do app.
4. Conferir certificado/assinatura, revisão, tamanho e SHA-256 do arquivo final.
   Registrar resultados reais aqui e em validation.md antes de marcar T062.
5. Entregar APK e instruções de acesso por canais separados; não colocar senha
   em commits, documentação pública ou dentro do APK.

## Evidências desta preparação

- 11 testes Python de configuração, chave privilegiada, projeto divergente,
  transporte, resposta, redirect, falha de build e empacotamento: PASS local.
- MCP oficial Dart/Flutter `run_tests`: 3 testes em
  `test/utils/app_config_test.dart` PASS; `analyze_files`: No errors.
- Teste remoto de schema/Functions/RLS: não executado; projeto inexistente.
- APK na nuvem e validação física independente: não executados.
- A etapa Python foi adicionada ao workflow existente; resultado remoto ainda
  não confirmado para esta alteração.

Referências oficiais: [ambientes e migrations](https://supabase.com/docs/guides/deployment/managing-environments),
[implantação de Functions](https://supabase.com/docs/guides/functions/deploy) e
[chaves públicas e de servidor](https://supabase.com/docs/guides/getting-started/api-keys).
