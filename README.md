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
animal abre sua edição. O painel de fotos já permite seleção, prévia e confirmação do envio; o backend
local tem testes de upload/substituição/limpeza. A galeria, o envio, a substituição e a recuperação após recriar a Activity
foram validados no emulador Android, com confirmação explícita antes do upload. Painel Kanban/lista, totais globais e comandos de situação/publicação já estão integrados. O editor de animais salvos também permite mudar situação e publicação, sem salvar o rascunho clínico pendente. A aba Calendário está em planejamento. O ambiente validado é local, sem deploy de produção.
A implementação antiga de demonstração foi removida. Dados de demo_animals_v1
não são importados; apenas IDs válidos de favoritos são aproveitados, inclusive
quando o animal não está disponível no catálogo.

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
evidências separadas; a CI executa gates Flutter, Supabase local e Android antes do artifact debug.
Confira o resultado da execução em Actions; iOS continua dependendo de Mac/Xcode.

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


## Entrega contínua e evidências

[Execuções no GitHub Actions](https://github.com/lari-sh/app-extensao-II/actions/workflows/flutter.yml).
Push na developer e PR para main/developer validam geração Freezed, formato,
análise, testes Flutter, PostgreSQL/RLS, funções HTTP e jornada Android. Somente
após os gates é publicado o artifact debug, sem assinatura para lojas. Nenhum
segredo de produção é necessário. Variáveis públicas DEV_SUPABASE_URL (HTTPS) e
DEV_SUPABASE_PUBLISHABLE_KEY configuram o APK; ausentes, a conexão fica indisponível.

Provisionamento de contas/equipe e configuração do Vault para limpeza agendada
ocorrem fora do cliente; instruções em [quickstart](specs/001-align-app-constitution/quickstart.md).
A demonstração clínica local foi removida; favoritos são apenas IDs locais.
Matriz SC-001 a SC-008 e limitações em [validation](specs/001-align-app-constitution/validation.md).
Calendário, recuperação de senha e opção configurável de persistência de login
continuam planejados, sem serem apresentados como funcionais. AVD atual deste
computador: Abrigo_Anjos_Test_API37; o AVD original foi preservado.


A ficha pública segue o artboard de detalhes: foto ampla, características, história,
quadro público, coração de favoritos e contato por cópia de mensagem. O administrador
cadastra peso (kg), cor, castração, temperamento, data da última vermifugação e
aplicações de vacina (somente data e tipo públicos). Campos opcionais ausentes
aparecem como Não informado; o indicador antigo de vacinação não inventa aplicações.
Nenhum prontuário interno é usado para preencher esses campos. Contrato, tarefas
e evidências em [perfil público](specs/002-public-animal-profile/plan.md).


O [planejamento do calendário de medicamentos](specs/003-medication-calendar/plan.md)
está detalhado, com [50 tarefas de implementação](specs/003-medication-calendar/tasks.md).
Prevê horários fixos e intervalos, autoria/horário real e correções auditadas,
alimentados pelos tratamentos estruturados da ficha. A funcionalidade ainda não
está implementada. A composição visual nova depende de aprovação, preservando o
protótipo; não haverá API externa de calendário nesta etapa.
