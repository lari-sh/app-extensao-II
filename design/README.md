# Protótipo visual — Abrigo dos Anjos

Fonte: abrigo-dos-anjos-figma.html, com image.png como logo. Cópia versionada do
arquivo editável no projeto Open Design. O commit anterior preserva a referência
original com seis telas; a proposta acrescenta as telas 07, 08 e 09.

Para conferir, abrir o HTML em navegador ou a página raw do projeto no Open Design.
A lista lateral permite selecionar Calendário de medicações, Programar medicação
e Aplicação e histórico. Também é possível tocar em Calendário no dashboard ou
Adicionar medicação na ficha. Adicionar ?preview=screen-7 à URL apresenta somente
a tela mobile; usar screen-8 ou screen-9 para as demais. Sem parâmetro, aparece o canvas.

As imagens em previews/ são capturas da proposta a 390×844. As interações simulam
dados em memória e não se comunicam com o app/backend. Revisão/aprovação formal em
../specs/003-medication-calendar/design-approval.md; criar o desenho não autoriza
sua implementação no Flutter.

## Navegação de retorno — ajuste autorizado em 2026-11-01

Botões de Voltar ficam à esquerda, antes do título/conteúdo do cabeçalho.
No catálogo público, removido o rótulo Vitrine e movido o retorno para a esquerda.
Controles Fechar continuam com sua função e localização próprias; não foram
transformados em botões de retorno. Layout, cores e demais conteúdos preservados.

## Proposta de equipe e acesso — DESIGN-TEAM-001

Abrir [team-access-proposal.html](team-access-proposal.html), também acessível pelo
link lateral Equipe e acesso · proposta no protótipo principal. A proposta é uma
página separada para preservar as telas já aprovadas. Navegação: equipe, convidar
pessoa, aceite, recuperação de acesso, nova senha e contexto do painel.
Alternar Administrador/Funcionário na lateral permite conferir a entrada Equipe.
Os menus simulam alteração de perfil/desativação; convites simulam reenvio,
cancelamento e aceite. Nenhum e-mail ou conta é criado. Dados somente em memória.

Capturas em previews/team/. Planejamento e 26 tarefas em
../specs/005-auth-team-access/. Aprovação visual pendente em design-approval.md;
a existência deste protótipo não autoriza implementar as novas telas no Flutter.


## Busca global administrativa — DESIGN-SEARCH-001 v2

[management-search-proposal.html](management-search-proposal.html): campo fixo após
os totais, sem quarta aba ou botão de entrada na busca. Nome ou código automático
único; painel com espécie, sexo, cor, porte e situação. Resultados globais enquanto
houver critérios, inclusive em Calendário sem evento do animal; limpar restaura
modo, dia e rolagem. As três visualizações existentes continuam disponíveis.

Nomes repetidos são demonstrados por duas Lunas com códigos diferentes. Os códigos,
dados e fotos são ilustrativos, sem backend e sem implementação no app/banco.
Use ?preview=search&mode=calendar&q=Luna para ver só a tela mobile nesse cenário.
Estados na lateral; capturas em previews/search/, QA v2 320/390/1440 px PASS.
A v1 teve aprovação visual com pedido de ajustes; **esta revisão ainda aguarda
aprovação**. Spec/plano/modelo/contratos/guia/tarefas revisados em
../specs/006-management-search/. Não implementar Flutter/SQL antes do novo aceite.
