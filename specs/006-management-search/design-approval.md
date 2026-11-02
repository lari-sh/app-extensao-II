# DESIGN-SEARCH-001 — revisão v2

## Histórico e gate atual

- v1: proposta com quarta aba Busca e filtros de situação/espécie.
- A responsável aprovou a aparência da v1, mas pediu ampliar a busca para diferenciar
  nomes repetidos; aceitou nome ou código e espécie/sexo/cor/porte/situação.
- Em 2026-11-02 solicitou explicitamente substituir a aba por campo fixo após os
  totais, com resultado independente de Kanban, Lista ou Calendário, para nova aprovação.
- **Estado atual: aguardando aprovação expressa desta revisão concreta v2.**
  O pedido de atualização não é registrado como aprovação de um desenho ainda não visto.

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
T001 concluída para esta revisão; T002 aguarda a aprovação explícita da responsável.
MCP do design continua com Transport closed. Usada cópia versionada e prévia local,
sem afirmar sincronização com o arquivo remoto do projeto externo.

URL local da revisão: http://127.0.0.1:58800/management-search-proposal.html?revision=search-global-v2
Servidor temporário restrito a localhost; HTML versionado permanece no repositório.
