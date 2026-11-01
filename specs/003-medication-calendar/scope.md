# Calendário de medicações — definição da responsável

Status: escopo registrado; planejamento técnico e implementação pendentes.
Origem: esclarecimento da responsável em 2026-10-31. Complementa a aba Calendário
já prevista no protótipo; não altera a contagem das 108 tarefas originais.

## Comportamento solicitado

- **003-FR-001**: Equipe acessa um calendário real, semelhante à agenda de um
  celular, com marcação dos dias que possuem aplicações de medicamentos.
- **003-FR-002**: Ao selecionar um dia, a agenda mostra os compromissos em ordem
  de horário, identificando medicamento e animal. Um mesmo horário pode conter
  aplicações de animais diferentes, sem agrupar ou ocultar essas identidades.
- **003-FR-003**: Comportamento de lista de tarefas: permitir registrar a aplicação
  como realizada e distinguir aplicações ainda pendentes. O contrato de conclusão,
  correção e atraso será detalhado antes da implementação.
- **003-FR-004**: Gerar os compromissos automaticamente a partir do tratamento
  cadastrado na ficha do animal, evitando cadastrar a mesma informação na agenda.
- **003-FR-005**: Tratamentos precisam de dados estruturados de medicamento,
  período e horários. Registros antigos são textos livres: não extrair datas,
  horários ou instruções por inferência nem criar compromissos fictícios.
- **003-FR-006**: A agenda e os tratamentos são privados, acessíveis somente à
  equipe autorizada. Publicar o animal não publica suas medicações. Os dados
  públicos de vacinação/vermifugação continuam limitados ao contrato da ficha.
- **003-CR-001**: Manter MVVM, Repository/Services, Supabase, Result e o design
  autorizado; testes unitários das regras, Widget Tests e validação Android,
  testes de autorização/idempotência no backend e commits por contexto na developer.

## Decisões confirmadas pela responsável

- **003-FR-007**: Permitir horários fixos por dia (ex.: 08h e 20h) e recorrência por
  intervalo (ex.: a cada 8 horas), escolhidos no cadastro do tratamento. O modo por
  intervalo precisa de uma primeira aplicação com data e hora para ancorar a série.
- **003-FR-008**: Ao concluir uma aplicação, registrar automaticamente o funcionário
  autenticado e o horário real no servidor, além de preservar o horário previsto.
  A autoria vem da sessão verificada, sem permitir escolher outro funcionário.

## Decisões que o plano técnico precisa fechar

1. Campos do tratamento: nome do medicamento, início/término, horários fixos ou intervalo (ambos confirmados),
   instruções registradas pela equipe e relacionamento com o animal. Não transformar
   descrições clínicas legadas automaticamente em prescrições estruturadas.
2. Recorrência e fuso do abrigo (America/Sao_Paulo): travessia de meia-noite,
   intervalos, último dia e datas de término. Preservar os instantes e a exibição
   civil com regra explícita, sem depender do fuso configurado no aparelho.
3. Criação automática e alterações: evitar duplicar aplicações ao salvar/repetir
   uma requisição. Detalhar interrupção/edição do tratamento, preservação das
   aplicações realizadas e comportamento das aplicações futuras.
4. Conclusão/correção: autoria e horário real automáticos confirmados; detalhar concorrência entre
   funcionários e reenvio após falha de rede. Uma aplicação não pode ser registrada
   duas vezes por repetição da mesma operação.
5. Exibição de pendentes/realizadas/atrasadas/canceladas e regras para animal adotado,
   sem excluir histórico silenciosamente. Filtros por animal e medicamento devem
   ser avaliados no desenho antes de incluídos.
6. Navegação mês/dia e lista do dia na aba existente; comparar com o protótipo e
   apresentar qualquer mudança de layout que exija autorização. Notificações do
   sistema e sincronização com agendas externas não foram solicitadas.

## Próximas tarefas de planejamento e implementação

- [ ] C001 Especificar exemplos de recorrência, conclusão, interrupção e correção;
  fechar as decisões pendentes com a responsável antes de implementar dependências.
- [ ] C002 Preparar plano, modelo de dados, contratos Supabase e análise de
  conformidade com a constituição; justificar qualquer pacote novo antes de adicioná-lo.
- [ ] C003 Escrever testes SQL de equipe/sessão, geração sem duplicação, alterações
  e preservação de histórico; implementar migrations/RPCs transacionais.
- [ ] C004 Implementar modelos imutáveis, DTOs, Services e Repositories com testes
  de mapeamento, Result, autorização e repetição de operações.
- [ ] C005 Implementar e testar ViewModels de tratamentos e agenda: datas, horários,
  recorrência, seleção de dia, estados vazios, conclusão e falhas.
- [ ] C006 Integrar o tratamento na ficha administrativa e o calendário/lista do dia
  no desenho aprovado, com Widget Tests de caminho feliz e responsividade.
- [ ] C007 Validar Android e duas sessões, proteção do visitante e concorrência;
  atualizar documentação, CI e publicar cada contexto validado na developer.

Este documento registra o pedido; não declara a aba funcional nem substitui
especificação e plano técnico revisados.
