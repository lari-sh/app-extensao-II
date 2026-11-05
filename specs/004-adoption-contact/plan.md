# Plano técnico — contato para adoção

Branch: developer | Data: 2026-11-01 | Spec: [spec.md](spec.md)

## Resumo e contexto técnico
Flutter 3.41.1/Dart 3.11, Android minSdk24, Supabase existente, Provider/Freezed.
Nova tela pública segue tela 10 aprovada sem prévia; nenhuma migration necessária
para US1. Usa AnimalsRepository.getPublic para revalidar antes do contato.

## Constitution Check — antes e após desenho
PASS: UI por funcionalidade, dados/domínio por tipo; Views só recebem VM e callbacks.
VM decide permissões/rascunho/mensagens; Repository medeia Service. Result em todas
as operações; exceções externas nunca chegam à View. Identificadores em inglês,
textos em português. Modelo de estado Freezed; nenhuma cópia de notas clínicas.
Unitários Service/Repository/VM, Widget e Android obrigatórios; documentação e
commits por contexto. A aprovação DESIGN-CONTACT-003 está registrada no protótipo.
Sem dispensa constitucional ou alteração não autorizada de layout.

## Dependência justificada
Adicionar url_launcher 6.3.3 (publisher flutter.dev): abrir URLs externas pelo SO,
com retorno de sucesso/falha e compatibilidade Android/iOS. Reutilizar APIs SDK
não fornece abertura multiplataforma equivalente; não criar plugin nativo próprio.
Android minSdk24 já atende. Service encapsula launchUrl em externalApplication e
captura false/exceções; não bloquear botão por canLaunchUrl (falsos negativos).
Nenhum outro pacote novo. App Links e hospedagem foram removidos do escopo.

## Estrutura e responsabilidades
- lib/domain/models/adoption_contact_state.dart: estado imutável Freezed.
- lib/domain/repositories/adoption_contact_repository.dart: contrato de abertura.
- lib/data/services/external_link_service.dart e url_launcher_link_service.dart:
  fronteira de plataforma injetável e Result.
- lib/data/repositories/adoption_contact_repository_impl.dart: canais fixos,
  rascunho português e composição segura de URI, nunca URL arbitrária da UI.
- lib/ui/features/adoption/{view_models,views}: carregar animal por ID, bloquear
  duplicatas, descartar respostas após dispose, estados amigáveis, tela aprovada.
- lib/app/{app_router,public_dependencies}.dart: composição e rota ID-only.
- lib/ui/features/animals/views/animal_detail_screen.dart: CTA abre contato,
  preserva retorno à ficha; antigo fluxo de copiar deixa de ser ação principal.
- test/data/{services,repositories}, test/ui/features/adoption: regras e happy path.
- integration_test/adoption_contact_flow_test.dart: jornada pública Android.

## Incrementos e fechamento
1. Aprovação/spec/plano/tarefas e commits por contexto na developer.
2. US1 com testes Service/Repository/VM/View, regressão e Android.
3. Conferência da CI/artifact e atualização de documentação/tarefas.

## Alteração de escopo em 2026-11-01
Cancelados a pedido do usuário: hospedagem gratuita da ficha, fallback web,
App Links e envio de link/anexo da ficha pelo WhatsApp. Removidas T007–T011.
Não adicionar configuração de host, manifest handlers ou plataforma de hospedagem.
O rascunho inclui apenas dados públicos em texto; continua revisável e sem envio
automático. Remover do rodapé a promessa/pendência de link mantendo o layout.
