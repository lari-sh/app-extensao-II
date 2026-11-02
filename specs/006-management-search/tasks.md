# Tarefas — busca administrativa (006)

Branch developer. Nenhuma implementação Flutter antes de DESIGN-SEARCH-001 aprovado.

- [x] T001 Preparar proposta, revisar 320/390 px, interações e estados; registrar evidência. [006-FR-001, 006-FR-007]
- [ ] T002 Obter aprovação expressa do desenho e atualizar design-approval.md. Depende de T001. [006-FR-007]
- [ ] T003 Criar RPC aditiva e pgTAP: nome/filtros/paginação/contagem/literais e autorização/sessão atual. Depende de T002. [006-FR-002, 006-FR-003, 006-FR-006]
- [ ] T004 Adicionar filtro imutável e contrato em Service/Domain; implementar SDK com erros saneados e testes. Depende de T003. [006-CR-001]
- [ ] T005 Implementar Repository e unitários de mapeamento, validação, cursor e falhas. Depende de T004. [006-CR-001]
- [ ] T006 Implementar VM/Freezed: debounce, submit, filtros, paginação, retorno, geração/contexto privado, dispose; unitários de regras e respostas tardias. Depende de T005. [006-FR-002, 006-FR-005, 006-FR-006]
- [ ] T007 Integrar aba/painel/cartões e editor existente preservando modos; Widget happy path, erro/retry, vazio e 320/390 px/texto ampliado. Depende de T006. [006-FR-001, 006-FR-004, 006-FR-007]
- [ ] T008 Validar HTTP de acesso direto, revogação, busca além da primeira página e limpeza de fixtures próprias. Depende de T003. [006-FR-003, 006-FR-006]
- [ ] T009 Criar/validar jornada Android busca→ficha→retorno→filtros→logout com dados de teste e sem perda de cadastros manuais. Depende de T007/T008. [006-CR-001]
- [ ] T010 Executar gates/CI, preservar nove jornadas anteriores e cobertura global >=95%, registrar evidências reais. Depende de T009. [006-CR-001]
- [ ] T011 Atualizar documentação e tasks após cada etapa validada; commits por contexto na developer. Em todas as etapas. [006-CR-001]
