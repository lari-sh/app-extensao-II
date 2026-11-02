# Busca administrativa de animais — 006

Data: 2026-11-02. Branch de trabalho: developer, por instrução da responsável.
Solicitação: adicionar uma aba de busca no painel para funcionários encontrarem animais.
Estado: proposta visual e planejamento; implementação aguardando aprovação do desenho.

## Experiência

Como administrador ou funcionário ativo, quero localizar pelo nome um animal do
abrigo, combinar situação/espécie e abrir sua ficha de manejo. O visitante não deve
consultar esta busca. A busca cobre animais publicados, privados e adotados dentro
da autorização existente, e não somente os primeiros resultados já carregados.

## Requisitos

- 006-FR-001: aba “Busca” no painel, preservando Kanban, Lista, Calendário e demais
  componentes. Campo “Buscar pelo nome do animal”, limpar e filtros Situação/Espécie.
- 006-FR-002: nome parcial, sem distinguir maiúsculas/minúsculas, espaços externos
  removidos, até 80 caracteres; %, _ e barra tratados literalmente. Nome vazio busca
  todos os animais autorizados, sujeito aos filtros. Sem busca por notas clínicas.
- 006-FR-003: filtro de situação (todas/disponível/em tratamento/quarentena/adotado)
  e espécie (todas/cachorro/gato), cumulativos, paginação estável e contagem total
  correspondente no servidor; resultado além da primeira página deve ser encontrado.
- 006-FR-004: cartão informa foto/nome, características, situação e publicação.
  “Abrir ficha” usa o editor já existente; voltar preserva consulta/filtros e
  atualiza o resultado após edição. Busca não muda situação/publicação por si só.
- 006-FR-005: carregando, nenhum resultado, erro amigável/repetir e acesso revogado;
  mudanças de consulta cancelam logicamente respostas antigas e reiniciam paginação.
- 006-FR-006: acesso somente a funcionário/administrador ativos, também no servidor;
  nenhuma ampliação de RLS, nenhuma chave privilegiada no app. Logout/revogação
  descarta resultados e impede resposta tardia de restaurar dados privados.
- 006-FR-007: textos em português, código em inglês, sem dependência nova; layout
  validado em 320/390 px e escala de texto ampliada. Design explícito antes do Flutter.
- 006-CR-001: arquitetura da constituição/skill Flutter, Result tipado, unitários
  de VM/Repository/Service, Widget happy path/erro, SQL/HTTP de autorização e
  integração Android; documentação e commits por contexto na developer.

## Aceitação

1. “amo” encontra Amora; “ AMO ” tem o mesmo resultado; filtros combinados funcionam.
2. Animal fora da primeira página é encontrado sem carregar todas as páginas no app.
3. %, _ e apóstrofo não ampliam a consulta nem geram SQL dinâmico.
4. Zero resultados mostra limpar busca; falha permite tentar novamente sem perder texto.
5. Consultas rápidas A→B ignoram resposta tardia de A; revogação apaga o resultado.
6. Visitante e conta sem vínculo ativo recebem negação mesmo em chamada direta.
7. Os fluxos anteriores do painel continuam funcionando e sem perda de estado privado.
