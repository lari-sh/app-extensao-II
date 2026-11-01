# Evidências — calendário de medicamentos

Data: 2026-10-31. Implementação em andamento na developer.
Design 4e738eb aprovado explicitamente; T001 registrada antes da implementação.

## Referência e domínio

Suíte anterior: 181 testes Flutter aprovados. Testes novos foram executados antes
dos modelos (falha por arquivos ausentes), depois aprovados com os modelos reais.
Suíte completa com domínio: 185 testes aprovados. flutter analyze sem problemas.
Modelos Freezed para tratamento, programação, aplicação/eventos e snapshots.
Validações civis de entrada e capacidades usam referência de servidor; o app não
duplica a geração IANA. Limites e exclusividade dos modos cobertos no domínio.
Nenhum pacote novo. Fronteiras arquiteturais conferidas pela suíte existente.

## Pendências

Interfaces, Services/Repositories, RPCs funcionais, ViewModels, telas, Android e
CI do calendário ainda precisam das tarefas posteriores. Não declarar o calendário
funcional com apenas modelos. Ver tasks.md para o acompanhamento autoritativo.


## Fundação SQL privada

Migração 011 aplicada somente no Supabase local, após teste vermelho confirmado.
Suíte pgTAP: 149 testes aprovados em oito arquivos, incluindo 22 da fundação.
Verifica tabelas/ledger, equipe atual, anonimato, não equipe, sessão ausente/expirada,
revogação, auditoria/recibos sem leitura direta, DML direto negado, FK de animal
restritiva, unicidade de aplicação ativa e contador transacional inicial.
O schema público de animals não recebeu informações de medicação. As revisões
possuem referência deferida e IDs próprios, separados dos clinical_records legados.
Nenhuma migração de produção realizada; RPCs e jornada Android do calendário pendentes.


## Contratos, DTOs e Service

Contratos abstratos de Repository/Service, fakes controlados e relógio de teste
preparados. DTOs validam identificadores, versões, modos, datas civis/UTC, autoria,
páginas, limites e imutabilidade, descartando campos clínicos não relacionados.
Service encapsula SDK e usa RPCs estreitos; autor/hora real não são enviados pelo app.
Testes novos executados primeiro em vermelho; sete testes de DTO/Service passaram.
Suíte completa: 192 testes Flutter aprovados, flutter analyze sem problemas.
Erros SQL, AuthException, timeout e rede continuam tipados/sanitizados por Result.
As chamadas foram verificadas com HTTP controlado: as RPCs reais do calendário
continuam na próxima etapa; não confundir essa aprovação com integração funcional.
