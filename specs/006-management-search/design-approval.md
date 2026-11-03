# DESIGN-SEARCH-001 — revisão v2

## Histórico e gate atual

- v1: proposta com quarta aba Busca e filtros de situação/espécie.
- A responsável aprovou a aparência da v1, mas pediu ampliar a busca para diferenciar
  nomes repetidos; aceitou nome ou código e espécie/sexo/cor/porte/situação.
- Em 2026-11-02 solicitou explicitamente substituir a aba por campo fixo após os
  totais, com resultado independente de Kanban, Lista ou Calendário, para nova aprovação.
- **Estado atual: revisão v2 aprovada expressamente pela responsável em 2026-11-02.**
  Resposta registrada: “Aprovar revisão v2”. Autorizada a implementação conforme o plano, com os testes obrigatórios.

## Proposta vigente

Campo “Nome ou código do animal” fixo abaixo dos totais, antes dos três modos.
Sem quarta aba e sem botão para entrar em busca. Botão de filtros abre painel com
espécie, sexo, cor, porte e situação; aplicar/limpar/cancelar e chips ativos.
Resultados globais com foto, nome, código, características e acesso à ficha, sem
limitar ao conteúdo carregado ou ao dia do calendário. Limpar retorna ao modo/data.

Motivo: encontrar o animal sem trocar de tela nem confundir fichas homônimas.
Exemplo: duas Lunas, #A0024 e #A0107; Amora encontrada no Calendário sem aplicação.
Paleta, tipografia, totais, retorno à esquerda e os três modos seguem a referência.
Arquivo: design/management-search-proposal.html. Protótipo em memória, códigos e
fotos ilustrativos; não foram criados códigos reais ou alterados app/banco nesta revisão.

## Validação desta revisão

QA v2 Playwright/Edge PASS a 320/390/1440 px: campo fixo abaixo dos totais e antes
somente dos três modos; nomes homônimos, código completo normalizado, Amora/Theo
fora da agenda/página carregada encontrados; cinco filtros e cancelamento de
rascunho; limpar texto/tudo; preservação de data e rolagem; paginação simulada,
vazio/loading/erro-retry; retorno à esquerda, fotos carregadas e nenhum erro JS.
Sem requisições a Supabase/Auth/Functions. Isto valida o protótipo, não código Flutter.

Capturas atuais substituem as da v1 em design/previews/search/:
results.png (duas Lunas no contexto Calendário), code.png, filters.png,
pinned-calendar.png (data restaurada), empty.png, error.png e overview.png.
T001 e T002 concluídas; execução das tarefas de implementação autorizada.
MCP do design continua com Transport closed. Usada cópia versionada e prévia local,
sem afirmar sincronização com o arquivo remoto do projeto externo.

URL local da revisão: http://127.0.0.1:58800/management-search-proposal.html?revision=search-global-v2
Servidor temporário restrito a localhost; HTML versionado permanece no repositório.


## Revisão v3 — decisão vigente da responsável (2026-11-02)

Substitui a apresentação v2 em lista global. O campo continua fixo e a consulta
continua abrangendo o cadastro completo antes da paginação. A apresentação
respeita o modo: Kanban conserva as colunas e filtra cartões; Lista filtra seus
itens; Calendário conserva mês/data e exibe somente as medicações daquele dia
dos animais correspondentes. Não mover para outra data. Um animal sem medicação
no dia produz agenda vazia, nunca uma lista de fichas. Limpar restaura o contexto.

A alteração visual foi solicitada expressamente pela responsável e a restrição
às medicações do dia foi confirmada em resposta. Não é necessário reconfirmar
essa mesma alteração. Protótipo management-search-proposal.html atualizado para
v3; as evidências anteriores v2 permanecem como histórico, não como UX vigente.


## DESIGN-ADMIN-NAV-001 — menu administrativo

Em 2026-11-02 a responsável aprovou expressamente **Aprovar menu ⋮**, após ver
management-navigation-proposal.html?revision=admin-menu-v1&mode=calendar e captura.
O menu substitui o ícone isolado de saída no cabeçalho; contém Equipe e acessos
(somente administradores) e Sair da conta. Atualizar permanece no topo e Voltar
à esquerda. Retirar o botão Equipe do corpo da agenda, mantendo acesso nos três
modos. Não alterar a entrada pública nem criar uma tela vazia de configurações.
A aprovação não inclui as alterações de dimensões pendentes T019/T020.

Fundamento: Android recomenda configurações em navegação secundária, como topo
ou menus: https://developer.android.com/design/ui/mobile/guides/patterns/settings
https://developer.android.com/develop/ui/views/components/appbar/actions
A escolha de menu neste painel é uma decisão de projeto, não uma imposição da API.


## DESIGN-ADD-TOP-001 — proposta, aguardando aprovação

Pedido: dar maior visibilidade ao cadastro e aproveitar a altura inferior do
Kanban. Proposta: botão + Animal no cabeçalho, com nome acessível Adicionar animal;
Atualizar passa ao menu ⋮, junto dos acessos/saída já aprovados. Remover o FAB e
reduzir a reserva inferior de 90 dp do Kanban/Lista, respeitando SafeArea. Preservar
as regras atuais de acesso e de visibilidade no calendário/busca; sem mudança
nas larguras dos cartões ou nas regras clínicas.

Prévia separada: design/management-add-animal-proposal.html?mode=kanban;
captura: design/previews/add-animal-top-v1.png. Verificação no navegador: cabeçalho
sem overflow em 320/390 px, botão de 92 × 48 px e colunas usando a altura restante.
Proposta de layout apenas: não representa teste Flutter/Android nem alteração
já aplicada ao aplicativo. T030 aguarda aprovação; T031 depende dela.

Referência sobre ações no topo, sem impor esta disposição específica:
https://developer.android.com/develop/ui/compose/quick-guides/content/display-app-bar


## DESIGN-ADD-TOP-001 — aprovação e ajustes explícitos

Local aprovado pela responsável: cabeçalho. Ajustes exigidos em seguida:
botão vermelho da marca (#C51D2A), texto completo Adicionar animal, e trocar
Manejo · quantidade por Total: quantidade de animais, usando contagem real no VM.
Atualizar no menu e retirada do FAB/reserva de 90 dp mantidos. Em 320 dp ou texto
ampliado, o botão continua no cabeçalho abaixo do título, sem abreviar/cortar.
Sem nova confirmação para esses ajustes expressamente solicitados. Larguras dos
cartões permanecem fora desta mudança; T019/T020 ainda pendentes.


## Feedback subsequente — cabeçalho comprimido

A responsável rejeitou o botão com texto completo na mesma linha por comprimir
o título. Cor vermelha, rótulo completo e Total permanecem solicitados. Revisão v3
propõe uma linha própria abaixo do título em todas as larguras, alinhada à direita,
sem comprimir o texto e preservando a extensão inferior do Kanban. Nova disposição
aguarda avaliação; não está aplicada ao Flutter. T033 acompanha a revisão.
