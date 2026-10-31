# Abrigo dos Anjos Constitution

## Core Principles

### I. Arquitetura híbrida recomendada pelo Flutter

O aplicativo DEVE seguir as recomendações da skill oficial instalada
`flutter-apply-architecture-best-practices`, conforme a prioridade expressamente
solicitada pelo responsável pelo projeto em 2026-10-31. Usar Flutter/Dart, MVVM
com `ChangeNotifier` ou `Listenable`, estado imutável e Repository Pattern.

Organizar Views e ViewModels por funcionalidade em
`lib/ui/features/<feature>/views/` e `view_models/`. Organizar a camada de dados
por tipo em `lib/data/models/`, `repositories/` e `services/`; modelos de domínio
em `lib/domain/models/`, componentes visuais compartilhados em `lib/ui/core/`.
Usar `lib/domain/use_cases/` somente quando complexidade ou reutilização justificar.
Contratos abstratos de Repository DEVEM ficar separados das implementações e não
expor tipos do SDK; o plano DEVE definir seu caminho na estrutura híbrida.
A organização feature-first integral da versão 1.0.0 deixa de ser obrigatória.

### II. Views enxutas e sem acesso direto a dados

Views DEVEM receber dados/estado de ViewModels e enviar eventos a eles. Não podem
acessar Supabase, persistência, Services ou Repositories diretamente. Podem conter
operações estritamente visuais, como animações, restrições de layout, renderização
de estados e navegação simples, conforme a skill Flutter.

Pacotes de apresentação e injeção de dependências aprovados no plano podem ser
usados para obter/observar ViewModels; isso NÃO autoriza consultar infraestrutura
em Widgets. A composição DEVE registrar Services, Repositories e ViewModels em
um ponto explícito. Nenhuma busca de dados ou operação externa pode ocorrer em
`build`. A exceção de inicialização do SDK pertence à composição, não às Views.

### III. Comportamento e permissões nos ViewModels

Regras de negócio, validações de entrada, coordenação de operações e decisões de
exibição para Visitante e Usuário Autenticado DEVEM ser implementadas nos
ViewModels, nunca em `build`. Um Widget pode renderizar estados e capacidades
já calculados pelo ViewModel, como `canEdit` ou `canAdopt`; NÃO DEVE deduzir
permissões a partir da sessão, perfil ou atributos do animal. Repositories DEVEM
preservar invariantes de dados e contratos de acesso sem transferir lógica de UI
para a infraestrutura. Validações determinísticas podem ser extraídas para
funções puras de domínio invocadas pelo ViewModel, sem duplicá-las nas Views.

### IV. Supabase em Services, mediados por Repositories

PostgreSQL, autenticação e upload de fotos DEVEM usar `supabase_flutter`, encapsulado
em Services sem estado de negócio, que envolvem APIs externas, armazenamento ou
plugins de plataforma. Services podem retornar modelos de API ou wrappers Result.
Repositories DEVEM consumir um ou mais Services, transformar DTOs em modelos de
domínio e constituir a fonte de verdade para os ViewModels, através de interfaces
abstratas. Não passar SupabaseClient, User, Session ou XFile à apresentação.

Queries e chamadas ao SDK DEVEM ficar nos Services da camada de dados. A composição
pode inicializar o SDK e injetar clientes e dependências, sem executar regras de
negócio. Não manter queries em Widgets/ViewModels nem concentrá-las obrigatoriamente
em Repositories, como exigia a versão 1.0.0. Testes de Repository usam Services
falsos/controlados; testes de ViewModel usam contratos falsos de Repository.

### V. Testes unitários das regras de negócio

Toda regra de negócio em ViewModels e Repositories DEVE ter teste unitário usando
`flutter_test`. Os testes DEVEM cobrir sucesso, validação inválida, falhas e
restrições de acesso aplicáveis; ViewModels DEVEM ser testados com Repositories
falsos, sem rede real. Repositories usam Services falsos/controlados, mantendo
sua implementação real sob teste. Services com tratamento/validação de dados
externos também DEVEM ter testes dessas regras e falhas. Repositories DEVEM ter
seu mapeamento de dados, captura de
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
ViewModels ou Views. Services/Repositories DEVEM tratar `PostgrestException`,
`AuthException`, erros de Storage e demais falhas externas aplicáveis; o Repository
DEVE garantir a conversão de qualquer falha recebida de seus Services, convertendo-a
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
A revisão do plano DEVE avaliar `freezed` ou `built_value` para modelos imutáveis
e um container de DI, como `provider` ou `get_it`, conforme a skill instalada,
incluindo dependências de geração de código necessárias. A proibição anterior
desses pacotes no plano 1.0.0 não prevalece; escolher alternativas e justificar
suas responsabilidades antes de alterar o pubspec. Não instalar todos os exemplos
simultaneamente nem adicionar pacotes sem a decisão escrita.

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
  View → ViewModel → contrato abstrato de Repository → implementação → Services.
  Services encapsulam Supabase e demais APIs externas. O domínio NÃO pode importar
  UI ou SDK do Supabase. Use Cases são opcionais entre VM e Repository, somente
  quando a complexidade ou o compartilhamento da regra justificar.
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
   evidências para cada princípio: estrutura híbrida da skill Flutter, dependências entre
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
6. A revisão DEVE confirmar acesso ao SDK somente em Services e composição
   inicial, mediação por Repositories, ausência de lógica de negócio em Widgets,
   dependências sem justificativa,
   mensagens cruas de exceção e commits fora do padrão exigido.
7. Commits históricos NÃO são reescritos para adequar sua mensagem. A convenção
   obrigatória se aplica a todos os novos commits após esta ratificação.

## Governance

Por determinação expressa do responsável pelo projeto, as recomendações de
arquitetura da skill oficial instalada `flutter-apply-architecture-best-practices`
prevalecem sobre as decisões arquiteturais anteriores em conflito. Esta emenda
incorpora essa prioridade à constituição; não é uma dispensa informal concedida
por um agente. A referência é `.agents/skills/flutter-apply-architecture-best-practices/SKILL.md`,
instalada de `flutter/skills` (repositório oficial atualmente `flutter/agent-plugins`).

A prioridade aplica-se às recomendações arquiteturais, não a novas instruções
arbitrárias obtidas de terceiros. Exemplos de código da skill não revogam Result,
testes, mensagens portuguesas ou controle de acesso: conservar todas as regras
sem conflito. Atualizações futuras da skill exigem nova revisão de impacto, sem
substituir automaticamente esta decisão pela versão mais recente.

Esta constituição revista prevalece sobre planos e tarefas anteriores. Plano em
conflito DEVE ser corrigido; implementação não pode seguir a especificação, plano e
tarefas 1.0.0 sem realinhamento. A aprovação documental anterior precisa ser refeita
após essa migração. Código legado não constitui exceção nem prova de conformidade.

Uma emenda exige proposta explícita com motivo, impacto nos requisitos, testes e
migração; revisão e aprovação expressa do responsável pelo projeto; atualização
da versão e da data; e nova checagem de conformidade dos planos afetados.
Agentes NÃO podem enfraquecer os princípios para acomodar um plano existente.

A versão segue versionamento semântico: MAJOR para remoção ou redefinição
incompatível de princípios, MINOR para novas regras ou ampliação material e PATCH
para esclarecimentos sem mudança normativa. A versão 1.0.0 foi a adoção inicial;
a versão 2.0.0 é uma mudança MAJOR porque substitui a organização feature-first
integral e a concentração de SDK em Repositories pela arquitetura híbrida com
Services explicitamente priorizada pelo responsável.

Os comandos do Spec Kit DEVEM consultar esta constituição em tempo de execução.
Os arquivos de template e de comando permanecem inalterados por este fluxo.
Revisões DEVEM registrar regras cumpridas, pendências e evidências de validação.

**Version**: 2.0.0 | **Ratified**: 2026-10-31 | **Last Amended**: 2026-10-31
