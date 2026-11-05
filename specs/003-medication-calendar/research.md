# Pesquisa e decisões — calendário de medicamentos

Data: 2026-10-31. Pesquisa de documentação primária e inspeção do repositório.

## Recorrência e fuso

Decisão: PostgreSQL 17 gera a série. Horário fixo é civil no abrigo; intervalo é
duração decorrida ancorada em timestamptz. Guardar também a zona IANA; a RPC retorna
data/hora civil e offset para a apresentação. Não usar UTC-3 fixo nem o timezone do
aparelho para interpretar a agenda. Flutter constrói a grade por datas civis com SDK.
Motivo: evitar duplicação de regras IANA no cliente e divergência entre modos.
Alternativas: pacote timezone no app, calendário externo ou somar 24 h para horário
fixo; rejeitadas nesta etapa. Não há pacote novo nem API externa.

[Tipos temporais PG17](https://www.postgresql.org/docs/17/datatype-datetime.html),
[funções temporais PG17](https://www.postgresql.org/docs/17/functions-datetime.html).
A rejeição explícita de gaps/folds é decisão do projeto, não o comportamento padrão
do cast do PostgreSQL. Implementar e testar um resolvedor de data/hora civil na zona
fixa antes de gerar a série; uma conversão silenciosa do banco não satisfaz o contrato.
Usar dados IANA do servidor e cobrir as transições históricas de São Paulo.

## Materialização finita

Decisão: período obrigatório de até 366 dias civis inclusivos e 10.000 ocorrências
por revisão, geradas atomicamente ao salvar. Sem cron/horizonte móvel.
Motivo: todo compromisso existe após confirmação; limite impede carga ilimitada.
Alternativas: recorrência virtual no cliente e cron extensível; aumentam a ambiguidade
sobre conclusão, cancelamento e indisponibilidade. Limites são decisões de produto
operacionais documentadas, não recomendações clínicas.
[Constraints PG17](https://www.postgresql.org/docs/17/ddl-constraints.html).

## Persistência e identidade

Decisão: tabelas próprias para tratamento/revisão/aplicação/evento; não usar
clinical_records como chave. save_animal atual apaga/recria esse histórico descritivo.
Preservar snapshots da revisão em aplicações antigas evita mudar nome/instruções
já utilizados. Cada aplicação tem UUID estável e versão para escrita otimista.
Usar ledger privado medication_operations: o CHECK do write_operations existente
aceita apenas save_animal/set_status/set_publication. Não ampliar nem reaproveitar
esse contrato silenciosamente.

## Concorrência e auditoria

Decisão: advisory lock por ator/chave, depois animal → tratamento → aplicações
ordenadas por ID. Revalidar sessão/equipe após esperas; capturar clock_timestamp()
após locks para corte e conclusão. now() é início da transação e pode preceder espera.
Uma restrição parcial impede duas aplicações não canceladas do mesmo tratamento
no mesmo instante. Correção adiciona evento; não atualiza eventos antigos.
[Locks PG17](https://www.postgresql.org/docs/17/explicit-locking.html),
[relógios PG17](https://www.postgresql.org/docs/17/functions-datetime.html).

## Autorização e Result

Decisão: manter private.is_staff_current(), auth.sessions e RPCs estreitos com
search_path vazio, nomes qualificados e EXECUTE somente authenticated. RLS para
leitura; sem DML direto. Ledger/eventos sem grants ao cliente. Recibos somente do
ator e ainda sujeitos à equipe/sessão atual. Reutilizar serviceResult,
mapRepositoryResult e OperationId; mensagens SQL não chegam à interface.
[Funções Supabase](https://supabase.com/docs/guides/database/functions),
[RLS Supabase](https://supabase.com/docs/guides/database/postgres/row-level-security).
A escolha de definer segue o padrão necessário das escritas do projeto; não presumir
que RLS protege automaticamente o corpo de uma função privilegiada.

## UI e decisões confirmadas

Decisão: componentes nativos Flutter; Freezed e provider já aprovados permanecem.
Inspeção encontrou seis artboards: screen-5 tem a aba, porém não o corpo Calendário;
screen-6 tem cartões Medicações em uso, mas não editor de datas/horários.
Aprovação visual específica é gate antes das Views novas; fundação/dados podem
avançar independentemente. Horários fixos e intervalos, auditoria automática,
atrasadas preservadas e correção com justificativa foram confirmados pela responsável.
Concluir antecipadamente não é permitido nesta versão; adoção não interrompe
tratamento. Essas decisões estão explícitas na especificação, sem inferência no código.

Sem dúvida técnica adiada para a implementação: contratos abaixo fixam estados,
limites, corte, paginação e proteção. A aprovação de composição visual é uma etapa
reconhecida do fluxo, não uma dispensa da regra de design.
