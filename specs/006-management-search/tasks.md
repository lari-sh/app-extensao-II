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
- [ ] T016 Validar revisão no Android/CI, cobertura >=95%, documentação e commits por contexto na developer. [006-CR-001]

- [ ] T017 Ampliar cobertura de regras/permissões/modos/fotos e medir cobertura real; não excluir código para elevar números. [006-CR-001]


## Auditoria de dimensões solicitada em 2026-11-02

- [x] T018 Inventariar dimensões das views/widgets/tema e medir Kanban/Lista/Calendário com fontes ampliadas; comparar com recomendações oficiais e documentar limitações. Ver docs/reviews/component-sizing-2026-11-02/review.md. [006-CR-001]
- [ ] T019 Preparar revisão visual das dimensões/colunas do Kanban e áreas de toque; explicar alterações e obter aprovação antes de mudar o layout. [006-FR-007, 006-CR-001]
- [ ] T020 Após aprovação, implementar ajustes por contexto, testar acessibilidade/responsividade por tela e validar no celular/CI. Depende de T019. [006-CR-001]


## Busca confirmada e navegação administrativa — 2026-11-02

- [x] T021 Separar texto digitado de critérios aplicados; consultar somente após confirmar Buscar ou aplicar filtros, preservar resultados/foco durante edição e rejeitar respostas antigas. Testes VM/Widget e documentação; CI acompanhada em T024. [006-FR-003, 006-FR-009, 006-CR-001]
- [x] T022 Pesquisar navegação secundária oficial e preparar proposta de Equipe e acessos no menu do cabeçalho administrativo, fora da agenda; obter aprovação expressa antes de implementar a mudança visual. [006-FR-007, 006-CR-001]
- [x] T023 Após aprovação de T022, implementar navegação administrativa preservando perfis, voltar à esquerda e os três modos; testes e documentação por contexto. [006-FR-006, 006-FR-007, 006-CR-001]

- [ ] T024 Validar busca confirmada e menu aprovado no Android/CI, atualizar APK normal no celular e deixar acesso administrativo disponível; registrar evidências. Android e APK PASS; CI remota pendente. [006-CR-001]


## Busca no catálogo público por nome, espécie e sexo

- [x] T025 Atualizar especificação/plano/contrato da busca pública combinada: nome, espécie, sexo e combinações como gata fêmea/gato macho/gato fêmea; manter paginação/filtros existentes e dados públicos apenas. [006-FR-010, 006-CR-001]
- [x] T026 Criar testes de interpretação/VM para acentos, maiúsculas, nome + espécie + sexo, espécies/sexos isolados, limpar/repetir pesquisa, conflitos e respostas tardias. Sem SDK na UI ou dependência nova. Depende de T025. [006-FR-010, 006-CR-001]
- [x] T027 Implementar interpretação na camada de lógica e integrar ao campo público existente, com confirmação Buscar e filtros combinados enviados ao Repository; Widget happy path/erro e preservação do design. Depende de T026. [006-FR-010, 006-CR-001]
- [ ] T028 Validar catálogo público no Android e CI/cobertura, atualizar documentação e publicar commits por contexto na developer; deixar APK normal disponível no celular. Depende de T027. Android e APK PASS; CI remota pendente. [006-FR-010, 006-CR-001]

- [x] T029 Corrigir e validar limpeza das fixtures de busca com tratamentos, respeitando FKs RESTRICT e rejeitando remoção de animais alheios. [006-CR-001]
