# DESIGN-SEARCH-001

Solicitado em 2026-11-02: aba para funcionários encontrarem os animais no painel.
**Status: aguardando revisão da proposta concreta pela responsável.** O “ok” para
preparar a proposta não é registrado como aprovação de um desenho ainda não visto.

Arquivo: design/management-search-proposal.html. Mudanças propostas: quarta aba Busca,
campo de nome/limpar, situação/espécie, total, resultados e abertura do editor existente.
Cores, tipografia, cabeçalho, contadores, retorno à esquerda e modos anteriores
preservados como referência. Motivo: evitar procurar manualmente em dezenas de cartões.
Aprovação pendente; nenhum Widget/ViewModel/Repository/RPC da busca implementado.


## Evidência da proposta — 2026-11-02

Playwright/Edge: PASS em 320/390/1440 px; sem overflow horizontal, retorno à
esquerda, nome parcial/trim/case, filtros, mais resultados, limpar, nenhum resultado,
loading e falha/retry com consulta preservada. Fotos ilustrativas carregadas;
nenhum request a Supabase/Auth/Functions e nenhum erro JavaScript.
Imagens em design/previews/search/{results,empty,error,overview}.png.
Link local da revisão: http://127.0.0.1:58800/management-search-proposal.html
O servidor é temporário e restrito a localhost; HTML versionado permanece no repo.
MCP do design retornou Transport closed; utilizada a cópia versionada e prévia local,
sem afirmar sincronização com o arquivo remoto aberto anteriormente.
