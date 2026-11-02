# Modelo planejado — nome/código e busca global

## Animal e código

Animal mantém UUID como identidade relacional. Novo animalCode string única e
imutável, gerada apenas no servidor: A0001…A9999→A10000, sem truncamento/reciclagem.
A0000 não é gerado. Sequence bigint permite lacunas. Migração futura preenche
legados deterministicamente por UUID e preserva relações, fotos e históricos.
O payload de criação/edição do app não recebe código editável; Domain/DTO passam
as projeções de leitura somente após o backfill. Código ausente não é inventado.

## Critérios e estado

ManagedAnimalSearchFilter imutável: query (trim, até 80), species?, sex?, size?,
status? e color? (trim, até 80). Enums atuais; cor/nome em texto parcial literal.
Código é reconhecido pelo formato, normalizado para uppercase sem # e comparado
por igualdade exata. Sem critérios hasCriteria=false; só filtros também ativa busca.

ManagedAnimalSearchState: critérios aplicados e rascunho do painel, itens, total,
cursor, loading/loadingMore, erro amigável e geração/contexto privado. Sem tokens.
Reutilizar ManagedAnimalPage/ManagedAnimal com campo de código validado.

O dashboard mantém três modos e contexto próprio: mês/dia do calendário, coluna e
rolagens. Busca não cria quarto modo nem usa data da agenda como filtro implícito.
A visibilidade global é calculada no VM a partir dos critérios/estado, não em build.

## Transições

- Sem critérios→modo normal; editar texto/aplicar filtros→nova geração/página inicial.
- Rascunho alterado→não altera busca até aplicar; cancelar descarta rascunho.
- Só limpar texto→conserva filtros; limpar busca→remove tudo e restaura contexto.
- Trocar modo durante busca→preserva critérios/resultados globais; agenda não zera.
- Sucesso→dados; mais→anexar só na mesma geração sem duplicar UUID; erro→retry
  preservando critérios. Voltar da ficha revalida e reconsulta.
- Logout/revogação/dispose→invalidar geração e descartar dados/fotos privados.

Cursor: par nome/UUID, validado no servidor; mudar qualquer critério reinicia-o.
Não contém SQL nem limita a consulta à visualização anterior.


### Compatibilidade de operações antigas

Resultados imutáveis de write_operations anteriores à migration não contêm
animal_code. O domínio aceita código ausente somente para permitir esses replays
legados, sem reescrever auditoria nem inventar identificadores. Quando presente,
o código deve ser canônico; a nova busca exige código válido em todos os itens.
Os registros atuais do servidor foram integralmente preenchidos pelo backfill.
