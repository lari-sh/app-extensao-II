# Tarefas — contato para adoção

Branch developer. Autoridade: spec.md e plan.md. Testes obrigatórios.

## Preparação
- [x] T001 Registrar aprovação v3, opção por subdomínio grátis e plano constitucional em design/adoption-contact-proposal.md e specs/004-adoption-contact/*.md. [004-FR-001, 004-FR-007]

## Fundação e US1 — contatos oficiais
Aceitação: ficha -> tela aprovada -> canal externo; retorno preserva ficha.
- [x] T002 Escrever testes Service/Repository em test/data/services/url_launcher_link_service_test.dart e test/data/repositories/adoption_contact_repository_test.dart: URLs oficiais, encoding, indisponibilidade, false/exceções. [004-FR-002, 004-FR-003, 004-CR-001]
- [x] T003 Adicionar pacote justificado pubspec.yaml/lock e implementar lib/data/services/{external_link_service,url_launcher_link_service}.dart, lib/domain/repositories/adoption_contact_repository.dart e lib/data/repositories/adoption_contact_repository_impl.dart. [004-FR-002, 004-FR-003, 004-CR-001]
- [ ] T004 Escrever test/ui/features/adoption/view_models/adoption_contact_view_model_test.dart e implementar lib/domain/models/adoption_contact_state.dart e lib/ui/features/adoption/view_models/adoption_contact_view_model.dart; revalidação, busy/dispose, erros amigáveis. [004-FR-004, 004-CR-001, 004-CR-002]
- [ ] T005 Escrever test/ui/features/adoption/views/adoption_contact_screen_test.dart e regressão de rota em test/ui/features/animals/views/animal_detail_screen_test.dart; implementar tela em lib/ui/features/adoption/views/adoption_contact_screen.dart e composição em lib/app/{app_router,public_dependencies}.dart. Sem prévia; 320 px/texto ampliado e retornos. [004-FR-001, 004-CR-002]
- [ ] T006 Escrever integration_test/adoption_contact_flow_test.dart; validar Android externo/retorno, atualizar .github/scripts/android_management.sh, README.md e validation.md; format/analyze/test/build e CI/artifact; publicar US1 por contexto. [004-FR-002, 004-CR-002]

## US2 — ficha compartilhável
Aceitação independente: URL HTTPS abre animal correto com/sem app; nenhum dado privado.
- [ ] T007 Avaliar host grátis e preparar proposta concreta de endereço/conta, fallback e publicação em specs/004-adoption-contact/hosting.md; verificar políticas/limites do fornecedor e solicitar autorização antes da publicação. [004-FR-005, 004-FR-007]
- [ ] T008 Escrever testes públicos da página e implementar fallback web local em web/animal-profile/ usando somente acesso público vigente; testar oculto/removido e ausência de cache privado. [004-FR-006, 004-CR-002]
- [ ] T009 Após autorização publicar host/assetlinks, registrar endereço e fingerprint real; configurar AndroidManifest.xml e lib/app/app_router.dart com roteamento de URL validado, sem aceitar host arbitrário. [004-FR-005, 004-FR-006, 004-FR-007]
- [ ] T010 Ampliar Repository/testes para anexar URL HTTPS real e codificada ao rascunho WhatsApp; habilitar somente após host validado, sem prévia na tela. [004-FR-003, 004-FR-005]
- [ ] T011 Validar App Links verified, cold/warm start, link em outro app, fallback sem instalação; atualizar integration_test/adoption_contact_flow_test.dart e specs/004-adoption-contact/validation.md. Não substituir por adb com package forçado. [004-FR-006, 004-CR-002]

## Entrega
- [ ] T012 Revisar docs/tasks, CI e artifact, commits por contexto na developer e limitações de iOS em specs/004-adoption-contact/validation.md. [004-CR-002]

## Dependências e estratégia
T001 -> T002 -> T003 -> T004 -> T005 -> T006. US1 é incremento utilizável sem host,
sem alegar US2 pronta. T007 -> T008 -> aprovação de publicação -> T009 -> T010 ->
T011 -> T012. Contratos/modelos de US2 podem ser preparados depois de T001.
Testes separados podem ser executados em paralelo sem edições concorrentes;
marcadores não autorizam agentes. Atualizar tasks após etapa validada e commit/push
antes do próximo contexto. Tarefas de teste não são concluídas só por escrever testes.
