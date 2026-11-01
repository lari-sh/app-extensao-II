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


## Geração e gravação de tratamentos

Migração 012 aplicada somente localmente. Teste de contrato executado primeiro em
vermelho pela ausência das RPCs; depois 19 casos de programação aprovados.
Suíte completa pgTAP: 168 testes em nove arquivos, sem falhas. Casos: fixos e
intervalos, limites inclusivos, meia-noite, datas inválidas, gaps/folds IANA de
São Paulo, horários duplicados, 10.000 aplicações e rollback do excesso,
campos de autoria indevidos, período/intervalo inválidos, digest/replay/conflito,
listagem e recibo privado negado após revogação.
Resolver civil e geração ficam no servidor; o corpo da RPC fixa UTC e preserva
America/Sao_Paulo no contrato. A verificação de sessão da medicação usa relógio
real também após esperas/generação. Recibo e contador são transacionais.
Nesta etapa save cria tratamentos e rejeita edição; revisão/interrupção pertencem
à US4. Integração Repository/VM/tela e Android ainda pendentes.


## Repository real

MedicationsRepositoryImpl consome o Service, normaliza campos editáveis e mapeia
os modelos imutáveis. Confirmações precisam corresponder à chave/alvo solicitados;
respostas incompatíveis não podem virar sucesso. Validação de IDs, versões,
períodos/cursor e motivos evita chamadas inválidas, sem mover o fuso para o cliente.
Testes do Repository escritos antes da implementação e aprovados com Service falso:
normalização, DTO→domínio, páginas, autoria/eventos, Result, reconciliação,
falhas tipadas/inesperadas e recibo divergente. Suíte Flutter completa: 198 PASS;
flutter analyze sem problemas. Android ainda não validado para o calendário.

Correção de evidência do Repository: a primeira análise final tinha dois avisos de blocos if no teste; foram corrigidos antes de avançar. Nova execução de flutter analyze sem problemas e os seis testes do Repository novamente aprovados. A suíte completa de 198 testes havia passado; a correção alterou apenas delimitadores no teste.
