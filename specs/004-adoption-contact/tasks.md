# Tarefas — contato para adoção

Branch developer. Autoridade: spec.md e plan.md. Testes obrigatórios.

## Preparação
- [x] T001 Registrar aprovação v3, histórico de escopo e plano constitucional em design/adoption-contact-proposal.md e specs/004-adoption-contact/*.md. [004-FR-001, 004-FR-007]

## Fundação e US1 — contatos oficiais
Aceitação: ficha -> tela aprovada -> canal externo; retorno preserva ficha.
- [x] T002 Escrever testes Service/Repository em test/data/services/url_launcher_link_service_test.dart e test/data/repositories/adoption_contact_repository_test.dart: URLs oficiais, encoding, indisponibilidade, false/exceções. [004-FR-002, 004-FR-003, 004-CR-001]
- [x] T003 Adicionar pacote justificado pubspec.yaml/lock e implementar lib/data/services/{external_link_service,url_launcher_link_service}.dart, lib/domain/repositories/adoption_contact_repository.dart e lib/data/repositories/adoption_contact_repository_impl.dart. [004-FR-002, 004-FR-003, 004-CR-001]
- [x] T004 Escrever test/ui/features/adoption/view_models/adoption_contact_view_model_test.dart e implementar lib/domain/models/adoption_contact_state.dart e lib/ui/features/adoption/view_models/adoption_contact_view_model.dart; revalidação, busy/dispose, erros amigáveis. [004-FR-004, 004-CR-001, 004-CR-002]
- [x] T005 Escrever test/ui/features/adoption/views/adoption_contact_screen_test.dart e regressão de rota em test/ui/features/animals/views/animal_detail_screen_test.dart; implementar tela em lib/ui/features/adoption/views/adoption_contact_screen.dart e composição em lib/app/{app_router,public_dependencies}.dart. Sem prévia; 320 px/texto ampliado e retornos. [004-FR-001, 004-CR-002]
- [x] T006 Escrever integration_test/adoption_contact_flow_test.dart; validar Android externo/retorno, atualizar .github/scripts/android_management.sh, README.md e validation.md; format/analyze/test/build e CI/artifact; publicar US1 por contexto. [004-FR-002, 004-CR-002]

## Entrega
- [ ] T012 Revisar docs/tasks, CI e artifact, commits por contexto na developer e limitações de iOS em specs/004-adoption-contact/validation.md. [004-CR-002]

## Dependências e escopo atual
T001 -> T002 -> T003 -> T004 -> T005 -> T006 -> T012.
T007–T011 removidas a pedido do usuário em 2026-11-01: cancelados hospedagem,
ficha compartilhável, App Links e URL na mensagem. Não renumerar nem registrar
essas tarefas como implementadas. WhatsApp mantém apenas o rascunho textual.
Atualizar evidências e publicar cada contexto validado na developer.
