# Abrigo dos Anjos Constitution

## Core Principles

### I. Feature-first MVVM

O aplicativo DEVE usar Flutter e Dart, com arquitetura MVVM baseada em
`ChangeNotifier` ou `ValueNotifier` e Repository Pattern. Cada funcionalidade
DEVE organizar seu código em `lib/features/<feature>/ui/`, `domain/` e `data/`.
`ui/` contém Views e ViewModels; `domain/` contém entidades, contratos abstratos
de Repository e regras puras compartilhadas pela funcionalidade; `data/` contém
implementações concretas dos Repositories e mapeamento de dados externos.
A pasta `lib/core/` DEVE conter somente abstrações e recursos realmente
compartilhados, como `Result<T>`, tema e tipos de falha. A organização por
funcionalidade mantém coesas as mudanças e explícitas as fronteiras entre camadas.

### II. Widgets isolados de infraestrutura

Uma View DEVE obter dados e estado de seu ViewModel e enviar eventos a ele.
Widgets NÃO DEVEM importar, instanciar ou chamar Supabase, Repositories,
persistência ou APIs de pacotes externos diretamente. Widgets podem usar Flutter,
Dart e componentes locais de apresentação. A composição das dependências DEVE
ocorrer fora das Views, em um ponto explícito de inicialização/injeção.
Nenhum acesso a dados ou efeito externo pode ser disparado pelo método `build`.
Essa separação permite testar a apresentação sem depender de serviços externos.

### III. Comportamento e permissões nos ViewModels

Regras de negócio, validações de entrada, coordenação de operações e decisões de
exibição para Visitante e Usuário Autenticado DEVEM ser implementadas nos
ViewModels, nunca em `build`. Um Widget pode renderizar estados e capacidades
já calculados pelo ViewModel, como `canEdit` ou `canAdopt`; NÃO DEVE deduzir
permissões a partir da sessão, perfil ou atributos do animal. Repositories DEVEM
preservar invariantes de dados e contratos de acesso sem transferir lógica de UI
para a infraestrutura. Validações determinísticas podem ser extraídas para
funções puras de domínio invocadas pelo ViewModel, sem duplicá-las nas Views.

### IV. Supabase exclusivamente em Repositories

PostgreSQL, autenticação e upload de fotos dos animais DEVEM usar Supabase por
meio de `supabase_flutter`. Todo acesso ao cliente, queries, sessão de autenticação
e operações de Storage DEVE ficar exclusivamente em implementações concretas de
Repository, expostas por interfaces abstratas no domínio. Views e ViewModels
NÃO DEVEM depender do SDK ou dos tipos específicos do Supabase. O ponto de entrada
pode inicializar o SDK e injetar o cliente nos Repositories; essa composição NÃO
pode executar queries nem substituir os contratos abstratos por acessos globais.
Fakes para testes DEVEM implementar os mesmos contratos.

### V. Testes unitários das regras de negócio

Toda regra de negócio em ViewModels e Repositories DEVE ter teste unitário usando
`flutter_test`. Os testes DEVEM cobrir sucesso, validação inválida, falhas e
restrições de acesso aplicáveis; ViewModels DEVEM ser testados com Repositories
falsos, sem rede real. Repositories DEVEM ter seu mapeamento de dados, captura de
erros e produção de `Result<T>` testados por dependências controláveis. Casos de
carregamento, atualização de estado e conclusão de operações assíncronas DEVEM
ser verificados quando existirem. Nenhuma regra pode ser declarada concluída
somente com análise estática ou teste de Widget.

### VI. Caminho feliz de cada tela principal

Toda tela principal DEVE possuir ao menos um Widget Test de caminho feliz com
`flutter_test`. O teste DEVE renderizar a tela com dependências controladas,
executar uma ação relevante e verificar o resultado visível esperado, sem depender
de Supabase real. O plano DEVE listar as telas principais da entrega e associar
cada uma a seu teste. Testes de integração podem complementar, mas NÃO substituir
os testes unitários e de Widget exigidos por esta constituição.

### VII. Falhas assíncronas com Result

Operações assíncronas expostas pelos Repositories DEVEM retornar `Result<T>` com
sucesso tipado ou falha padronizada; NÃO DEVEM lançar exceções brutas para
ViewModels ou Views. As implementações DEVEM capturar `PostgrestException`,
`AuthException`, erros de Storage e demais falhas externas aplicáveis, convertendo-os
para tipos de falha independentes do SDK. Erros de rede, autorização e validação
DEVEM permanecer distinguíveis e testáveis. ViewModels DEVEM transformar essas
falhas em mensagens amigáveis em português e publicar estados de carregamento,
sucesso e erro. A UI NÃO DEVE exibir stack traces, mensagens cruas do SDK,
credenciais ou detalhes internos. Operações falhas NÃO DEVEM apresentar sucesso
nem deixar o estado de carregamento permanentemente ativo.

### VIII. Dependências com justificativa escrita

Nenhum pacote externo novo pode ser adicionado ao `pubspec.yaml` sem justificativa
escrita no `plan.md` da funcionalidade antes da alteração. A justificativa DEVE
identificar pacote, finalidade, alternativa com SDK e razão pela qual essa
alternativa não atende à necessidade. `supabase_flutter` e pacotes nativos do SDK
Flutter/Dart estão dispensados dessa justificativa; suas responsabilidades ainda
DEVEM constar no plano. A regra inclui dependências de desenvolvimento.
Dependências herdadas NÃO recebem aprovação automática: sua manutenção, remoção
ou substituição DEVE ser avaliada no plano de adequação que as afetar.

### IX. Código em inglês e interface em português

Classes DEVEM usar nomes em inglês em `PascalCase`; variáveis, membros, métodos
e funções DEVEM usar inglês em `camelCase`; arquivos Dart DEVEM usar inglês em
`snake_case`. Textos visíveis, rótulos, validações e mensagens de erro destinados
ao usuário DEVEM ser em português. Nomes próprios, como Abrigo dos Anjos e nomes
dos animais, não precisam de tradução. Entidades e códigos de erro NÃO DEVEM
vazar identificadores internos para a interface. A revisão DEVE verificar nomes
e todas as mensagens novas ou alteradas.

### X. Commits convencionais e rastreáveis

Todo novo commit DEVE seguir estritamente o formato
`tipo(escopo): descrição no imperativo [ID-DO-REQUISITO]`.
Somente `feat`, `fix`, `docs`, `style`, `refactor`, `test` e `chore` são permitidos.
O escopo DEVE identificar o módulo alterado, por exemplo `auth`, `animals`, `core`
ou `supabase`; mudanças transversais de governança usam `core`. A descrição DEVE
ser um comando no imperativo, em português. O identificador DEVE existir na
especificação ou em uma regra identificada desta constituição; identificadores
fictícios não são permitidos. Cada alteração DEVE ser rastreável a seu requisito.
Os princípios desta constituição têm identificadores estáveis `CONST-001` a
`CONST-010`, correspondentes a I a X. Exemplo válido para esta adoção:
`docs(core): estabeleça a constituição do projeto [CONST-001]`.

## Architectural Constraints

- Android é a plataforma inicial prioritária; o código compartilhado DEVE manter
  compatibilidade arquitetural com iOS. Builds iOS exigem validação própria e NÃO
  podem ser declarados aprovados por execução de testes no Windows.
- Cada funcionalidade DEVE respeitar a direção de dependências:
  View → ViewModel → contrato abstrato de Repository; a implementação concreta
  depende do contrato e encapsula Supabase. O domínio NÃO pode importar UI ou SDK
  do Supabase.
- O controle de exibição no ViewModel NÃO substitui autorização no servidor.
  PostgreSQL e Storage DEVEM aplicar políticas de acesso no Supabase; ocultar um
  botão NÃO autoriza uma operação. Chaves privilegiadas NÃO podem ser incluídas
  no app, nos commits ou nos textos de erro.
- O contrato `Result<T>` DEVE ser compartilhado, tipado e independente de Supabase.
  As implementações NÃO DEVEM retornar objetos do SDK que obriguem a UI a tratar
  detalhes externos.
- A implementação de demonstração existente ainda não comprova conformidade.
  Persistência local, acesso direto de Widgets ao store, regras em `build` e
  ausência de ViewModels DEVEM ser tratados em uma especificação de adequação.
  Esta constituição NÃO executa nem autoriza implicitamente essa refatoração.

## Development Workflow and Quality Gates

1. Toda especificação DEVE identificar requisitos verificáveis, jornadas públicas
   e autenticadas, telas principais e critérios de aceitação em português.
2. Antes de implementar, o plano DEVE passar pelo `Constitution Check`, com
   evidências para cada princípio: estrutura feature-first, dependências entre
   camadas, contratos de Repository, responsabilidades dos ViewModels, tratamento
   por `Result<T>`, regras de acesso, testes, dependências e rastreabilidade.
3. O plano DEVE repetir essa checagem após o desenho técnico. Qualquer conflito
   bloqueia o avanço até o plano ser corrigido. Tabelas de complexidade NÃO podem
   conceder dispensas de princípios obrigatórios.
4. As tarefas DEVEM incluir testes unitários de cada regra alterada e um caminho
   feliz por tela principal, mesmo se um modelo genérico disser que testes são
   opcionais. Toda tarefa DEVE apontar os arquivos e requisitos correspondentes.
5. Para concluir uma entrega, DEVEM passar `dart format --output=none
   --set-exit-if-changed lib test`, `flutter analyze` e `flutter test`, além das
   verificações de plataforma e Supabase previstas no plano. Falhas e verificações
   não executadas DEVEM ser reportadas; NÃO podem ser apresentadas como sucesso.
6. A revisão DEVE confirmar ausência de acesso direto ao Supabase fora de
   Repositories, lógica de negócio em Widgets, dependências sem justificativa,
   mensagens cruas de exceção e commits fora do padrão exigido.
7. Commits históricos NÃO são reescritos para adequar sua mensagem. A convenção
   obrigatória se aplica a todos os novos commits após esta ratificação.

## Governance

Esta constituição prevalece sobre planos, tarefas, exemplos genéricos, decisões
anteriores e conveniências de implementação. Se o plano contradisser qualquer
princípio, quem muda é o plano. A existência de código legado NÃO constitui uma
exceção nem prova de conformidade. Mudanças futuras DEVEM respeitar estes gates
e registrar explicitamente o trabalho de adequação necessário ao seu escopo.

Uma emenda exige proposta explícita com motivo, impacto nos requisitos, testes e
migração; revisão e aprovação expressa do responsável pelo projeto; atualização
da versão e da data; e nova checagem de conformidade dos planos afetados.
Agentes NÃO podem enfraquecer os princípios para acomodar um plano existente.

A versão segue versionamento semântico: MAJOR para remoção ou redefinição
incompatível de princípios, MINOR para novas regras ou ampliação material e PATCH
para esclarecimentos sem mudança normativa. Esta é a primeira adoção completa,
versão `1.0.0`; o documento anterior continha apenas o scaffold não ratificado.

Os comandos do Spec Kit DEVEM consultar esta constituição em tempo de execução.
Os arquivos de template e de comando permanecem inalterados por este fluxo.
Revisões DEVEM registrar regras cumpridas, pendências e evidências de validação.

**Version**: 1.0.0 | **Ratified**: 2026-10-31 | **Last Amended**: 2026-10-31
