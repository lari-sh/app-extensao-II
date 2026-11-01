# Proposta visual — calendário de medicamentos

Data: 2026-10-31. Estado: design aprovado explicitamente pela responsável.
Aprovação: “Aprovo o design. Pode iniciar a implementação do calendário de
medicamentos conforme o plano”. Referência: commit visual 4e738eb, telas 07/08/09.
T001 concluída. A implementação está autorizada com testes, Android, documentação
e commits por contexto na developer; novas alterações de layout exigem autorização.

## Artefatos

Fonte versionada: design/abrigo-dos-anjos-figma.html e design/image.png.
Arquivo de trabalho do Open Design atualizado com a mesma fonte.
Prévia de imagens em design/previews/:
calendar.png, schedule-fixed.png, schedule-interval.png e application.png.

- screen-7: cabeçalho/indicadores/abas mantidos; calendário mensal, seleção do dia,
  aplicações por animal/horário, estado e acesso aos detalhes.
- screen-8: medicamento, instruções, período com data/hora inicial e final,
  horários fixos ou intervalo em horas/minutos e prévia das próximas aplicações.
- screen-9: horário previsto, autor/horário real quando realizada, histórico e
  correção justificada que preserva o registro anterior.

As telas originais foram mantidas. A aba Calendário liga à proposta; Adicionar
medicação liga ao novo formulário. As novas composições reutilizam paleta,
tipografia, bordas e ritmo dos componentes existentes. O canvas ganhou três
artboards e atalhos. Corrigidos IDs ausentes do canvas necessários à navegação.

## Interações ilustrativas

Navegar mês/dia; visualizar dia vazio; abrir aplicação; marcar uma aplicação
atrasada; conferir autoria/hora demonstrativas; corrigir com motivo e manter os
eventos originais. Alternar modo e editar horários atualiza a prévia visual.
Dados são ilustrativos e em memória. Não há gravação no Supabase, integração com
API externa, efeito no emulador nem alteração em lib/, pubspec ou migrations.
Salvar programação apresenta feedback de prévia, sem prometer persistência real.

## Conferência

Renderização em Edge headless com Playwright isolado em .tools, sem adicionar
pacote ao app. Verificados os fluxos acima, ausência de erros JavaScript e de
rolagem horizontal nas três telas em 320 px e 390 px. Imagens conferidas visualmente.
A página servida pelo Open Design respondeu HTTP 200 contendo screen-7/8/9.
Comparação DOM confirmou preservação das seis telas anteriores, normalizando
apenas seleção/espaços e as duas ligações de navegação acrescentadas. Navegação
a página servida validada: dashboard → calendário e ficha → programação.
Flutter tests não foram executados: esta alteração modifica apenas o protótipo.

## Aprovação registrada

A responsável aprovou a composição do calendário, o formulário e os detalhes
antes da implementação. Não houve aprovação por silêncio. Manter esta referência
na conferência visual do app, sem ampliar o escopo da autorização.
