# Contrato planejado da busca administrativa

RPC `search_managed_animals(p_name text=null, p_status text=null,
p_species text=null, p_cursor jsonb=null)` → `{items,total,cursor}`. Página fixa de
25 itens, ordem nome/id, com projeção de manejo atual. Cursor nulo na última página.
Contagem considera os mesmos filtros antes da paginação. Mudar qualquer filtro
reinicia o cursor no cliente; cursor malformado falha com erro de validação.

Nome null/vazio → todos autorizados. Trim, até 80 caracteres. Busca parcial ILIKE,
curingas tratados literalmente. Situação/espécie só aceitam enum válido. Nome com
apóstrofo permanece parâmetro; sem SQL dinâmico. Sem leitura de notas para pesquisar.
A chamada exige authenticated e private.is_staff_current(); anônimo, vínculo
inativo/ausente e sessão revogada devem falhar também por requisição direta.

Domain/Repository: searchManagement(filter, cursor?) → Result<ManagedAnimalsPage>.
Service traduz para RPC e saneia SDK/erros. VM recebe somente objetos de domínio,
mensagens em português e contrato Result. Nenhuma chave administrativa entra no app.

Contrato de interface DESIGN-SEARCH-001: quatro abas; nome+limpar; filtros
Situação/Espécie; total; cartões com foto/situação/publicação; Abrir ficha; mais;
vazio com limpar; falha com tentar novamente; retorno sempre à esquerda.
Protótipo é simulação em memória e não comprova autorização/consulta real.
