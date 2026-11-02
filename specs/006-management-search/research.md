# Decisões de pesquisa

- **Busca no servidor, RPC nova.** list_managed_animals atual recebe somente situação
  e cursor; filtragem no app perderia animais de páginas não carregadas. RPC aditiva
  preserva os contratos e os testes do painel existente.
- **Autorização reutilizada.** private.is_staff_current() e as projeções atuais de
  manejo já verificam sessão/vínculo. A aba não será um novo mecanismo de permissão.
- **Nome parcial literal.** ILIKE com parâmetro, escapando %, _ e barra; evitar SQL
  dinâmico ou concatenar filtros OR vindos da interface. Acentos não são removidos
  nesta versão; não há normalização linguística implícita no requisito.
- **Debounce nativo.** Timer de dart:async + geração/contexto do request. Sem pacote
  de busca, sem baixar todo o catálogo, sem acesso Supabase em Widgets.
- **Aba separada.** Pedido literal da responsável; o protótipo mantém os três modos
  anteriores, com quarta aba visível e mesmas cores. Campo global sobre o Kanban
  foi considerado, mas não adotado porque alteraria o uso dos modos existentes.
- **Fotos pelos contratos atuais.** Nenhum bucket público e nenhuma URL assinada
  persistida. Revogação deve invalidar também a apresentação dos bytes privados.

Referências de código consultadas: SupabaseAnimalsService.listManagement,
AnimalsRepository/AnimalsRepositoryImpl, DashboardScreen e
202610310006_animal_writes.sql. Nenhuma incerteza técnica bloqueia a proposta;
o gate pendente é a aprovação visual. Não foram necessários agentes de pesquisa
para tecnologias novas: as decisões usam somente contratos e dependências existentes.
