# Validar busca administrativa

## Antes da implementação

Abrir design/management-search-proposal.html. Em Busca, pesquisar “ AMO ”, limpar,
filtrar Gato, combinar situação, abrir ficha, testar estados vazio/loading/erro na
lateral e alternar os modos anteriores. Conferir a 320/390 px. Aprovação visual
expressa deve ser registrada em design-approval.md antes de mudar Flutter.

## Após implementação (pendente)

1. Preparar ambiente local de teste separado ou fixtures exclusivas com animal além
   da página inicial; não resetar o banco com cadastros manuais.
2. Rodar unitários/Widgets Flutter, analyze/geração/formato e medir cobertura >=95%.
3. Rodar pgTAP e HTTP com visitante, sem vínculo, funcionário, administrador e
   sessão revogada. Testar %/_/apóstrofo, combinações e cursor inválido.
4. No Android, funcionário busca animal além da primeira página, abre/volta da ficha,
   muda filtro, limpa, recebe zero resultados e faz logout. Confirmar limpeza de dados.
5. Reexecutar as nove jornadas existentes; registrar run/SHA/artifact da CI e docs.

iOS precisa de Mac/Xcode para validação própria. Sem nova dependência no pubspec.
