# Abrigo dos Anjos

Aplicativo Flutter de adoção e manejo, com prioridade Android e código compartilhado
com iOS. A migração segue a constituição 2.0.0 e a skill oficial Flutter instalada.
Trabalho na branch `developer`; integração à `main` por Pull Request.

## Estado implementado

- Início, catálogo com filtros combinados e paginação, detalhes, favoritos e sobre.
- Dados públicos do Supabase; somente animais publicados e não adotados.
- Fotos atuais entregues em bytes por função autorizada a cada requisição, sem cache.
- Favoritos persistidos localmente; mensagem de interesse copiada, sem envio de pedido.
- MVVM com ChangeNotifier, estados Freezed, Repositories abstratos, Services e Provider.
- Falhas tipadas por Result e mensagens em português; logo e paleta vermelha/marrom.
- Login de contas provisionadas, verificação remota de sessão/equipe e saída,
  validados no Android com Supabase local.
- Área privada com listagem paginada, cadastro e edição de animais, notas internas,
  vacinação/castração e cuidados; persistência atômica no Supabase e reconciliação
  após falha de resposta. Novos animais ficam disponíveis e privados por padrão.

Fluxo: **Área do voluntário → Animais do abrigo → Cadastrar animal**; tocar em um
animal abre sua edição. Upload de fotos, publicação e painel por situação continuam
nas próximas histórias. O ambiente validado é local, sem deploy de produção.
A demonstração antiga está isolada em `lib/legacy_demo.dart` para caracterização;
não é a entrada do aplicativo e será removida conforme T100.

## Executar

Requer Flutter 3.41.1/Dart 3.11, Java 21 e SDK Android. Configurar somente URL e
chave pública do projeto de desenvolvimento. Sem configuração, o app exibe um
estado de serviço não configurado, sem dados de demonstração como fallback.

```sh
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run -d <dispositivo> --dart-define=SUPABASE_URL=<url> --dart-define=SUPABASE_PUBLISHABLE_KEY=<chave-publica>
```

Para Supabase local no Android Emulator: URL `http://10.0.2.2:54321` e
`--dart-define=ALLOW_LOCAL_HTTP=true` apenas em debug. O manifesto de debug permite
esse tráfego local; a configuração de release exige HTTPS.
Não incluir service_role, senha de fixture ou qualquer segredo de servidor na build.

O roteiro completo de banco local, fixtures, funções, versões e testes está em
[quickstart](specs/001-align-app-constitution/quickstart.md). Evidências e pendências
em [validation](specs/001-align-app-constitution/validation.md).

## Estrutura

- `lib/ui/features/<feature>/{views,view_models}`: apresentação por funcionalidade.
- `lib/ui/core`: tema, componentes e apresentação reutilizável.
- `lib/domain/{models,repositories}`: domínio e contratos sem SDK.
- `lib/data/{models,services,repositories}`: DTOs, APIs/plugins e implementações.
- `lib/app`: inicialização, composição e rotas; `lib/utils`: Result e falhas.
- `supabase`: migrations, funções e testes de autorização.
- `test`: unitários e Widgets; `integration_test`: jornadas em dispositivo.

Views recebem ViewModels. Somente Services fazem queries ou chamam plugins;
Repositories transformam DTOs e mantêm a fonte de verdade. A composição inicial
pode inicializar e injetar o SDK. Use Cases são opcionais para complexidade real.

## Verificar

```sh
flutter pub run build_runner build --delete-conflicting-outputs
dart format --output=none --set-exit-if-changed lib test integration_test
flutter analyze
flutter test --coverage
npx --yes supabase@2.122.0 test db
flutter build apk --debug
```

Gerar modelos pelo comando Flutter mantém o contexto correto do SDK no Puro deste
Windows. O APK debug fica em `build/app/outputs/flutter-apk/app-debug.apk`.
Um APK sem dart-defines não conecta automaticamente a um backend. Não é uma versão
assinada para publicação. Testes de Flutter, SQL, funções HTTP e plataforma têm
evidências separadas; a CI será ampliada em T103. iOS depende de Mac/Xcode.

## Ambiente Android deste computador

SDK em `C:\Users\Larissa\AppData\Local\Android\Sdk` e Android Studio em
`C:\Users\Larissa\AppData\Local\Programs\android-studio`.
Java 21 selecionado no Flutter para compatibilidade com Gradle 8.14.
Plataforma Android 36, Build Tools 35/36 e NDK 28.2.13676358 instalados.
As novas variáveis de ambiente são lidas por novos terminais; reinicie o terminal
se flutter/adb ainda não aparecerem no PATH.

## Planejamento e Spec Kit

Constituição em `.specify/memory/constitution.md`; especificação, plano e tarefas
em `specs/001-align-app-constitution`. O checklist de requisitos revisados não
significa que a implementação inteira está concluída. Verificar marcações das tarefas.
As skills estão versionadas em `.agents/skills/`; Specify CLI 1.2.5 já configurado.
Não reinicializar o Spec Kit nem substituir a constituição por um template.

Referência visual: protótipo `abrigo-dos-anjos-figma.html`, com as cores do logo.
O editor/canvas do protótipo não faz parte do aplicativo.
