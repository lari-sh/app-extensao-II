# Busca global administrativa de animais — 006

Data: 2026-11-02. Branch: developer. Revisão de escopo v2.
Pedido vigente: campo fixado após o quadro de totais, sem aba/botão para acessar
busca; nome ou código e filtros de espécie, sexo, cor, porte e situação. A busca
retorna animais independentemente de o funcionário estar no Kanban, Lista ou Calendário.
**Entrega atual: somente design e planejamento, aguardando aprovação da revisão.**

## Experiência e decisões

O funcionário/administrador digita no campo sempre visível logo abaixo dos totais.
Não existe uma quarta aba. Os três modos existentes continuam disponíveis abaixo
do campo. Um botão de filtros abre cinco controles; ele não é uma entrada para a busca.
Enquanto texto ou filtros estiverem ativos, a área central mostra resultados globais
com foto, nome, código, sexo/porte/cor, situação, publicação e acesso à ficha.
O modo selecionado continua indicado. A busca não exige que o animal esteja na
coluna carregada, na página atual, tenha medicação ou apareça no dia da agenda.
Limpar tudo restaura o modo/data/rolagem anteriores; não redefine a agenda.

## Requisitos

- 006-FR-001: campo “Nome ou código do animal” fixo abaixo dos totais e antes dos
  três modos. Sem quarta aba ou botão que precise ser acionado para pesquisar.
  Permanece visível ao rolar resultados, Kanban, Lista e Calendário.
- 006-FR-002: texto com trim e até 80 caracteres. Nome parcial sem distinguir caixa;
  %, _ e barra são literais. Texto no formato #?A + quatro ou mais algarismos é
  interpretado como código completo, com # opcional e A sem distinguir caixa.
  Outros textos buscam nome. Não inclui pesquisa em notas clínicas ou microchip.
- 006-FR-003: cinco filtros cumulativos e opcionais: espécie (dog/cat), sexo
  (female/male), porte (small/medium/large), situação (available/treatment/quarantine/
  adopted) e cor textual parcial com trim, case-insensitive, até 80 caracteres.
  Campo livre de cor respeita o cadastro atual, sem impor paleta/enum novo.
  Painel de filtros tem aplicar, limpar e cancelar; cancelar não altera a consulta.
- 006-FR-004: resultados com foto, nome e código legível único, características,
  situação/publicação e “Abrir ficha” para o editor já existente. Voltar preserva
  busca/filtros e atualiza resultados; busca não altera animal por si só.
- 006-FR-005: carregando, vazio, erro/retry e revogação. Nova consulta/filtro reinicia
  cursor/rolagem dos resultados e ignora respostas antigas, inclusive fotos. Limpar
  somente texto mantém filtros; limpar busca inteira remove texto e todos os filtros.
- 006-FR-006: somente vínculo e sessão ativos, também em requisição direta ao servidor.
  Visitante/conta sem vínculo/sessão revogada não podem ler resultados privados.
  Logout/revogação descarta consulta e dados privados. Sem ampliar RLS ou expor chaves.
- 006-FR-007: interface em português, código em inglês, sem pacote novo. Preservar
  estilo/retorno à esquerda; validar 320/390 px e texto ampliado. Aprovação explícita
  da revisão global antes da implementação Flutter/SQL.
- 006-FR-008: código automático gerado no servidor, único, não editável e imutável.
  Formato A0001…A9999, depois A10000 etc., sem truncar. Preencher os animais antigos
  uma única vez, preservando UUID, fotos e histórico. Não reciclar códigos; lacunas
  são permitidas. Renomear, adotar, publicar ou mudar situação não altera o código.
- 006-FR-009: servidor aplica busca/filtros a TODOS os animais autorizados antes de
  contar/paginar, incluindo privados/adotados, sem limitar ao modo, coluna, página,
  mês ou dia. Página de 25, ordem nome/UUID e cursor estável. Busca ativa substitui
  temporariamente o conteúdo central por resultados globais; limpar restaura contexto.
- 006-CR-001: MVVM/ChangeNotifier/Freezed, contratos Repository, Services e Result;
  unitários, Widgets, SQL/HTTP e Android; documentação/commits por contexto na developer.

## Aceitação

1. Nas três visualizações, “Luna” retorna as duas fichas homônimas, diferenciadas
   por código/foto/características. “ #a0024 ” retorna somente o código A0024.
2. No Calendário do dia 3, buscar Amora sem medicação agendada a encontra. Limpar
   devolve a agenda do dia 3. Em Kanban, pesquisa não depende da coluna carregada.
3. Animal fora da página inicial é encontrado sem carregar todas as páginas no app.
4. Combinar os cinco filtros encontra a Luna fêmea, preta, pequena e em quarentena;
   cor “preto” inclui pelagem composta que contenha esse texto. Sem cor inclui nulos.
5. Nome vazio e sem filtros devolve o modo anterior, sem lista global residual.
   Filtros sem nome fazem busca global; limpar texto não apaga esses filtros.
6. %, _, barra e apóstrofo não ampliam a consulta nem geram SQL dinâmico.
7. Respostas tardias A→B, fotos antigas e respostas após logout são descartadas.
8. Código é único sob cadastros concorrentes, estável após edição e cresce além de
   quatro dígitos. Migração não perde fotos, históricos ou relações existentes.
9. Abrir/fechar filtros sem aplicar não muda a busca; erro preserva os critérios.
10. Campo fica na mesma posição ao rolar e trocar modos; visitante e acesso direto
    indevido continuam negados. As nove jornadas Android existentes são preservadas.
