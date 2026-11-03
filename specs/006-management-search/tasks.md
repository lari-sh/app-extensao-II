# Tarefas — busca global administrativa (006, revisão v2)

Branch developer. Esta revisão substitui a aba da v1. DESIGN-SEARCH-001 v2
aprovada expressamente antes da implementação. Evidências reais em validation.md.

- [x] T001 Atualizar proposta com campo fixo, três modos, nome/código, cinco filtros e homônimos; QA 320/390/1440 px, estados e preservação do contexto. [006-FR-001, 006-FR-007, 006-FR-009]
- [x] T002 Obter aprovação expressa da revisão visual v2 e registrar em design-approval.md. Depende de T001. [006-FR-007]
- [x] T003 Criar migration de código automático único/imutável, backfill protegido e testes pgTAP de legados, concorrência, lacunas e >9999; preservar UUID/fotos/históricos. Depende de T002. [006-FR-008]
- [x] T004 Criar RPC aditiva com query/código e cinco filtros, total/cursor; testes SQL de literais, nomes repetidos, autorização e independência de modo/data/evento. Depende de T003. [006-FR-002, 006-FR-003, 006-FR-006, 006-FR-009]
- [x] T005 Atualizar Domain/DTO/Service com código e filtro imutável; contrato Repository e testes de serialização, validação e erros saneados. Depende de T004. [006-CR-001, 006-FR-008]
- [x] T006 Implementar Repository e unitários de mapeamento, filtros, cursor e falhas, sem tipos SDK na UI. Depende de T005. [006-CR-001]
- [x] T007 Implementar VM/Freezed: debounce, submit, critérios/rascunho/cancelar, limpar texto/tudo, geração/contexto/fotos/dispose e preservação dos três modos. Unitários das regras. Depende de T006. [006-FR-003, 006-FR-005, 006-FR-006, 006-FR-009]
- [x] T008 Integrar toolbar fixa/painel de filtros/resultados/ficha, sem DashboardMode.search. Widget happy path/erro e testes dos três modos, retorno de data/rolagem e 320/390 px/texto ampliado. Depende de T007. [006-FR-001, 006-FR-004, 006-FR-007, 006-FR-009]
- [x] T009 Validar HTTP de código/filtros, acesso direto e revogação; casos além da página inicial e sem aplicação no dia. Limpar só fixtures próprias. Depende de T004. [006-FR-002, 006-FR-003, 006-FR-006, 006-FR-009]
- [x] T010 Criar/validar jornada Android nos três modos, homônimos/códigos, cinco filtros, ficha/retorno, dia preservado e logout, sem perder cadastros manuais. Depende de T008/T009. [006-CR-001]
- [x] T011 Executar gates/CI, preservar nove jornadas existentes e cobertura global >=95%; registrar evidências reais. Depende de T010. [006-CR-001]
- [x] T012 Atualizar documentação/tasks após cada etapa validada e realizar commits por contexto na developer. Em todas as etapas. [006-CR-001]


## Revisão v3 solicitada em 2026-11-02

A responsável substituiu a lista global temporária pelo resultado dentro do modo
selecionado. No Calendário, manter a data e mostrar somente as medicações do dia.

- [x] T013 Corrigir carregamento/permissões do manejo clínico na ficha durante revalidação concorrente; testes VM/Widget e Android. [006-FR-006, 006-CR-001]
- [x] T014 Atualizar design, especificação/plano/contratos para busca dentro de Kanban/Lista/Calendário e medicações somente do dia. [006-FR-009]
- [x] T015 Implementar filtros do modo no servidor e na apresentação, sem limitar aos itens carregados; testes obrigatórios. [006-FR-009, 006-CR-001]
- [x] T016 Validar revisão no Android/CI, cobertura >=99%, documentação e commits por contexto na developer. [006-CR-001]

- [x] T017 Ampliar cobertura de regras/permissões/modos/fotos e medir cobertura real; não excluir código para elevar números. [006-CR-001]


## Auditoria de dimensões solicitada em 2026-11-02

- [x] T018 Inventariar dimensões das views/widgets/tema e medir Kanban/Lista/Calendário com fontes ampliadas; comparar com recomendações oficiais e documentar limitações. Ver docs/reviews/component-sizing-2026-11-02/review.md. [006-CR-001]
- T019 CANCELADA em 2026-11-03: propostas de dimensões avaliadas e rejeitadas; responsável determinou manter o Kanban como estava antes. Ver docs/reviews/component-sizing-2026-11-02/rejected-proposals/README.md. [006-FR-007]
- T020 CANCELADA pela decisão de T019: nenhuma mudança de layout do Kanban deve ser implementada. Layout Flutter anterior preservado.


## Busca confirmada e navegação administrativa — 2026-11-02

- [x] T021 Separar texto digitado de critérios aplicados; consultar somente após confirmar Buscar ou aplicar filtros, preservar resultados/foco durante edição e rejeitar respostas antigas. Testes VM/Widget e documentação; CI acompanhada em T024. [006-FR-003, 006-FR-009, 006-CR-001]
- [x] T022 Pesquisar navegação secundária oficial e preparar proposta de Equipe e acessos no menu do cabeçalho administrativo, fora da agenda; obter aprovação expressa antes de implementar a mudança visual. [006-FR-007, 006-CR-001]
- [x] T023 Após aprovação de T022, implementar navegação administrativa preservando perfis, voltar à esquerda e os três modos; testes e documentação por contexto. [006-FR-006, 006-FR-007, 006-CR-001]

- [x] T024 Validar busca confirmada e menu aprovado no Android/CI, atualizar APK normal no celular e deixar acesso administrativo disponível; registrar evidências. Android e APK normal PASS na etapa anterior; CI #187 PASS. A versão de depuração atual foi mantida conectada conforme decisão posterior para reduzir instalações. [006-CR-001]


## Busca no catálogo público por nome, espécie e sexo

- [x] T025 Atualizar especificação/plano/contrato da busca pública combinada: nome, espécie, sexo e combinações como gata fêmea/gato macho/gato fêmea; manter paginação/filtros existentes e dados públicos apenas. [006-FR-010, 006-CR-001]
- [x] T026 Criar testes de interpretação/VM para acentos, maiúsculas, nome + espécie + sexo, espécies/sexos isolados, limpar/repetir pesquisa, conflitos e respostas tardias. Sem SDK na UI ou dependência nova. Depende de T025. [006-FR-010, 006-CR-001]
- [x] T027 Implementar interpretação na camada de lógica e integrar ao campo público existente, com confirmação Buscar e filtros combinados enviados ao Repository; Widget happy path/erro e preservação do design. Depende de T026. [006-FR-010, 006-CR-001]
- [x] T028 Validar catálogo público no Android e CI/cobertura, atualizar documentação e publicar commits por contexto na developer; deixar APK normal disponível no celular. Depende de T027. Android e APK normal PASS na etapa anterior; CI #187 PASS. A versão de depuração atual foi mantida conectada conforme decisão posterior para reduzir instalações. [006-FR-010, 006-CR-001]

- [x] T029 Corrigir e validar limpeza das fixtures de busca com tratamentos, respeitando FKs RESTRICT e rejeitando remoção de animais alheios. [006-CR-001]


## Cadastro visível e altura do Kanban — proposta de 2026-11-02

- [x] T030 Preparar e revisar proposta de + Animal no cabeçalho, Atualizar no menu e remoção da reserva inferior de 90 dp do Kanban/Lista, mantendo SafeArea; validar 320/390 px e solicitar aprovação antes de mudar Flutter. [006-FR-007, 006-CR-001]
- [x] T031 Após aprovação de T030, reposicionar cadastro preservando regras de acesso/visibilidade, estender área útil e testar navegação, altura, toque e Android; documentar e publicar por contexto. [006-FR-006, 006-FR-007, 006-CR-001]

- [x] T032 Aplicar ajustes aprovados: item vermelho Adicionar animal no menu do cabeçalho (decisão T034), rótulo Total com contagem real, adaptação compacta, testes de navegação/altura e atualização do APK no celular. [006-FR-007, 006-CR-001]

- T033 SUBSTITUÍDA: a proposta de linha própria foi descartada pela decisão expressa de colocar Adicionar animal no menu (T034); nenhuma implementação dessa proposta é necessária.

- [x] T034 Aplicar decisão vigente: Adicionar animal vermelho no menu administrativo nos três modos, sem botão externo/linha extra; testar perfis, cadastro/retorno, Total e altura do Kanban; atualizar protótipo, APK e documentação, com commit por contexto. Substitui T031–T033 quanto à posição. [006-FR-007, 006-CR-001]


- [x] T035 Investigar divergência 71/72, remover exclusivamente fixture de medicação comprovada, garantir limpeza no finally da jornada local, testar proteção de cadastros reais e contagem com adotados; atualizar painel/documentação e commit por contexto. [006-CR-001]


## Meta de cobertura global 99% — solicitada em 2026-11-02

- [x] T036 Medir LCOV por arquivo e mapear lacunas reais, sem adicionar exclusões; registrar a linha de base e os cenários prioritários. [006-CR-001]
- [x] T037 Cobrir operações/dados: validações, transporte, permissões, armazenamento, callbacks e descarte de respostas obsoletas; executar testes específicos e commit por contexto. [006-CR-001]
- [x] T038 Cobrir interfaces/navegação: medicamentos, fotos, ficha, catálogo, painel e rotas, incluindo erros e texto ampliado; executar testes específicos e commit por contexto. [006-CR-001]
- [x] T039 Medir suíte integral até >=99% global, atualizar gate/documentação com o resultado real e publicar na developer; distinguir cobertura local e aprovação remota. [006-CR-001]


## Sobre público: contatos e doação Pix

- [x] T040 Planejar e atualizar a referência visual do Sobre com WhatsApp +55 34 99137-8936, Instagram abrigodosanjosoficial, Facebook abrigodosanjosura e Pix 23.785.379/0001-98, conforme pedido expresso. Preservar visual existente. [006-FR-011, 006-CR-001]
- [x] T041 Implementar contatos e cópia da chave via ViewModel/Repository/Services, com mensagens portuguesas e testes de sucesso, indisponibilidade/erro e UI; sem SDK externo no Widget. [006-FR-011, 006-CR-001]
- [x] T042 Validar no Android, atualizar documentação e publicar por contexto na developer; retomar a meta de cobertura global >=99% incluindo o novo código. [006-FR-011, 006-CR-001]


## Cenários fidedignos de uso — 2026-11-02

- [x] T043 Reutilizar exemplos fictícios autorizados com fotos ilustrativas versionadas, origem/hash documentados e testes de integridade; preservar animais manuais e evitar duplicações no backend local. [DEMO-FR-001, 006-CR-001]
- [x] T044 Validar ficha/foto, favoritos, homônimos/códigos, filtros e medicações usando exemplos realistas; incluir falhas e permissões na ampliação da cobertura. [006-CR-001]
- [x] T045 Conferir CI atual, validar cenário no celular após aviso, atualizar documentação e publicar cada contexto validado na developer. [006-CR-001]

- [x] T046 Excluir os 63 cadastros antigos de teste por identidade/autoria confirmadas, salvar backup local, preservar os oito exemplos com fotos e configurar tratamento/quarentena/agenda simulada, conforme nova autorização. Ver supabase/demo/README.md. [DEMO-FR-001, 006-CR-001]


- [x] T047 Organizar Vacinas na ficha pública com nome antes da data, preservando todos os registros/reforços; atualizar protótipo, testar VM/Widget em tela pequena, validar Android e commit por contexto. [006-FR-012]


- [x] T048 Corrigir conteúdo privado retido quando a instância de sessão é substituída por outra conta com mesma geração; regressão Widget, gates e Android, sem alterar o layout. [006-FR-006, 006-CR-001]

## Demonstração gravada no celular — 2026-11-03

- [x] T049 Gravar o APK real no celular nos fluxos públicos e administrativos, usando dados fictícios e fotos ilustrativas; conferir os arquivos, organizar capítulos e documentar o que foi demonstrado e eventuais limitações. Salvar o vídeo localmente e informar a pasta, sem enviar mensagens externas. [DEMO-FR-001, 006-CR-001]

- [x] T050 Atualizar checkout/setup-java/upload-artifact para commits oficiais cujo action.yml declara Node.js 24, preservando versões de Flutter, Java e Supabase; validar YAML e publicar separadamente. Resultado remoto conferido somente após os últimos commits. [006-CR-001]

- [x] T051 Pausar a gravação, registrar o MCP oficial Dart/Flutter, comprovar conexão e ferramentas reais, instalar as skills oficiais Flutter/Dart e documentar o uso obrigatório das ferramentas disponíveis antes de retomar T049. Dispositivo físico identificado e análise sem erros via MCP; detalhes em docs/development/flutter-mcp.md. [006-CR-001]

- [x] T052 Reduzir margens externas, recuos das colunas e padding dos cartões do Kanban por solicitação da responsável, mantendo três colunas visíveis sem rolagem lateral e os controles existentes; atualizar protótipo, testar 320/390 px com texto ampliado, validar no celular e publicar por contexto. [006-FR-013]

- [x] T053 Ampliar discretamente os títulos das três colunas do Kanban de 10 para 11 sp, conforme solicitação; atualizar protótipo, validar testes existentes em 320/390 dp com texto ampliado, análise e APK no celular. [006-FR-013]

- [x] T054 Conferir a CI dos commits 06c1670/916726e, corrigir falhas reais e registrar execução, cobertura e entrega Android por contexto. [006-CR-001]
- [x] T055 Substituir no vídeo os trechos com Kanban anterior pelo quadro aprovado (margens reduzidas e títulos 11 sp), preservar os demais fluxos, rever capítulos e decodificação, atualizar roteiro e remover apenas materiais temporários após validar o resultado. [DEMO-FR-001, 006-FR-013]

- [x] T056 Corrigir leitura de medicações interrompida por revalidações concorrentes ao reabrir o editor; retomar somente após acesso confirmado no mesmo contexto privado, testar negativa explícita/troca de contexto e revalidar CI Android, sem mudar o layout. [003-CR-003, 006-CR-001]

- [x] T057 Padronizar altura e alinhamento dos cartões do Kanban, limitar observação visível a até 80 caracteres/3 linhas sem alterar o texto completo na ficha, respeitar texto ampliado e nomes longos; protótipo, testes, Android, vídeo e commit próprios. [006-FR-014]

- [x] T058 Isolar as dez jornadas Android em processos Flutter independentes, preservar o DDS exigido pelo framework e impor limite por jornada, preservar erros e validar o executor com testes de sucesso/falha/offline/configuração antes da execução remota final. [006-CR-001]

Fechamento remoto de T016/T024/T028/T045/T054: CI #187 (0761f3e), quatro jobs PASS; 599 testes Flutter, 99,06% de cobertura, dez jornadas Android e APK entregue. Evidências em docs/reviews/ci-kanban-2026-11-03.md.

## APK de avaliação na nuvem — 2026-11-03

- [x] T059 Preparar configuração pública separada, build normal release sem Driver, verificação HTTPS/schema público, testes do empacotamento e roteiro de implantação. 11 testes Python e 3 Flutter via MCP PASS; análise MCP sem erros. A geração real depende de T060–T061 e será validada em T062. [006-FR-015]
- [x] T060 Com a conta Supabase conectada, criar/identificar projeto de avaliação e aplicar as 21 migrations e quatro Functions; conferir RLS, Storage privado e sessões Auth, sem reset/importação do banco local. PASS em tcdmiudchyptbgjzrotj; configuração/entrega de email e callbacks acompanhadas separadamente em T063. [006-FR-015]
- [x] T061 Provisionar acesso dedicado de funcionário e exemplos fictícios com fotos pelos fluxos autorizados; validar catálogo anônimo, permissões, fotos, cadastro e agenda na nuvem. 8 exemplos, três tratamentos simulados, 15 verificações HTTP PASS; contas criadas manualmente e perfis auditados, sem extrair chaves administrativas. Depende de T060. [006-FR-015, DEMO-FR-001]
- [x] T062 Gerar APK normal para avaliação, conferir assinatura/hash e validar no celular sem transporte ADB reverse; documentar arquivo, acesso e resultados reais. Release/assinatura/instalação PASS; catálogo, ficha, login, Kanban e aplicação com autor/horário confirmados no celular. Arquivos locais de senha apagados. Depende de T059–T061. [006-FR-015]
- [ ] T063 Configurar e validar envio de email e callbacks de convite/recuperação no projeto na nuvem, com provedor apropriado e destinatários autorizados; nenhuma mensagem ao professor enviada automaticamente. Redirects exatos relidos; SMTP Brevo ativo, remetente temporário autorizado e templates em português. Convite de funcionário enviado pelo Android e entregue pelo Brevo às 19h23 de 03/11/2026; banco pending, validade 1h. Restam aceite, recebimento/retorno da recuperação e conclusão dos fluxos no Android. Roteiro em docs/development/cloud-auth-email.md. [006-FR-015]
- [x] T064 Entregar manual DOCX de instalação/acesso/roteiro de avaliação, revisar todas as páginas e conferir ausência de senhas; manter cópia na pasta do APK. Duas páginas revisadas por PDF/PNG do Google Docs, conforme alternativa solicitada; conteúdo do DOCX exportado conferido contra o original. [006-FR-015]
- [x] T065 Conferir CI do último commit e, somente após aprovação, abrir PR developer → main com escopo, validações e limitações; manter merge para revisão posterior. CI #194 no 404a7bf: quatro jobs PASS, 599 testes Flutter, 99,06% de cobertura e dez jornadas Android; PR #1 aberto, sem merge. Novas verificações do commit documental serão acompanhadas separadamente. [006-CR-001, 006-FR-015]
- [x] T066 Corrigir visibilidade de Equipe e acessos para administrador durante carregamento/operações de animais, preservando a permissão real do servidor e a ocultação para funcionários. Regressão reproduzida antes da correção; 38 testes selecionados, análise e formato PASS via MCP oficial. Release atualizado no celular, menu e listagem da equipe confirmados com administrador; perfil remoto correto, sem promoção de contas. Relacionada à validação de T063. [005-FR-001, 006-CR-001]
