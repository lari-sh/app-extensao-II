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
Nenhum outro pacote novo. App Links inicialmente usam mecanismo nativo Flutter;
não adicionar app_links sem necessidade comprovada e novo plano justificado.

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

## Incrementos
1. Aprovação/spec/plano/tarefas; commit documental antes do código.
2. US1: testes antes de Service/Repository/VM/View, regressão completa e Android.
   Sem host publicado, mensagem só textual e nota curta informa isso; US2 pendente.
3. US2: preparar ficha web local com acesso somente público, endereço grátis e
   assetlinks parametrizados pelo certificado real. Autorização final antes de
   publicar. Só anexar URL real após validação de host/App Links e fallback.
4. CI, evidências e commits por contexto; iOS não é validado por Windows.

## Riscos e gates
Preferência de subdomínio grátis não define conta/host/nome disponível nem autoriza
publicação. Não prometer prefixo ou prévia social. Associar apenas host controlado,
sem handlers genéricos; serviço web não usa service_role. Página removida/oculta não
expõe cache antigo. Definir foto sem cache conforme política vigente.
Uma falha de rede impede usar o animal antigo para preparar contato; permite retry.
