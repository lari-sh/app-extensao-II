# Modelo de busca

`ManagedAnimalSearchFilter` imutável: name (trim, até 80 caracteres), status opcional
(available/treatment/quarantine/adopted) e species opcional (dog/cat).
`ManagedAnimalSearchState` imutável: query/filtros, itens, total, cursor,
loading/loadingMore, mensagem e geração/contexto privado vigente. Senhas/tokens
não pertencem ao estado. Reutilizar `ManagedAnimal` e `ManagedAnimalsPage` atuais.

Transições: abrir→carregar; editar filtro→nova geração/página inicial; sucesso→dados;
erro→mensagem+consulta preservada; mais→anexar apenas mesma geração sem duplicar IDs;
voltar da ficha→reconsultar; revogação/logout/dispose→invalidar/descartar resposta.
Não criar tabela nem coluna para busca. Cursor contém par nome/id, validado no
servidor e associado aos mesmos filtros; cliente não o interpreta como SQL.
