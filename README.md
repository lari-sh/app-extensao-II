# Abrigo dos Anjos

Aplicativo Flutter de adoção e manejo, com prioridade Android e código compartilhado
com iOS. A migração segue a constituição 2.0.0 e a skill oficial Flutter instalada.
Trabalho na branch `developer`; integração à `main` por Pull Request.

Fechamento técnico da versão de testes Android concluído para um único abrigo:
CI 41358425256 aprovada em Flutter, backend, Android e entrega, incluindo o
ajuste de navegação e a reserva de disco do emulador. Consulte o
[registro 1.0.0+1 Android](docs/releases/1.0.0-android.md), com escopo, evidências
e pendências de produção/iOS. A expansão para outros abrigos fica para depois.

## Estado implementado

A entrega de [acesso e convites da equipe](specs/005-auth-team-access/spec.md)
inclui perfis, convites e telas DESIGN-TEAM-001 aprovadas. O login oferece
**Permanecer logado** e **Esqueci a senha**, com persistência opcional de sessão
(sem salvar a senha), recuperação por e-mail e retorno ao login após a troca.
Consulte [as tarefas](specs/005-auth-team-access/tasks.md) e
[as evidências](specs/005-auth-team-access/validation.md) para distinguir testes
locais, validação Android e aprovação da CI de cada etapa.

- Início, catálogo com filtros combinados e paginação, detalhes, favoritos e sobre.
- Dados públicos do Supabase; somente animais publicados e não adotados.
- Fotos atuais entregues em bytes por função autorizada a cada requisição, sem cache.
- Favoritos persistidos localmente; tela de contato para adoção com canais oficiais,
  rascunho WhatsApp com dados públicos do animal, revisável e sem envio automático.
  Sem anexar ficha ou link compartilhável; hospedagem da ficha cancelada.
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
foram validados no emulador Android, com confirmação explícita antes do upload. Painel Kanban/lista, totais globais e comandos de situação/publicação já estão integrados. O editor de animais salvos também permite mudar situação e publicação, sem salvar o rascunho clínico pendente. A aba Calendário permite consultar mês/dia e aplicações, com tratamentos por horários fixos ou intervalos, conclusão com autoria/hora real, interrupção e correção auditada. O ambiente validado é local, sem deploy de produção. Evidências e gates remotos em [validação do calendário](specs/003-medication-calendar/validation.md).
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

Para abrir o AVD neste Windows com a configuração de janela validada:

```powershell
powershell -NoProfile -File .\scripts\open_android_emulator.ps1
```

O iniciador aplica escala Qt fixa e SwiftShader somente ao processo iniciado e
restaura as variáveis do terminal. Feche uma janela antiga antes de usá-lo para
aplicar as opções; um AVD já aberto é preservado. `-WhatIf` apenas mostra a ação.
O comando não apaga dados nem inicia sessão de usuário automaticamente.

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
Recuperação de senha e opção configurável de persistência de login continuam
planejadas, com controles desabilitados. AVD atual deste
computador: Abrigo_Anjos_Test_API37; o AVD original foi preservado.


A ficha pública segue o artboard de detalhes: foto ampla, características, história,
quadro público, coração de favoritos e contato por cópia de mensagem. O administrador
cadastra peso (kg), cor, castração, temperamento, data da última vermifugação e
aplicações de vacina (somente data e tipo públicos). Campos opcionais ausentes
aparecem como Não informado; o indicador antigo de vacinação não inventa aplicações.
Nenhum prontuário interno é usado para preencher esses campos. Contrato, tarefas
e evidências em [perfil público](specs/002-public-animal-profile/plan.md).


O [calendário de medicamentos](specs/003-medication-calendar/plan.md) está implementado
com [tarefas e evidências acompanhadas aqui](specs/003-medication-calendar/tasks.md).
Tratamentos aceitam horários fixos ou intervalos; mês e agenda diária usam o fuso
do abrigo e snapshots paginados do Supabase. A equipe edita ou interrompe séries
preservando atrasadas/realizadas; conclui aplicações devidas com autoria/hora reais
do servidor e corrige registros com justificativa, mantendo histórico original.
Respostas incertas são reconciliadas por recibo, sem duplicar comandos.

Validação local: 262 testes Flutter, 256 testes SQL, jornadas HTTP concorrentes e
Android completo aprovados. Esteira e APK confirmados na entrega do calendário;
ver [validation](specs/003-medication-calendar/validation.md).
Sem notificações, sincronização com calendários externos ou implantação em produção.
O nome de exibição de cada funcionário é configurado no provisionamento da equipe;
na ausência dele, o histórico usa identificação estável, sem expor e-mail.

A [tela de contato público](specs/004-adoption-contact/plan.md) está implementada
conforme o design aprovado, sem prévia da mensagem. WhatsApp prepara texto com
dados públicos do animal; Instagram e Facebook abrem os perfis oficiais. O usuário
revisa e envia a mensagem. Hospedagem, App Links e compartilhamento da ficha foram
cancelados e removidos das tarefas. Evidências de testes, Android e CI em
[validation](specs/004-adoption-contact/validation.md).

As telas internas oferecem Voltar visível; programação e ficha pública mantêm
as ações Fechar existentes. A navegação respeita verificação de sessão.


Os cartões administrativos do Kanban exibem o resumo das observações clínicas
cadastradas, conforme o protótipo; textos longos têm limite de linhas e tooltip.
Quando o cadastro está vazio, o cartão informa a situação ou ausência de observações,
sem inferir diagnóstico. Essas notas permanecem restritas ao manejo.
As evidências da verificação ponta a ponta de público, login, cadastro, Kanban,
medicamentos, contatos e fotos estão em
[validation](specs/001-align-app-constitution/validation.md).


Verificação ponta a ponta aprovada na
[CI 41293728173](https://github.com/lari-sh/app-extensao-II/actions/runs/41293728173):
272 testes Flutter, 256 SQL, 12 de funções HTTP e sete jornadas Android. O fluxo
nativo de fotos também passou localmente. Resta a validação iOS em Mac/Xcode.


### Equipe por convite (desenvolvimento)

Administradores verificados acessam **Equipe** no painel para convidar pessoas
como funcionário ou administrador, gerenciar convites e alterar/desativar acessos.
Cada destinatário define sua própria senha pelo e-mail e confirma o convite antes
de entrar. Funcionário continua com manejo de animais e medicações, sem gestão
de equipe. O primeiro administrador segue provisionamento técnico; não existe
cadastro público de administrador. A implantação real exige SMTP configurado.

Fluxo Android de convite/aceite com e-mail local integrado aos testes; roteiro e
resultados em `specs/005-auth-team-access/quickstart.md` e `validation.md`.
Com **Permanecer logado** desmarcado, a sessão fica somente em memória. Marcado,
a sessão é restaurada e o vínculo da equipe é revalidado no servidor. **Esqueci a
senha** abre as telas aprovadas; o e-mail não revela se a conta existe. O link
Android usa PKCE e, após salvar a senha, exige login novamente. E-mails reais
exigem configurar e validar SMTP/redirects no ambiente de destino.


### CI conferida em 2026-11-02

A [execução 41395580798](https://github.com/lari-sh/app-extensao-II/actions/runs/41395580798)
aprovou Flutter, backend, Android e entrega para o commit `62d40f4` da developer:
441 testes Flutter, 337 SQL, 19 Deno e 8 jornadas Android. O teste de login foi
ajustado para aguardar e exibir o feedback da nova tentativa antes de verificá-lo.

[APK Android de debug](https://github.com/lari-sh/app-extensao-II/actions/runs/41395580798/artifacts/13119744573)
disponível pelo prazo de retenção da CI. Evidências e limites da validação em
[validation.md](specs/005-auth-team-access/validation.md).


### Acesso da equipe — validação Android em 2026-11-02

Permanecer logado e Esqueci a senha implementados com DESIGN-TEAM-001 preservado.
A [CI 41408259965](https://github.com/lari-sh/app-extensao-II/actions/runs/41408259965)
aprovou Flutter, backend, nove jornadas Android e entrega para `ff5db07`.
Suíte local: **474 testes e 95,02% de cobertura de linhas**. Recuperação por PKCE
validada com app aberto/encerrado; senha anterior recusada, nova aceita, replay
bloqueado e login normal obrigatório. Persistência marcada/desmarcada confirmada
com force-stop/relaunch, além de revogação e logout.

[APK debug validado](https://github.com/lari-sh/app-extensao-II/actions/runs/41408259965/artifacts/13125706659)
(disponível até 2026-11-09 08:10:58 UTC). APK normal atualizado no emulador local.
[Registro completo](specs/005-auth-team-access/validation.md). Neste plano, resta
validação iOS em Mac/Xcode (T025). E-mail real depende de SMTP/redirects produtivos;
os testes de e-mail usam exclusivamente Mailpit local.


### Dados de apresentação local

Catálogo do emulador preparado com oito **exemplos fictícios** e fotos ilustrativas:
Amora, Bento, Luna, Thor, Mel, Nina, Simba e Theo. Não representam animais reais do
abrigo. As fixtures técnicas foram ocultadas do visitante e preservadas para testes,
sem apagar cadastros ou históricos. Fontes, licença, execução, limites e evidências
em [supabase/demo/README.md](supabase/demo/README.md). Este perfil não vai para
produção nem é aplicado automaticamente pela CI.


### Próxima melhoria: busca administrativa

Proposta revisada: campo fixo após os totais, por nome ou código automático único,
com filtros de espécie, sexo, cor, porte e situação; sem nova aba. A busca retorna
animais globalmente a partir de Kanban, Lista ou Calendário, inclusive sem medicação
no dia selecionado. Limpar restaura o contexto anterior. Ver
[design/management-search-proposal.html](design/management-search-proposal.html).
[Planejamento e tarefas](specs/006-management-search/plan.md) revisados; DESIGN-SEARCH-001
v2 aprovada; implementação em andamento. Códigos únicos foram adicionados ao backend
com preservação dos dados e 356 testes SQL PASS. Busca/RPC/Flutter continuam em
implementação; acompanhe [as evidências](specs/006-management-search/validation.md).
