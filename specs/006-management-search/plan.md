# Plano técnico — busca global administrativa v2

**Branch:** developer, por instrução da responsável. **Data:** 2026-11-02.
**Spec:** [spec.md](spec.md). **Gate visual:** DESIGN-SEARCH-001 v2 aprovada em 2026-11-02.
A aprovação da v1 foi registrada, mas o novo pedido substitui a quarta aba por campo
fixo/global e acrescenta código e cinco filtros; a revisão concreta foi aprovada expressamente pela responsável.

## Resumo e experiência

Campo permanente logo abaixo dos totais, seguido dos três modos atuais. Não criar
DashboardMode.search nem aba/botão de acesso à pesquisa. Painel de filtros separado
permite espécie, sexo, cor, porte e situação sem ocupar toda a altura do celular.
Texto/filtros ativos exibem resultados globais na área central, qualquer que seja
mode. Sem critérios, retorna o modo anterior com data/coluna/rolagem preservados.
Não vincular a pesquisa aos eventos do calendário nem ao conjunto já carregado.

## Contexto técnico

Flutter 3.41.1/Dart, ChangeNotifier, Freezed, Provider, Result, supabase_flutter e
PostgreSQL/Supabase existentes. Android prioritário; iOS requer validação própria.
Nenhum pacote novo. Reavaliadas e mantidas Freezed para estado/filtro imutáveis,
Provider para composição e supabase_flutter exclusivamente em Services.
Página 25, ordem nome/UUID, total filtrado no servidor. Meta de medir até 2 s em
5.000 registros locais; rede e inicialização fria são registradas separadamente.
Não é necessário pg_trgm/unaccent novo nesta entrega; otimização posterior depende
medição. Busca textual não remove acentos nesta versão.

## Checagem constitucional e autorização visual

- PASS: UI por feature e dados/domínio por tipo; SDK apenas em Services/composição.
- PASS: VM controla critérios, validação, debounce, estados, generations e perda de
  acesso. Widgets só exibem e emitem eventos. Sem lógica Supabase em build.
- PASS: Repository abstrato/Result não expõem SDK. Novas RPCs verificam sessão/vínculo
  atuais; códigos não são segredo nem mecanismo de autorização.
- PASS: plano exige unitários de regras, Widget happy path/erro, SQL/HTTP e Android,
  cobertura global >=95% sem exclusões artificiais, nove jornadas anteriores preservadas.
- PASS: sem dependência nova; códigos gerados pelo servidor, não pelo celular.
- PASS: DESIGN-SEARCH-001 v2 aprovada expressamente; migrations e integração
  autorizadas e implementadas. Resultados dos gates registrados em validation.md.
- Rechecagem pós-design: paleta/tipografia/cabeçalho/totais/retorno à esquerda e os
  três modos preservados como referência; testes de 320/390 px e texto ampliado previstos.

## Implementação da revisão aprovada

1. Migration aditiva de animal_code em animals: sequência bigint de servidor,
   prefixo A, largura mínima quatro expansível, unicidade/NOT NULL e imutabilidade.
   Backfill determinístico por UUID em transação protegida; ajustar sequência após
   preenchimento. Não reutilizar/truncar código e não usar count(*)+1 no cliente.
   Manter UUID como PK e todas as relações/fotos/históricos. SaveAnimal não aceita
   código do app; editar o nome não o recalcula. Testar concorrência e rollback com lacunas.
2. Nova RPC search_managed_animals, aditiva às funções existentes. Aceita query,
   espécie, sexo, cor, porte, situação e cursor. Não recebe modo/dia/mês/coluna.
   EXECUTE authenticated, private.is_staff_current(), search_path vazio, SQL estático.
   Nome/cor por ILIKE literal parametrizado; código normalizado para igualdade exata.
   Validar enums, limites e cursor; filtros/contagem antes da página. Sem busca em notas.
3. Acrescentar código aos DTOs/modelos de domínio e projeções necessárias, com testes
   e atualização das factories/fakes. Backend/backfill antes de exigir campo no app;
   dado ausente/malformado é falha tratada, não UUID truncado inventado como código.
4. Service serializa critérios e captura SDK/erros; Repository valida/mapeia página.
   Foto segue os endpoints privados/públicos já autorizados, sem novo bucket público.
5. ManagedAnimalSearchViewModel e filtro/estado Freezed. Timer nativo 300 ms e busca
   imediata por teclado; geração + contexto privado invalidam respostas antigas/fotos.
   Nova consulta reinicia cursor/rolagem; paginação só anexa à mesma geração e critérios.
6. Dashboard continua com enum {kanban,list,calendar}. Coordenador/VM expõe hasCriteria
   e showGlobalResults. Renderização alterna corpo entre modo normal e painel global;
   busca/controlos fixos fora das rolagens. A decisão não fica em condições de build.
   Preservar VMs/ScrollControllers dos modos, mês/data do calendário e coluna Kanban;
   não desmontar/zerar agenda ao digitar. Trocar modo com busca mantém os resultados
   globais e só muda o contexto que será restaurado ao limpar.
7. View/painel de filtros tem rascunho de critérios, aplicar/limpar/cancelar e chips
   removíveis. Cancelar não publica estado novo; limpar texto conserva filtros;
   limpar busca remove todos. Editar/voltar da ficha revalida o contexto e reconsulta.
8. Logout/revogação limpa dados privados e invalida operações. Nenhum papel recebe
   novas capacidades de equipe. Não introduzir gravações de medicação ao pesquisar.

## Estrutura prevista

- Domain: Animal/ManagedAnimal com animalCode, ManagedAnimalSearchFilter e contrato
  aditivo em AnimalsRepository; sem tipos SDK na apresentação.
- Data: AnimalDto, AnimalsService/SupabaseAnimalsService/AnimalsRepositoryImpl.
- UI: managed_animal_search_view_model.dart, managed_animal_search_toolbar.dart,
  managed_animal_search_panel.dart e managed_animal_search_filters_sheet.dart;
  integração em DashboardViewModel/Screen e composição existente.
- Migration numerada somente na implementação; pgTAP/HTTP com fixtures próprias.
- Testes nas camadas e integration_test/management_search_flow_test.dart.

## Validação e limites

Ver contracts/search.md e quickstart.md: dois nomes iguais/códigos distintos, cinco
filtros, todos os modos, animal sem evento no dia, item além da primeira página,
restauração de data/rolagem, código >9999/concorrência, erro/retry/dispose/revogação,
Widgets compactos e autorização direta. Manter a cobertura e os fluxos anteriores.
A documentação e tarefas acompanham cada etapa validada e os commits na developer.
Não inclui microchip, OCR/IA, pesquisa em diagnóstico/notas, múltiplos abrigos ou
mudança do layout público. A execução foi autorizada após aprovação; progresso e evidências em validation.md.
.specify/extensions.yml ausente: hooks before_plan/after_plan não aplicáveis.


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


## Correção de interação — 2026-11-02

Substitui o debounce automático anterior: digitar não dispara consulta, não apaga
resultados e não revalida a sessão. A busca é confirmada pela ação Buscar do
teclado; aplicar/remover/limpar filtros são confirmações explícitas. O texto em
edição é separado dos critérios aplicados; refresh/retorno não confirmam rascunho.
Resultados de solicitações antigas são descartados. A correção não altera layout.
Equipe deve sair do conteúdo do calendário; proposta de menu no cabeçalho será
revisada antes da implementação visual, mantendo restrição a administradores.


## 006-FR-010 — busca pública combinada

O campo existente aceita nome, espécie e sexo, isolados ou combinados. Gato/gata/
gatos/gatas identificam espécie felina; cachorro/cachorra/cão/cães/cadela e plurais
identificam canina. Sexo é indicado por macho/fêmea (com ou sem acento); gato não
impõe sexo masculino, permitindo gato fêmea. Palavras restantes mantêm nome,
acentos e caixa originais. Keywords reconhecidas viram os filtros visíveis já
existentes; após confirmar, o campo mantém apenas o nome restante. Filtros não
informados continuam ativos até serem alterados ou limpos. Escolher um filtro
explicitamente prevalece sobre a mesma categoria digitada nessa confirmação.

Consultas com espécies ou sexos contraditórios no mesmo texto são recusadas com
mensagem portuguesa, sem consulta ao backend; limite de 80 caracteres. Sem IA,
API adicional ou dependência externa. Comparação normalizada somente para tokens
conhecidos; nome literal continua no filtro existente. Buscar no teclado confirma;
digitar preserva a lista. A ação Buscar da navegação inferior também confirma.
Espécie, sexo, porte e nome são enviados juntos a AnimalsRepository.listPublic,
antes da paginação no servidor e sob as políticas públicas existentes.

Testar gata fêmea/gato macho/gato fêmea, espécie ou sexo isolado, nome combinado,
maiúsculas/acentos/plurais, termos desconhecidos preservados, contradições,
limpeza, filtros existentes, erro de rede, resposta tardia e nenhum acesso privado.
Sem mudança de composição; placeholder passa a indicar nome/espécie/sexo.
