# Tarefas — busca global administrativa (006, revisão v2)

Branch developer. Esta revisão substitui a aba da v1. Flutter e migrations somente
após aprovação expressa de DESIGN-SEARCH-001 v2; aprovação antiga não cobre o novo layout.

- [x] T001 Atualizar proposta com campo fixo, três modos, nome/código, cinco filtros e homônimos; QA 320/390/1440 px, estados e preservação do contexto. [006-FR-001, 006-FR-007, 006-FR-009]
- [ ] T002 Obter aprovação expressa da revisão visual v2 e registrar em design-approval.md. Depende de T001. [006-FR-007]
- [ ] T003 Criar migration de código automático único/imutável, backfill protegido e testes pgTAP de legados, concorrência, lacunas e >9999; preservar UUID/fotos/históricos. Depende de T002. [006-FR-008]
- [ ] T004 Criar RPC aditiva com query/código e cinco filtros, total/cursor; testes SQL de literais, nomes repetidos, autorização e independência de modo/data/evento. Depende de T003. [006-FR-002, 006-FR-003, 006-FR-006, 006-FR-009]
- [ ] T005 Atualizar Domain/DTO/Service com código e filtro imutável; contrato Repository e testes de serialização, validação e erros saneados. Depende de T004. [006-CR-001, 006-FR-008]
- [ ] T006 Implementar Repository e unitários de mapeamento, filtros, cursor e falhas, sem tipos SDK na UI. Depende de T005. [006-CR-001]
- [ ] T007 Implementar VM/Freezed: debounce, submit, critérios/rascunho/cancelar, limpar texto/tudo, geração/contexto/fotos/dispose e preservação dos três modos. Unitários das regras. Depende de T006. [006-FR-003, 006-FR-005, 006-FR-006, 006-FR-009]
- [ ] T008 Integrar toolbar fixa/painel de filtros/resultados/ficha, sem DashboardMode.search. Widget happy path/erro e testes dos três modos, retorno de data/rolagem e 320/390 px/texto ampliado. Depende de T007. [006-FR-001, 006-FR-004, 006-FR-007, 006-FR-009]
- [ ] T009 Validar HTTP de código/filtros, acesso direto e revogação; casos além da página inicial e sem aplicação no dia. Limpar só fixtures próprias. Depende de T004. [006-FR-002, 006-FR-003, 006-FR-006, 006-FR-009]
- [ ] T010 Criar/validar jornada Android nos três modos, homônimos/códigos, cinco filtros, ficha/retorno, dia preservado e logout, sem perder cadastros manuais. Depende de T008/T009. [006-CR-001]
- [ ] T011 Executar gates/CI, preservar nove jornadas existentes e cobertura global >=95%; registrar evidências reais. Depende de T010. [006-CR-001]
- [ ] T012 Atualizar documentação/tasks após cada etapa validada e realizar commits por contexto na developer. Em todas as etapas. [006-CR-001]
