# Feature Specification: Adequação do Abrigo dos Anjos à constituição

**Feature Branch**: `developer` (criada a pedido; integração à main por PR)
**Feature Directory**: `specs/001-align-app-constitution`
**Created**: 2026-10-31
**Status**: Em implementação; fundação e jornada pública concluídas, demais histórias pendentes
**Input**: User description: "Adeque o app Abrigo dos Anjos à constituição: arquitetura Flutter com MVVM, ViewModels, Repositories e Services, backend Supabase, autenticação, upload de fotos e testes obrigatórios; prevalecem as recomendações da skill flutter-apply-architecture-best-practices, conforme constituição 2.0.0."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Conhecer os animais sem criar conta (Priority: P1)

Como visitante, quero pesquisar animais e conhecer suas características públicas,
sem fornecer credenciais, para decidir se tenho interesse em uma adoção.

**Why this priority**: Preserva a finalidade pública do app durante a adequação.
**Independent Test**: Com animais de teste publicados e sem sessão ativa, realizar
busca, aplicar filtros, abrir detalhes e alternar favoritos.

**Acceptance Scenarios**:

1. **Given** um visitante sem sessão, **When** abre o catálogo, **Then** vê somente
   animais publicados não adotados, suas fotos públicas e seus estados de disponibilidade.
2. **Given** animais publicados, **When** combina nome, espécie, porte e sexo,
   **Then** vê somente os resultados que atendem a todos os filtros e pode limpá-los.
3. **Given** um animal publicado, **When** abre seus detalhes, **Then** vê nome,
   características, descrição pública e indicação de disponibilidade, sem notas
   clínicas internas, identificadores de usuários ou metadados privados.
4. **Given** um visitante, **When** marca um favorito e reinicia o app no mesmo
   dispositivo, **Then** o favorito permanece sem exigir conta.
5. **Given** zero resultados ou nenhum animal publicado, **When** abre a listagem,
   **Then** vê um estado vazio em português e pode alterar filtros ou atualizar.

### User Story 2 - Entrar e sair com acesso autorizado (Priority: P1)

Como voluntário autorizado, quero entrar com minhas credenciais e encerrar minha
sessão, para acessar ferramentas de manejo sem expor dados internos a visitantes.

**Why this priority**: Nenhuma escrita real pode depender do acesso de demonstração.
**Independent Test**: Usar uma conta de teste autorizada, uma conta autenticada sem
autorização e credenciais inválidas; verificar login, restauração e logout.

**Acceptance Scenarios**:

1. **Given** credenciais válidas de voluntário autorizado, **When** confirma o login,
   **Then** acessa o painel de manejo e o app deixa explícito que a sessão está ativa.
2. **Given** campos vazios, e-mail inválido ou senha incorreta, **When** tenta entrar,
   **Then** recebe mensagem amigável e permanece fora do painel, sem revelar se uma conta existe.
3. **Given** sessão válida, **When** reabre o aplicativo, **Then** mantém o acesso
   autorizado após a verificação da sessão, sem mostrar conteúdo privado antes dessa verificação.
4. **Given** sessão expirada ou autorização revogada, **When** tenta uma ação restrita,
   **Then** a ação é negada, o estado privado deixa de ser acessível e o app solicita novo acesso.
5. **Given** sessão ativa, **When** sai, **Then** volta ao fluxo público, limpa os
   dados privados de memória e não retorna ao painel com o botão Voltar.
6. **Given** conta autenticada sem autorização de voluntário, **When** tenta abrir
   o painel ou alterar dados, **Then** não recebe dados internos nem permissão de escrita.
7. **Given** sessão expirada durante edição, **When** reautentica o mesmo usuário
   e confirma sua autorização atual, **Then** recupera o rascunho somente em memória;
   antes disso, a tela permanece aberta, integralmente oculta e sem ações privadas.
   Logout, revogação, outro usuário, fechamento ou cancelamento descartam o rascunho.

### User Story 3 - Cadastrar e manter animais na nuvem (Priority: P1)

Como voluntário autorizado, quero cadastrar e editar animais e seus registros de
manejo, para que a equipe trabalhe com dados persistentes compartilhados.

**Why this priority**: Substitui os cadastros locais de demonstração por registros úteis à equipe.
**Independent Test**: Cadastrar um animal, reiniciar o app, ler em outro dispositivo
com uma conta autorizada e conferir a separação entre dados internos e públicos.

**Acceptance Scenarios**:

1. **Given** uma sessão autorizada, **When** informa os campos obrigatórios válidos
   e salva, **Then** o cadastro recebe identificador único e confirmação somente após
   persistência; reabrir ou atualizar em outro dispositivo mantém os dados salvos.
2. **Given** dados obrigatórios ausentes, **When** tenta salvar, **Then** os campos
   são indicados em português, os valores preenchidos permanecem e nada é gravado.
3. **Given** um animal existente, **When** altera identificação, descrição pública,
   situação clínica ou registros de cuidados e salva, **Then** os dados atualizados
   são exibidos sem criar um segundo animal.
4. **Given** dados clínicos internos e descrição pública distintos, **When** um
   visitante consulta o animal, **Then** apenas a descrição pública é disponibilizada.
5. **Given** toque repetido em Salvar durante uma gravação, **When** a operação termina,
   **Then** existe um único cadastro correspondente àquela submissão.
6. **Given** falha na gravação, **When** a tentativa termina, **Then** o formulário
   preserva as alterações, informa a falha e permite tentar de novo sem indicar sucesso.

### User Story 4 - Adicionar e substituir a foto do animal (Priority: P2)

Como voluntário autorizado, quero selecionar uma foto da galeria e associá-la ao
animal para facilitar seu reconhecimento e sua divulgação.

**Why this priority**: Fotos reais tornam o catálogo útil e substituem as ilustrações provisórias.
**Independent Test**: Associar e substituir uma imagem válida em animal existente;
reabrir o catálogo e simular cancelamento, arquivo inválido e interrupção.

**Acceptance Scenarios**:

1. **Given** um animal salvo e uma imagem válida selecionada, **When** confirma o envio,
   **Then** acompanha o estado do envio e vê a nova foto após conclusão confirmada.
2. **Given** foto já associada, **When** um novo envio falha ou é cancelado,
   **Then** a foto anterior permanece associada e a falha não altera o cadastro.
3. **Given** arquivo que não é JPEG/PNG ou ultrapassa 5 MB, **When** tenta enviá-lo,
   **Then** recebe explicação em português e o arquivo não é publicado.
4. **Given** imagem enviada mas associação ao animal não concluída, **When** ocorre
   falha, **Then** o app não declara sucesso e o arquivo sem associação é removido
   ou fica registrado para limpeza, sem ser anunciado como foto atual.
5. **Given** visitante ou usuário sem autorização, **When** tenta enviar, substituir
   ou consultar foto de cadastro não publicado, **Then** a operação é negada também fora da interface.
6. **Given** permissão de galeria negada, **When** tenta selecionar uma foto,
   **Then** recebe mensagem em português, o carregamento termina, formulário e foto
   anterior permanecem e nenhum upload é iniciado.
7. **Given** JPEG/PNG válido de até 5 MB, **When** a primeira normalização aumenta
   seu tamanho além do limite, **Then** o processamento ajusta compressão/resolução
   preservando a proporção para gravar uma versão compatível; esse aumento isolado
   não torna inválido o arquivo selecionado.

### User Story 5 - Acompanhar o manejo e a publicação (Priority: P2)

Como voluntário autorizado, quero organizar os animais por situação e decidir quais
cadastros estão publicados, para manter o catálogo e a equipe atualizados.

**Why this priority**: Preserva o Kanban do protótipo e controla a exposição dos dados.
**Independent Test**: Mover um animal entre situações, publicar/despublicar e
conferir o resultado após atualização em outra sessão.

**Acceptance Scenarios**:

1. **Given** animais em situações diferentes, **When** abre o painel, **Then** os
   totais e colunas refletem os registros reais, inclusive quando não há animais.
2. **Given** animal disponível, **When** altera para tratamento, quarentena ou adotado,
   **Then** a alteração persistida atualiza cartões, contadores e disponibilidade pública.
3. **Given** um animal adotado ou não publicado, **When** um visitante atualiza o
   catálogo ou tenta abrir seus detalhes, **Then** ele não aparece como disponível
   nem fornece os detalhes do cadastro oculto.
4. **Given** falha ao alterar situação ou publicação, **When** a operação termina,
   **Then** a tela mantém ou restaura os valores confirmados e informa a falha.
5. **Given** alterações de outra sessão, **When** atualiza explicitamente catálogo
   ou painel, **Then** vê os últimos dados confirmados; atualização em tempo real não é exigida.

### User Story 6 - Usar o app com falhas previsíveis e sem regressões (Priority: P2)

Como usuário, quero mensagens compreensíveis e caminhos recuperáveis quando uma
operação falha, mantendo a experiência visual e os fluxos conhecidos.

**Why this priority**: A adequação não pode transformar falhas externas em telas travadas.
**Independent Test**: Simular falhas de conexão, autorização, leitura e envio em
cada jornada; executar a matriz de validação das telas principais.

**Acceptance Scenarios**:

1. **Given** uma operação que falha, **When** recebe sua conclusão, **Then** o
   carregamento termina, há mensagem em português e uma ação possível de recuperação.
2. **Given** falha de acesso a dados, **When** a mensagem é exibida, **Then** não
   contém credenciais, rastros internos ou texto técnico cru do provedor.
3. **Given** o app adequado, **When** percorre início, catálogo, favoritos, detalhes,
   sobre, login, painel e formulário, **Then** os fluxos permanecem navegáveis e
   preservam o logo e a identidade vermelha/marrom.

### Edge Cases

- Sessão expira enquanto o formulário está aberto: negar escrita, manter a tela
  aberta mas integralmente oculta durante a reautenticação e preservar rascunho
  apenas em memória. Retomar só para o mesmo usuário novamente autorizado; logout,
  revogação, outro usuário, fechamento ou cancelamento descartam o rascunho.
  Não gravar dados privados em armazenamento local não autorizado.
- Aplicativo sem rede: informar indisponibilidade e permitir repetição; não simular
  sincronização nem confirmar gravações pendentes como concluídas.
- Favorito cujo animal foi adotado, ocultado ou removido: não recuperar conteúdo
  privado; omitir o cartão indisponível sem impedir uso dos demais favoritos.
- Leitura de animal inexistente: exibir estado de não encontrado e retorno ao catálogo.
- Cancelamento da galeria ou acesso negado: preservar cadastro e foto anterior,
  sem tratar cancelamento voluntário como sucesso de envio.
- Foto indisponível ou corrompida: usar imagem substituta e manter detalhes navegáveis.
- Toque repetido durante login, gravação, mudança de estado ou envio: impedir
  submissões simultâneas da mesma ação.
- Edições simultâneas: ao atualizar, apresentar o último estado confirmado; neste
  escopo, a última gravação confirmada prevalece, sem promessa de mesclagem automática.
- Ambiente sem configuração de serviço: informar que o serviço está indisponível;
  nunca trocar silenciosamente por dados fictícios ou liberar acesso de demonstração.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: O sistema DEVE oferecer início, catálogo, filtros combináveis de nome,
  espécie, porte e sexo, favoritos locais, detalhes públicos e sobre sem exigir login. Aceite: US1.
- **FR-002**: O catálogo público DEVE listar apenas animais publicados não adotados;
  animais em tratamento ou quarentena publicados DEVEM informar indisponibilidade
  para adoção. Cadastros ocultos e adotados NÃO DEVEM fornecer detalhes públicos. Aceite: US1/US5.
- **FR-003**: O sistema DEVE separar descrição e características públicas de notas
  clínicas, histórico interno e dados de usuários; visitantes NÃO DEVEM obter os
  dados internos por nenhum caminho de leitura. Aceite: US1.3, US3.4.
- **FR-004**: Voluntários previamente autorizados DEVEM entrar por e-mail e senha,
  restaurar sessão válida e sair; o app NÃO DEVE oferecer cadastro público de
  voluntários nem o bypass de demonstração. Aceite: US2.
- **FR-005**: A autorização de manejo DEVE ser validada além da existência de uma
  sessão; visitantes e contas autenticadas sem autorização NÃO PODEM ler dados
  internos, cadastrar, editar, mudar situação/publicação ou enviar fotos. Aceite: US2.6/US4.5.
- **FR-006**: Sessão inválida, expirada ou revogada DEVE impedir ações restritas;
  logout DEVE limpar o estado privado e impedir retorno indevido por navegação. Aceite: US2.3–5.
- **FR-007**: O cadastro DEVE exigir nome, espécie (cachorro/gato), sexo (fêmea/macho),
  porte (pequeno/médio/grande), idade aproximada e situação. Nome e idade DEVEM
  aceitar de 1 a 80 caracteres após remoção de espaços externos. Aceite: US3.1–2.
- **FR-008**: O animal DEVE permitir descrição pública, observações internas,
  indicação de vacinação/castração e registros separados de vacinação,
  vermifugação e medicações. Descrições DEVEM limitar-se a 3.000 caracteres cada;
  registros de cuidados DEVEM ter descrição não vazia de até 1.000 caracteres. Aceite: US3.3–4.
- **FR-009**: Cadastro e edição DEVEM persistir na nuvem e manter identificador
  estável; outra sessão autorizada DEVE recuperar o mesmo registro após atualização. Aceite: US3.1/3.
- **FR-010**: O sistema DEVE oferecer situações disponível, em tratamento,
  quarentena e adotado, com contadores derivados dos registros confirmados. Aceite: US5.1–2.
- **FR-011**: A publicação DEVE ser controlada por voluntário autorizado e ser
  independente da situação clínica; cadastro novo DEVE começar não publicado. Aceite: US5.3.
- **FR-012**: O painel DEVE preservar visualizações Kanban e lista, incluindo
  alteração de situação por menu acessível sem arraste obrigatório. Aceite: US5.
- **FR-013**: O sistema DEVE permitir associar e substituir uma foto principal por
  animal salvo, selecionada da galeria, com JPEG/PNG até 5 MB (5.242.880 bytes);
  o limite se refere ao arquivo selecionado, sem contar delimitadores/campos de
  transporte. Conteúdo inválido DEVE ser rejeitado além de sua extensão nominal.
  A normalização pode ajustar compressão/resolução preservando proporção; não pode
  rejeitar entrada válida apenas porque a primeira saída aumentou. Aceite: US4.1–3/7.
- **FR-014**: Envios DEVEM distinguir processamento, sucesso, falha e cancelamento;
  uma substituição malsucedida NÃO DEVE eliminar a foto anterior. Arquivos sem
  associação DEVEM ser removidos ou rastreados para limpeza. Aceite: US4.2/4.
- **FR-015**: Fotos públicas só DEVEM permitir leitura de animais publicados não
  adotados; acesso à foto de cadastro oculto DEVE exigir autorização, inclusive por
  endereço direto, com validade máxima de 60 segundos para acessos temporários já emitidos;
  novos acessos DEVEM ser negados imediatamente após a retirada de publicação. Aceite: US4.5/US5.3.
- **FR-016**: Toda operação assíncrona DEVE mostrar carregamento e conclusão,
  impedir submissões duplicadas e permitir recuperação apropriada após falha.
  Falha de gravação NÃO DEVE perder o formulário nem produzir confirmação falsa. Aceite: US3.5–6/US6.
- **FR-017**: Falhas DEVEM ser apresentadas em português sem exceções cruas,
  credenciais ou detalhes internos. Validação de entrada DEVE ocorrer antes de
  submeter alterações inválidas. Aceite: US2.2/US3.2/US6.1–2.
- **FR-018**: O fluxo de interesse em adoção DEVE ser oferecido somente para
  animais disponíveis e publicados. Enquanto não existir canal oficial configurado,
  DEVE permitir apenas copiar a mensagem, avisando que nada foi enviado. Aceite:
  animal disponível mostra ação; demais situações não permitem iniciar adoção.
- **FR-019**: O app DEVE manter o logo, a paleta vermelha/marrom, textos em português
  e navegação utilizável em Android; compatibilidade iOS DEVE ser preservada sem
  declarar uma compilação iOS não executada. Aceite: US6.3 e revisão de plataforma.
- **FR-020**: Os animais fictícios e registros locais de demonstração NÃO DEVEM
  ser publicados nem importados automaticamente para a nuvem. Aceite: instalação
  sobre a versão atual não cria animais no serviço e remove o bypass administrativo.
- **FR-021**: O sistema DEVE tratar estados sem resultados, serviço não configurado,
  ausência de rede, imagem ausente e registro não encontrado sem travar a navegação.
  Aceite: cenários de Edge Cases e US6.

### Constitutional Requirements

Estas são restrições já fixadas pela constituição 2.0.0, não novas decisões de
implementação. A especificação define os resultados; o plano detalhará estrutura,
contratos, dependências, configuração e estratégia de migração, sem conceder exceções.

- **CR-001**: A adequação DEVE demonstrar cumprimento de CONST-001 a CONST-004:
  arquitetura híbrida da skill Flutter, MVVM, ViewModels, interfaces de Repository
  e Services que encapsulam Supabase/plugins, conforme a constituição 2.0.0. A UI
  é agrupada por funcionalidade e Data/Domain por tipo. A revisão DEVE comprovar
  ausência de acessos diretos e decisões de negócio nos Widgets. Repositories
  consomem Services e retornam modelos de domínio, sem executar queries do SDK.
- **CR-002**: A adequação DEVE cumprir CONST-007 com um contrato compartilhado
  `Result<T>`, sem dependência dos tipos do provedor na apresentação; as falhas
  esperadas DEVEM resultar nos estados e mensagens de FR-016/017.
- **CR-003**: Toda regra de ViewModel e Repository, e todo tratamento/validação de
  Service, DEVE possuir teste unitário
  obrigatório de sucesso, falha, validação e autorização quando aplicáveis,
  incluindo estados assíncronos, mapeamentos e captura de erros (CONST-005).
  Testes de Repository usam Services falsos; testes de VM usam Repositories falsos;
  testes dos Services exercitam o limite externo com dependências controladas.
- **CR-004**: Cada tela principal DEVE ter pelo menos um Widget Test de caminho
  feliz: início; catálogo/busca; favoritos; detalhes; sobre; login; painel Kanban/lista;
  cadastro/edição. Upload DEVE ser exercitado no teste do formulário ou detalhe
  onde for inserido. Os testes DEVEM usar dependências controladas (CONST-006).
- **CR-005**: O plano DEVE incluir comprovação de bloqueios de leitura, escrita e
  fotos para visitantes e contas não autorizadas no serviço, além dos testes de
  apresentação; esconder controles não satisfaz FR-003/005/015.
- **CR-006**: Dependências novas, nomes do código, mensagens e commits DEVEM
  cumprir CONST-008 a CONST-010. O plano DEVE justificar pacotes antes de sua inclusão;
  testes obrigatórios NÃO podem ser dispensados por templates genéricos.
- **CR-007**: A conclusão DEVE apresentar evidências dos gates de formatação,
  análise, testes e plataforma definidos na constituição, sem alegar validação
  inexistente; plano em conflito DEVE ser corrigido, não a constituição.

### Key Entities *(include if feature involves data)*

- **Animal**: Identificador estável; identificação; descrição pública; situação;
  publicação; indicações de cuidados e referência à foto principal.
- **Registro de cuidado**: Animal relacionado; tipo (vacinação, vermifugação,
  medicação); descrição interna. Exposição limitada à equipe autorizada.
- **Usuário autorizado**: Identidade autenticada e autorização de manejo concedida
  pelo responsável pelo abrigo; autenticação isolada não concede essa autorização.
- **Sessão**: Estado de autenticação, validade e encerramento; determina a
  possibilidade de avaliar acesso privado sem substituir a autorização de manejo.
- **Foto de animal**: Imagem principal associada a um animal, tipo/tamanho,
  estado de envio e condição de acesso compatível com a publicação do cadastro.
- **Favorito**: Referência local a um animal de interesse; não concede acesso
  adicional nem torna públicos dados ocultos.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Um visitante conclui início → busca filtrada → detalhes → favorito
  sem criar conta, em 100% dos cenários de aceitação dessa jornada.
- **SC-002**: Em todos os cenários negativos de acesso definidos, visitantes e
  contas sem autorização obtêm zero registros internos e executam zero alterações
  ou envios autorizados indevidamente, inclusive fora da interface.
- **SC-003**: Um animal cadastrado ou editado permanece idêntico nos campos salvos
  após reinício e após atualização em uma segunda sessão autorizada, em todos os
  cenários de persistência definidos.
- **SC-004**: Em todos os cenários de envio válido, a foto confirmada aparece no
  catálogo permitido; em todos os cenários de envio interrompido ou inválido,
  a foto anterior permanece e nenhum sucesso falso é exibido.
- **SC-005**: Em todas as falhas simuladas de leitura, gravação, login e envio,
  a interface encerra o carregamento, informa o problema em português e oferece
  recuperação sem perder indevidamente os dados em edição.
- **SC-006**: Após adoção ou retirada da publicação e atualização da listagem,
  o animal deixa de fornecer detalhes e foto ao visitante; os contadores internos
  correspondem aos registros confirmados em todos os cenários de manejo.
- **SC-007**: Todas as oito telas principais passam pela jornada feliz definida,
  mantendo navegação, logo e cores; cada resultado é acompanhado de evidência
  reproduzível, e nenhum campo obrigatório inválido é salvo.
- **SC-008**: A revisão da entrega apresenta evidência para os dez princípios
  constitucionais, sem exceções não aprovadas e sem pendências obrigatórias
  apresentadas como concluídas.

## Assumptions

- O escopo cobre um único abrigo, com dois contextos visíveis: Visitante e Usuário
  Autenticado. Só usuários explicitamente autorizados têm acesso ao manejo;
  provisionamento inicial ocorre pelo responsável fora do app, sem nova tela de gestão de equipe.
- A autenticação inicial usa e-mail e senha; criação pública de contas, login social,
  MFA e recuperação de senha dentro do app não fazem parte desta adequação.
- A equipe decide quais animais publica; tratamento/quarentena podem aparecer com
  aviso de indisponibilidade. Novos registros são privados por padrão.
- O upload inicial usa galeria, uma foto principal e JPEG/PNG até 5 MB. Câmera,
  múltiplas fotos, recorte e PDFs ficam fora do escopo.
- Cadastro clínico mantém registros descritivos; não inclui prescrição automática,
  agenda de doses, lembretes ou recomendações de tratamento.
- A rede é necessária para dados compartilhados. Não há fila de escrita offline,
  sincronização em tempo real nem migração automática de dados fictícios. Favoritos
  continuam locais e não incluem informações clínicas.
- Exclusão de animais/contas, histórico de auditoria completo, gestão de usuários,
  notificações, envio de pedidos de adoção e publicação em lojas ficam fora do escopo.
- O plano detalhará o ambiente Supabase, credenciais públicas de cliente, políticas
  de autorização, migrações e armazenamento. Acesso ao projeto e configuração de
  ambiente são dependências para implementação/validação real, não para esta especificação.
- O provedor de dados deve possuir contas e animais de teste separados dos reais
  para comprovar os cenários sem publicar dados de demonstração na produção.
- A rastreabilidade de commits usará os identificadores FR/CR desta especificação,
  qualificados por `001` quando necessário para evitar colisões com futuras features.
