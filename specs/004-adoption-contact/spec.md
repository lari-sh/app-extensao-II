# Contato público para adoção

Data: 2026-11-01. Branch de implementação: developer.
Design aprovado explicitamente: DESIGN-CONTACT-003, tela 10, commit 73d1e55.
Escolha do usuário: planejar subdomínio gratuito, sujeito à disponibilidade.

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

## US2 — link da ficha (P1, dependência de hospedagem)
Quem recebe a mensagem toca em URL estável do mesmo animal: app instalado abre
ficha correta; sem app, página pública HTTPS. Sem domínio próprio, planejar
subdomínio gratuito. Não inventar URL nem apresentar link local como público.

- 004-FR-005: URL HTTPS com identificador público e nenhum dado privado; anexar à
  mensagem WhatsApp somente depois de haver endereço publicado validado.
- 004-FR-006: Android App Links verificados, cold/warm start, fallback web e
  indisponibilidade amigável. Fotos e dados seguem autorização pública atual.
- 004-FR-007: Não contratar/publicar serviço nesta etapa; preparar resultado local
  revisável e solicitar autorização final de publicação após definir endereço/conta.
- 004-CR-001: MVVM, estados Freezed, Repository abstrato, SDK/plugin em Service,
  Result com mensagem amigável. Novo pacote justificado no plano.
- 004-CR-002: Unitários das regras e Widget happy path de cada tela, regressões,
  Android e CI distintos; docs/tasks atualizados e commits por contexto na developer.

Escopo incremental: US1 pode funcionar com rascunho textual sem URL enquanto US2
não foi publicada. Isso não conclui o compartilhamento de link; registrar a limitação.
O aviso curto do desenho sobre link deve refletir a disponibilidade real no estado
apresentado pelo ViewModel, sem acrescentar componentes ou alterar o layout.
