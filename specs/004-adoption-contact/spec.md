# Contato público para adoção

Data: 2026-11-01. Branch de implementação: developer.
Design aprovado explicitamente: DESIGN-CONTACT-003, tela 10, commit 73d1e55.
Escopo atualizado pelo usuário: sem hospedagem e sem compartilhamento da ficha.

## US1 — canais oficiais (P1)
Visitante abre “Entrar em contato para adoção” na ficha e vê “Fale com o abrigo”,
logo, nome do animal, WhatsApp, Instagram, Facebook e ambos os retornos à ficha.
Sem prévia de mensagem/cartão de link na tela. Voltar preserva a ficha.

- 004-FR-001: Preservar integralmente a composição aprovada, inclusive 320 px/texto ampliado.
- 004-FR-002: Abrir somente os três canais oficiais fornecidos pelo usuário, via HTTPS.
  Instagram /abrigodosanjosoficial/, Facebook /abrigodosanjosura/?locale=pt_BR,
  WhatsApp 5534991378936. Sem envios automáticos.
- 004-FR-003: WhatsApp recebe rascunho em português com nome e dados públicos do
  animal; somente o usuário revisa e envia. Não mostrar a mensagem na tela de contato.
- 004-FR-004: Revalidar a visibilidade/disponibilidade do animal antes de preparar
  seu contato; oculto/adotado/removido não usa dados obsoletos. Sem dados clínicos.

## Escopo cancelado em 2026-11-01

Usuário determinou remover hospedagem e envio da ficha da lista de tarefas.
004-FR-005 e 004-FR-006 retirados, sem implementação: não há link compartilhável,
fallback web ou App Links nesta feature. 004-FR-007 passa a registrar a proibição
de preparar/publicar hospedagem de ficha neste escopo. WhatsApp prepara somente
texto com dados públicos; sem anexar ficha, URL ou prévia na tela.

- 004-CR-001: MVVM, estados Freezed, Repository abstrato, SDK/plugin em Service,
  Result com mensagem amigável. Novo pacote justificado no plano.
- 004-CR-002: Unitários das regras e Widget happy path de cada tela, regressões,
  Android e CI distintos; docs/tasks atualizados e commits por contexto na developer.

Escopo atual: US1 com canais oficiais e rascunho textual. A nota do rodapé informa
apenas que o usuário revisa e envia a mensagem; não promete link ou hospedagem.
