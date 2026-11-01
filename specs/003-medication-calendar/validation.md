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
