# Evidências — planejamento e proposta

2026-11-01: spec, plano, pesquisa, modelo, contratos e 26 tarefas escritos.
Decisão expressa: primeiro administrador provisionado; demais convites no app,
com perfis Administrador e Funcionário. A skill de plano foi executada com feature
explícita e NO_PERSIST; git permanece na developer. Nenhum hook de extensão
registrado (.specify/extensions.yml ausente na verificação).

Constitution Check antes/após desenho técnico registrado em plan.md. SDK/plugins
somente em Services/composição, permissões server-side, Result, nomes/idioma,
testes por regra/tela e commits por contexto previstos. UI nova aguarda T003.
Research de convite conferiu fontes oficiais: sem PKCE no Admin Invite, conta
existente e reenvio tratados explicitamente, segredo restrito ao servidor.

Checklist de requisitos nesta etapa: decisões confirmadas registradas; cada uma
das quatro histórias tem tarefas e testes; permissão de funcionário e último
administrador têm negações; falhas e operação incerta não são sucesso de envio.
check-prerequisites retornou plan.md/tasks.md e documentos da feature.

Ainda não executados: implementação, Flutter/backend/Android/iOS e envio de e-mails.
Proposta visual/interações serão verificadas separadamente; aprovação pendente.

## T002 — proposta visual conferida

DESIGN-TEAM-001 em design/team-access-proposal.html. Sete visualizações conferidas
em 320, 390 e 1440 px: equipe, convite, aceite, recuperação, nova senha, convite
expirado e contexto do painel. Voltar à esquerda verificado geometricamente;
sem overflow horizontal do conteúdo/página e sem erros de JavaScript.
Simulações conferidas: envio/duplicata, cooldown de reenvio, cancelamento,
alteração de perfil, desativação, proteção do próprio administrador, visibilidade
por perfil, confirmação de senha divergente/correta, recuperação neutra e nova
senha. São interações HTML em memória, não testes Flutter/Supabase do produto.

Capturas visuais inspecionadas: equipe, convite e aceite, com logo/paleta atual.
Capturas de todas as sete telas e visão geral em design/previews/team/.
Protótipo principal preservado byte a byte após remover somente o novo script de
link lateral, comparado com a referência Git. Nenhum artboard anterior alterado.
MCP retornou Transport closed; nova página sincronizada no arquivo local do
projeto conhecido e seu link acrescentado pontualmente ao protótipo. HTTP 200
confirmado na página servida. Abertura solicitada no painel do chat; ferramenta
retornou queued. Link direto também está em design-approval.md.

Rastreabilidade conferida: 17 IDs de requisitos presentes nas tarefas, 26 IDs
únicos; T001/T002 concluídas, T003 de aprovação permanece desmarcada. Nenhum
arquivo lib/, pubspec, migration ou Function implementado nesta entrega.
Flutter/backend/Android não repetidos, pois o escopo é planejamento/protótipo.
A aprovação do usuário ainda é necessária e não foi presumida.
