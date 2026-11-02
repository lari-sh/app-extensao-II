# Validação — busca global administrativa 006

## Aprovação — 2026-11-02

Responsável respondeu “Aprovar revisão v2” à proposta DESIGN-SEARCH-001 v2.
T002 concluída. Branch developer, prerequisites PASS; sem checklists ou hooks de
extensão. Skill speckit-implement e arquitetura Flutter serão seguidas. Backend,
Flutter, Android e CI serão registrados separadamente após validação efetiva.
Nenhuma tarefa de implementação é marcada apenas por geração de arquivos.


## Acompanhamento na skill — 2026-11-02

Por solicitação, speckit-implement aponta para tasks.md da feature 006 e exige
atualização de estado/evidências após cada contexto validado. Sem duplicar a lista
na skill nem inserir tarefas na constituição. Frontmatter e links validados.


## T003 — códigos dos animais — 2026-11-02

Migration 202611020018 aplicada localmente com transação explícita/bloqueio e
backfill por UUID. UUIDs, fotos e relações não mudam. Código é único, não editável,
gerado só pelo servidor, permite lacunas e cresce após A9999 sem truncar.
Snapshot anterior: hashes/contagens preservados em animals (excluindo só o novo
campo), animal_internal_details, clinical_records, photo_upload_jobs,
medication_treatments e medication_applications. Dados manuais/demo preservados.

Teste red confirmou coluna ausente antes da implementação. Depois, 19 testes de
código PASS e regressão completa: **356 SQL em 15 arquivos PASS**. Inclui legado,
homônimos, >9999/bigint, rejeição de código forjado, estabilidade em edição,
rollback/lacunas e privilégios. HTTP local com duas sessões independentes PASS:
alocação concorrente distinta, replay concorrente de mesma chave com uma identidade
e código estável após renomear. Fixtures próprias removidas; nenhuma credencial
impressa. Teste HTTP incluído no job backend da CI; resultado remoto ainda pendente.

T004 (RPC de busca) e integração Flutter permanecem pendentes. Código ainda não é
exibido na UI do app; o backfill não representa conclusão da busca.
