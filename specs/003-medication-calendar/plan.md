# Plano técnico — calendário de medicamentos

Branch Git: developer. Feature documental: 003-medication-calendar.
Data: 2026-10-31. Spec: [spec.md](spec.md). Estado: planejamento concluído,
implementação pendente, com gate visual explícito antes das Views novas.
Scripts executados com SPECIFY_FEATURE_DIRECTORY explícito e NO_PERSIST: não
mudar a branch nem o contexto persistido da adequação anterior.

## Resumo

Tratamentos privados estruturados na ficha geram aplicações finitas no Supabase.
Agenda mensal e lista do dia usam os instantes/civis do servidor. Conclusão registra
autor/hora reais; revisões e eventos preservam histórico. Dois modos de recorrência,
interrupção só de futuras e correções auditadas seguem as escolhas confirmadas.
Sem API externa de calendário e sem novos pacotes Flutter.

## Contexto técnico

Flutter 3.41.1/Dart 3.11; Android prioritário, iOS com validação futura própria.
PostgreSQL 17 via supabase_flutter 2.18.3, RPCs SQL/RLS; Freezed 3.2.5 e
freezed_annotation 3.1.0; provider 6.1.5+1; build_runner já aprovado. flutter_test,
integration_test, pgTAP e harness HTTP/Python já existentes. Manter lockfile.
Nenhuma dependência herdada muda de finalidade nesta etapa. SDK Flutter fornece
grade/calendário; funções IANA no servidor evitam pacote timezone no cliente.

Limites: até 366 dias civis inclusivos, 10.000 aplicações/revisão, paginação do dia
100 e tratamentos 50. Contagens mensais consultadas por intervalo indexado. Testar
carga limite sem truncamento; não carregar todos os tratamentos na memória da UI.
Sem comando offline, cron, notificações, Google/Outlook ou prescrição inferida.

## Constitution Check — antes e depois do desenho

| Regra | Antes | Depois / evidência planejada |
|---|---|---|
| CONST-001 arquitetura Flutter | Conforme | UI por feature; Data/Domain por tipo; estrutura abaixo |
| CONST-002 Views enxutas | Conforme | Apenas estado/eventos; composição inicia cargas fora de build |
| CONST-003 regras em VMs/domínio | Conforme | Calendar/Editor VMs; servidor é autoridade de recorrência |
| CONST-004 Services/Repositories | Conforme | MedicationsRepository abstrato, SDK só no Service/composição |
| CONST-005 unitários | Conforme | Tarefas de domínio, DTO, Service, Repository e todos os VMs |
| CONST-006 Widget feliz | Conforme | Editor, calendário e detalhe/auditoria com testes separados |
| CONST-007 Result | Conforme | Wrappers existentes, falhas tipadas e reconciliação por chave |
| CONST-008 pacotes justificados | Conforme | Nenhum pacote novo; Freezed/provider existentes |
| CONST-009 nomes/português | Conforme | Arquivos/classes inglês; rótulos/mensagens PT |
| CONST-010 commits | Conforme | developer, contexto, requisito 003-FR/CR real |
| Regra de design da skill constituição | Conforme | T001 gate visual antes de novas Views; não alegar artboard inexistente |

Revisão pós-desenho: sem conflito ou dispensa da constituição. A autorização visual
permanece pendente como dependência operacional, sem impedir testes/modelos/backend.
Não usar tabela de complexidade para autorizar mudança visual.

## Arquitetura e caminhos

- lib/domain/models/medication_treatment.dart: tratamento/revisão/rascunho Freezed.
- lib/domain/models/medication_application.dart: aplicação/evento/estado confirmado.
- lib/domain/models/medication_schedule.dart: modo, limites e validação pura de entrada.
- lib/domain/models/medication_agenda.dart: snapshot mensal, dia paginado e cursor.
- lib/domain/repositories/medications_repository.dart: contrato Future<Result<T>>.
- lib/data/models/medication_dto.dart: validação de respostas e isolamento de SDK.
- lib/data/services/medications_service.dart e supabase_medications_service.dart:
  chamadas RPC, captura SDK e DTOs; nenhum cálculo de recorrência na UI.
- lib/data/repositories/medications_repository_impl.dart: normalização, mapeamento,
  regras de acesso/Result e recibos. Sem cache privado persistido localmente.
- lib/ui/features/medications/view_models/medication_editor_view_model.dart:
  rascunho, validação, salvar/interromper, versões e resultado incerto.
- lib/ui/features/medications/view_models/medication_calendar_view_model.dart:
  mês/dia, células prontas, capacidades, atraso segundo snapshot do servidor,
  paginação, conclusão e correção. Relógio monotônico injetável só para atualizar
  rótulos relativos entre snapshots; decisão de escrever sempre cabe ao servidor.
- lib/ui/features/medications/view_models/medication_application_view_model.dart:
  detalhes/auditoria paginada, motivo, reconciliação e capacidade de correção.
- lib/ui/features/medications/views/medication_editor_panel.dart,
  medication_calendar_panel.dart e medication_application_details_sheet.dart:
  três interfaces com seus Widget Tests. Views não deduzem acesso nem datas.

Composição em lib/app/public_dependencies.dart e app_router.dart: registrar
Service/Repository e VMs no ProtectedScope. Usar isAuthorized/authorize/accessEpoch/
privateGeneration, listeners registrados/removidos e dispose. Mesmo usuário pode
revalidar rascunho; logout/troca/revogação descarta dados/recibos locais e respostas
antigas. Escopo de reconciliação pertence ao mesmo ator.

DashboardViewModel passa a usar DashboardMode kanban/list/calendar, preservando
comandos existentes enquanto migrados. Evento de seleção chama callback injetado
pela composição para carregar a agenda, fora de build. DashboardScreen mantém topo,
indicadores/abas e renderiza painel correspondente. Regressões Kanban/Lista obrigatórias.

No editor, vincular medicação ao animal confirmado, não a clinical_record nem a
formVersion: salvar o animal não pode apagar tratamentos ou o rascunho de medicação.
Tratamento só salva após existir animal_id e possui confirmação própria. Trocar o
animal invalida as respostas; ao salvar dados gerais, preservar o binding estável.
Sem Use Case adicional: regras compartilhadas puras no domínio e recorrência no
servidor já separam responsabilidades; reavaliar se houver duplicação real.

## Persistência, contratos e migrações

Ver [modelo](data-model.md) e [RPCs](contracts/rpc.md). Novas migrations aditivas
após a 010: 011 medication_foundation, 012 medication_treatments,
013 medication_agenda, 014 medication_completion, 015 medication_revision_audit.
Não editar migrations aplicadas. Todas implementam authorization/locks/Result
conforme contrato; não ampliar write_operations legado. Ledger e contador privados.

Testes SQL separados por fundação, recorrência, agenda, conclusão e revisão;
conflitos reais em supabase/tests/fixtures/medication_flow.py com duas conexões HTTP.
Fixtures locais exclusivas e limpeza própria, sem reset de dados manuais/produção.

## Sequência de entrega e testes

1. Preparar proposta visual autorizável (T001) e fundação/modelos/testes.
2. US1: programação e gravação transacional, DTO/Repository/VM e painel após aprovação.
3. US2: leitura mensal/dia com snapshot, células e painel aprovado.
4. US3: concluir/auditar; conflito, expiração, timeout e reconciliação.
5. US4: editar/interromper/corrigir com histórico; preservar atrasadas e snapshots.
6. Android em duas sessões, CI, documentação e commits/push por contexto validado.

Testes primeiro em cada história. Padrões existentes: service_result.dart,
repository_result.dart, OperationId e SessionViewModel. Nenhum teste de integração
substitui unidade/Widget. Referências exatas e dependências em tasks.md.

## Limites e aceitação final

Só declarar entregue com geração determinística, formato, análise, flutter_test,
pgTAP, HTTP concorrente, jornada Android e run CI/artifact confirmados. Execução
Windows não valida iOS. Mudanças posteriores de layout exigem nova autorização.
Nesta fase, não instalar pacote, criar tabelas ou alterar o app/emulador.
