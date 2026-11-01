# Contato público para adoção — proposta visual

Estado: aguardando aprovação explícita. Alteração exclusiva do protótipo HTML.
Solicitação e contatos fornecidos pelo usuário em 2026-11-01.

## Requisito DESIGN-CONTACT-001

Na ficha pública, “Entrar em contato para adoção” abre a tela 10 “Fale com o abrigo”.
Preservar cores do logo, tipografia, componentes arredondados e contexto do animal.
Exibir canais oficiais em cartões e retorno à ficha pelo topo e pelo final.

- WhatsApp: (34) 99137-8936 — https://wa.me/5534991378936
- Instagram: @abrigodosanjosoficial — https://www.instagram.com/abrigodosanjosoficial/
- Facebook: /abrigodosanjosura — https://www.facebook.com/abrigodosanjosura/?locale=pt_BR

Os links do protótipo abrem o serviço externo em outra aba; nenhuma mensagem é
enviada automaticamente. A tela conserva o nome e as características do animal selecionado na ficha.
Após aprovação, planejar binding ao animal selecionado, abertura de links em
Service, ViewModel/Repository conforme a constituição, justificativa de eventual
pacote novo e testes unitários/Widget/Android antes de alterar o Flutter.

- [ ] Aprovação explícita da tela 10 pelo usuário.
- [ ] Planejamento/tarefas da implementação após aprovação.
- [ ] Implementação Flutter e validação — bloqueadas pela aprovação visual.

Validação visual: entrada pela ficha, retorno pelos dois controles, três URLs
oficiais e ausência de overflow em 320/390 px; sem erro JavaScript. Regressões
dos fluxos de calendário/programação/detalhes também passaram. Prévia em
[previews/adoption-contact.png](previews/adoption-contact.png). Aprovação pendente.


## Revisão solicitada — DESIGN-CONTACT-002

Usuário pediu ajustes: deseja compartilhar um link da ficha, e não somente texto
com características. Ao tocar nesse link, quem recebe deve abrir o mesmo animal
no aplicativo. Abrigo não possui site/domínio, conforme resposta de 2026-11-01.

A tela 10 passa a mostrar mensagem e cartão de prévia do link (nome e características
públicas), vinculado ao animal da ficha. O clique no cartão simula abrir a ficha
no protótipo. Nenhum endereço público definitivo é inventado e a prévia não é um
link de produção. Perfis oficiais e número de WhatsApp permanecem os fornecidos.

Após aprovação, planejar:

- Endereço público HTTPS e hospedagem da ficha compartilhável; responsável e custo
  devem ser definidos antes de publicar. Nenhuma compra ou publicação autorizada.
- URL estável por animal e App Links Android verificados; iOS/Universal Links na
  entrega própria. Abrir o animal certo com app aberto/fechado; sem app, ficha web.
- Mensagem WhatsApp com URL codificada, revisável pelo remetente, sem envio automático.
- Metadados públicos da página para prévia de link; aparência depende do aplicativo
  receptor e não deve ser prometida como idêntica ao cartão do protótipo.
- Instagram/Facebook mantêm perfis oficiais; alternativa de copiar o mesmo link,
  sem prometer preenchimento automático de mensagens nessas redes.
- Animal oculto/removido/indisponível retorna mensagem amigável; URL contém somente
  identificador público, nunca notas clínicas, tratamentos, sessões ou credenciais.
- Testes de roteamento/URL, cold/warm start Android, fallback web, visibilidade e
  segurança; alterações de pacotes/arquitetura justificadas no plano.

Referências oficiais consultadas:
[WhatsApp click to chat](https://faq.whatsapp.com/5913398998672934),
[Android App Links](https://developer.android.com/training/app-links/about),
[associação HTTPS](https://developer.android.com/training/app-links/configure-assetlinks),
[Flutter App Links](https://docs.flutter.dev/cookbook/navigation/set-up-app-links).

Estado da revisão: aguardando aprovação. Sem implementação Flutter deste fluxo.

Validação da revisão: 320/390 px, mensagem/cartão vinculados ao nome da ficha,
características públicas preservadas, clique da prévia voltando ao mesmo animal
e três contatos oficiais conferidos. Sem erro JS/overflow. Aprovação ainda pendente.
