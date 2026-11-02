# Plano técnico — busca administrativa

**Branch:** developer (instrução da responsável; 006 é contexto de feature, não nova branch).
**Data:** 2026-11-02. **Spec:** [spec.md](spec.md).
**Gate atual:** aprovação de DESIGN-SEARCH-001 antes de mudar o Flutter.

## Resumo

Acrescentar modo Busca ao Dashboard com nome parcial e filtros de situação/espécie,
consulta paginada no servidor e abertura da ficha de manejo existente. Preservar os
outros modos, contadores globais e autorização. Busca não altera dados de animais.

## Contexto técnico

Flutter 3.41.1/Dart, ChangeNotifier, Freezed, Provider, Result, supabase_flutter e
PostgreSQL local/Supabase existente. Android prioritário; iOS exige validação própria.
Nenhum pacote novo. Reutilizar AnimalsRepository, SupabaseAnimalsService e os tipos
de página/DTO atuais; acrescentar filtro imutável e ViewModel próprios para a busca.
Não filtrar apenas os 50 itens previamente carregados: o servidor aplica nome,
situação e espécie antes de contar e paginar. Página de 25 itens, ordem nome/id.
Meta inicial: consulta de 5.000 registros locais em até 2 s, medida em teste;
sem incluir garantias de latência de rede ou inicialização fria do ambiente.

## Checagem da constituição e regras da responsável

- PASS: UI por funcionalidade; Services/Repositories/Domain por tipo. Nenhum SDK no VM.
- PASS: VM mantém texto/filtros, validação, debounce, geração da consulta, estados e
  descarte por perda de acesso; Widgets somente exibem/enviam eventos.
- PASS: Service encapsula RPC/DTO/erros; Repository abstrato e Result independentes
  do SDK. Servidor valida vínculo/sessão atual, sem depender de ocultar a aba.
- PASS: plano prevê unitários de regras e Widget happy path, SQL/HTTP e Android.
- PASS: sem dependências novas; preservar cobertura de linhas global >=95%, sem
  excluir código ou enfraquecer asserts para obter o número.
- GATE VISUAL: regra expressa da responsável exige informar/justificar/aprovar
  mudança de layout. Proposta separada mostra a quarta aba; não implementar até
  aprovação expressa, mantendo o protótipo anterior como referência.
- PASS pós-design: proposta usa a paleta, tipografia, cartões e retorno à esquerda
  existentes; requer validação 320/390 px e texto ampliado no Flutter.

## Alterações previstas

1. Migration aditiva de `search_managed_animals`, sem mudar assinatura/semântica de
   list_managed_animals nem políticas RLS existentes. EXECUTE apenas authenticated;
   private.is_staff_current() na entrada; search_path vazio e SQL estático.
2. Service recebe filtros validados e cursor opaco; Repository mapeia página;
   usar as projeções/visibilidade de fotos atuais. Notas clínicas não são pesquisadas.
3. `ManagedAnimalSearchViewModel` e estado Freezed, Timer de 300 ms, busca imediata
   ao enviar pelo teclado, prevenção de submit paralelo, controle de respostas
   antigas por geração e contexto privado. Limpar reinicia paginação/filtros;
   tratamento de erro mantém a consulta para tentar novamente.
4. Nova aba `Busca` no enum/modos do painel. Resultados reutilizam o editor e a
   entrega de fotos já autorizada. Reutilizar o cartão existente ou extrair apenas
   apresentação com callbacks; testes devem garantir que os modos antigos não mudem.
5. Ao voltar da ficha, atualizar a mesma busca; logout/revogação limpa resultados
   e invalida requests, inclusive carregamento de fotos. Não liberar gestão de equipe
   para funcionário nem expor resultados a visitante/conta sem vínculo.

## Estrutura prevista

- lib/domain/models/managed_animal_search_filter.dart
- lib/domain/repositories/animals_repository.dart (contrato aditivo)
- lib/data/services/{animals_service,supabase_animals_service}.dart
- lib/data/repositories/animals_repository_impl.dart
- lib/ui/features/animals/view_models/managed_animal_search_view_model.dart
- lib/ui/features/animals/views/managed_animal_search_panel.dart
- integração em dashboard_screen.dart e composição existente
- supabase/migrations/ migration numerada na implementação
- testes nas camadas correspondentes e integration_test/management_search_flow_test.dart

## Validação

Ver quickstart.md e contracts/search.md. Cobrir nome parcial/trim/case, filtros,
curinga literal, cursor inválido, resposta tardia, dispose, logout/revogação,
acesso direto indevido, busca além da primeira página, erro/retry e edição/retorno.
Executar gates existentes e CI, preservando as nove jornadas Android e os dados
manuais. Documentação e commits por contexto, sempre na developer.

## Escopo excluído

Não inclui OCR, IA, busca em notas clínicas, novo identificador humano, WhatsApp,
multiplos abrigos, redefinição de situação clínica ou mudanças em telas públicas.
Não há hooks de extensão: .specify/extensions.yml ausente na consulta inicial/final.
