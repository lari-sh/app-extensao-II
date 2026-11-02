# Contratos — busca global v2

## Código

Coluna animal_code gerada no servidor, unique/not null após backfill e imutável.
Prefixo A + sequência com mínimo quatro dígitos, expansível após 9999. Código não
é editável nos payloads do app e não concede permissão. UUID/relacionamentos atuais
permanecem. Migration e código implementados após aprovação visual v2; evidências em validation.md.

## RPC e domínio

Nova RPC search_managed_animals(p_query text=null, p_species text=null,
p_sex text=null, p_color text=null, p_size text=null, p_status text=null,
p_cursor jsonb=null) → {items,total,cursor}; página fixa de 25, ordem nome/UUID.
Itens incluem código legível e projeção de manejo autorizada. Total considera os
mesmos critérios antes da paginação. Cursor nulo na última página; cursor inválido
é falha de validação. Não há parâmetro de modo/coluna/dia/mês ou de medicação.

Query/cor com trim e máximo 80. Query no formato #?A[0-9]{4,} procura código exato
normalizado para uppercase e sem #; demais textos procuram nome parcial. Nome/cor
ILIKE literal com %, _ e barra escapados; apóstrofo permanece parâmetro. Filtros de
enum só aceitam valores do schema. Cor vazia/null não filtra; cor ativa exclui null.
Nenhuma consulta de notas clínicas/microchip. Sem critérios, VM restaura modo normal;
RPC vazia continua definida para todos os animais autorizados em chamadas diretas.

EXECUTE authenticated + private.is_staff_current() na função. Anônimo, conta sem
vínculo, vínculo inativo e sessão revogada falham por chamada direta. Nenhum relaxamento
RLS/Storage. Fotos privadas seguem o contrato atual e a sessão vigente.

AnimalsRepository.searchManagement(filter,cursor?) → Result<ManagedAnimalPage>.
Service encapsula SDK/RPC, Repository valida/mapeia e VM coordena regras. Result
não expõe exceção ou tipo Supabase à UI.

## Interface DESIGN-SEARCH-001 v2

Campo fixo após totais e antes dos três modos, sem aba/botão de acesso à busca.
Painel de cinco filtros (espécie, sexo, cor, porte e situação), aplicar/limpar/cancelar
e chips ativos. Resultados globais aparecem mesmo em Calendário sem evento do animal;
foto/nome/código/características/situação/publicação/Abrir ficha. Vazio, loading,
erro/retry e mais. Limpar tudo restaura modo/data/coluna/rolagem; limpar só texto
mantém filtros. Critérios não são resetados ao trocar o modo. Retorno à esquerda.
Protótipo simula dados em memória, sem comprovar backfill, RPC ou autorização reais.


### Compatibilidade de operações antigas

Resultados imutáveis de write_operations anteriores à migration não contêm
animal_code. O domínio aceita código ausente somente para permitir esses replays
legados, sem reescrever auditoria nem inventar identificadores. Quando presente,
o código deve ser canônico; a nova busca exige código válido em todos os itens.
Os registros atuais do servidor foram integralmente preenchidos pelo backfill.


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
