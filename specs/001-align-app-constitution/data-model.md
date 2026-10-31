# Data Model: Abrigo dos Anjos

**Date**: 2026-10-31 | **Status**: desenho, sem migrations executadas.
Nomes persistidos em inglês; rótulos visíveis traduzidos pelo ViewModel.

## Entidades e tabelas

### animals — somente dados divulgáveis

| Campo | Tipo / restrição | Observação |
|---|---|---|
| id | uuid, chave primária, gerado no banco | Identificador estável; não reutilizar IDs da demonstração |
| name | texto, trim, 1–80 caracteres | Obrigatório |
| species | dog ou cat | Exibido como cachorro/gato |
| sex | female ou male | Obrigatório |
| size | small, medium ou large | Obrigatório |
| approximate_age | texto, trim, 1–80 caracteres | Sem inferir data de nascimento |
| public_description | texto, 0–3.000 caracteres | Nunca recebe notas clínicas automaticamente |
| status | available, treatment, quarantine ou adopted | Independente da publicação |
| is_published | boolean, default false | Novo cadastro é privado |
| is_vaccinated / is_neutered | boolean, default false | Informação declarada, não recomendação clínica |
| primary_photo_id | uuid opcional | Referência ao objeto validado e associado |

Não incluir created_by, updated_by, notas, doses, tokens ou outros metadados
privados nessa tabela, pois usuários públicos podem solicitar select=*.
Ordenação pública estável por name,id; índices de publicação/status e filtros.
Auditoria mínima de atualização fica na tabela interna abaixo.

### animal_internal_details

- animal_id: uuid, chave primária e referência a animals (1:1).
- clinical_notes: texto até 3.000 caracteres, default vazio.
- created_at, updated_at: timestamps do servidor.
- created_by, updated_by: referências a auth.users; somente servidor define autoria.
- Leitura apenas por voluntário ativo com sessão atual; sem acesso anônimo.

### clinical_records

- id: uuid, chave primária do banco; animal_id: referência obrigatória a animals (1:N).
- kind: vaccination, deworming ou medication.
- description: trim, 1–1.000 caracteres.
- created_at, updated_at, created_by, updated_by: metadados internos do servidor.
- Não estruturar prescrição nem agenda automática fora do escopo. Remover um item
  no editor significa removê-lo na próxima transação confirmada de edição.

### staff_members

- user_id: uuid, chave primária e referência a auth.users.
- active: boolean, default false; timestamps administrativos internos.
- Criação/alteração apenas por responsável confiável fora do app.
- Sem grants de escrita para anon/authenticated. Consulta da própria autorização
  por access_context RPC; não disponibilizar listagem de equipe ao app.
- O usuário não pode aprovar a si mesmo por metadata, RPC de cadastro ou upload.

### write_operations — registro privado de idempotência

- actor_id, operation_key: chave única composta; key com 24 bytes aleatórios em
  base64url, gerada com Random.secure no cliente e estável em uma submissão.
- operation_kind: save_animal, set_status ou set_publication.
- payload_digest: hash do payload normalizado calculado no servidor.
- animal_id, result_payload, completed_at: resultado confirmado da transação.
- A criação de operação, as mudanças e o resultado são confirmados na mesma
  transação. Sem sucesso parcial; rollback não deixa operação marcada concluída.
- Mesma chave e mesmo payload retornam resultado anterior; chave com payload
  diferente retorna conflict. Nova edição intencional usa nova chave.
- Acesso somente via RPC do próprio ator e após reautorização; sem leitura pública.

### photo_upload_jobs — rastrear antes de gravar no Storage

| Campo | Regra |
|---|---|
| id | UUID gerado no servidor |
| animal_id, actor_id, actor_session_id | Animal alvo e autor/sessão verificados |
| operation_key, payload_digest | Unicidade por ator; hash para reconciliar retry |
| object_path | Caminho único imutável, gerado pelo servidor; sem nome fornecido pelo cliente |
| detected_mime, byte_size | JPEG/PNG e 1–5.242.880 bytes efetivamente recebidos |
| state | pending, validated, attached, cleanup_needed, cleaned ou failed |
| previous_photo_id | Referência substituída, definida ao finalizar com lock no animal |
| created_at, updated_at, error_code | Metadados privados, sem stack trace para o app |

animal.primary_photo_id aponta para um job attached; nenhum job pending/failed
pode ser anunciado como foto. Referência circular implementada após criar tabelas,
com integridade de associação aplicada pela finalização. Cliente não pode escolher
objeto arbitrário, alterar state nem escrever no bucket.

### photo_cleanup_queue

- job_id/object_path únicos; motivo failed_candidate ou superseded;
  attempts, next_attempt_at, last_error_code e completed_at.
- Enfileirada na transação que troca a foto ou marca falha. Se o processo cair
  antes, job pending antigo ainda identifica o objeto determinístico a inspecionar.
- Worker busca pending há mais de 15 minutos e itens de cleanup, usa Storage API
  e faz retry com backoff até sucesso, mantendo falhas visíveis para operação.
- Nunca apagar objeto referenciado por algum animal. Não mover job superseded
  para attached novamente; usar trava/estado terminal para evitar corrida.
- Apenas invocação interna autorizada; não há função pública de limpeza.

### Favoritos locais

- Persistir somente conjunto de IDs de animais em favorites_v1.
- IDs A0024 e similares herdados não são importados nem convertidos a UUIDs;
  FavoritesRepository os trata como indisponíveis e consulta só IDs válidos.
- Nenhum dado clínico, foto em bytes, senha ou rascunho é persistido nesse contrato.
- Sessão do SDK possui armazenamento próprio de autenticação, não é o repositório
  de favoritos. Limpar sessão e estado privado no logout.

## Regras de acesso

| Recurso/operação | Visitante | Autenticado sem staff | Staff ativo com sessão atual |
|---|---|---|---|
| animals leitura | Publicado e não adopted | Mesma regra pública | Todos |
| Notas/cuidados/autoria | Negado | Negado | Permitido |
| Alterar animal/status/publicação | Negado | Negado | RPC validada |
| Foto atual | Só animal publicável, via função | Mesma regra pública | Via função, inclusive privado |
| Upload/substituição | Negado | Negado | Função com reautorização |
| Storage direto/listagem/URL assinada | Negado | Negado | Negado ao cliente; funções fazem acesso interno |
| Membership/escalada de privilégios | Negado | Negado | Sem escrita; apenas estado próprio por RPC |

RLS habilitada em todas as tabelas expostas. Helpers de autorização em schema
private não exposto, SECURITY DEFINER estreito, search_path vazio, referências
qualificadas e grants mínimos. Verificar auth.uid(), session_id da claim e sessão
correspondente em auth.sessions, além de staff_members.active atual; ausência ou
identificador inválido retorna false. Não expor conteúdo de auth.sessions. Novos
JWTs/refresh seguem verificação do Auth; não confiar apenas na sessão em memória.

Writes somente por RPCs estreitas SECURITY DEFINER com autorização explícita e
validações repetidas no servidor. Revogar DML direto e EXECUTE padrão PUBLIC;
conceder apenas o necessário. Isso não delega a segurança à UI: testar helper,
políticas e cada RPC com atores não autorizados. RPCs privilegiadas não podem
receber owner/actor livre do cliente. As de foto service-only recebem o ator
verificado da função e revalidam sessão/membership antes da finalização.

## Transações e transições

- Status: qualquer situação pode mudar para outra situação após decisão de staff.
  adopted sempre exclui leitura pública, mesmo com is_published=true. Não permitir
  nova publicação com status adopted; para republicar, mudar status antes.
- save_animal: upsert lógico por ID (create sem ID) + detalhes + cuidados + operação
  em transação. Edição concorrente: última gravação confirmada prevalece para
  campos editáveis; não sobrescrever primary_photo_id a partir de formulário antigo.
- set_status e set_publication usam lock e autorização; contadores retornados por
  consulta global ao banco, não pela soma das páginas carregadas no dispositivo.
- Foto: pending → validated → attached. Falha anterior à associação →
  cleanup_needed → cleaned (ou failed sem objeto); foto antiga permanece.
  Substituição confirmada enfileira a antiga como superseded; nunca reativa antiga.
- Timeout/perda de resposta do upload: consultar operação/job antes de decidir
  retry/cleanup; job attached não pode ser apagado como falha presumida do cliente.
- Seleção da galeria é cancelável antes do envio. Após submissão, não oferecer
  cancelamento que prometa desfazer uma transação aceita; timeout usa reconciliação.

## Armazenamento e entrega de imagens

Bucket animal-photos privado, limite 5 MB e MIME JPEG/PNG. Caminho
animals/<animal_uuid>/<job_uuid>.<detected_extension>, exclusivo por tentativa.
Validar assinatura e decodificar no servidor, rejeitar arquivo corrompido e
normalizar removendo metadados. O arquivo selecionado aceita até 5.242.880 bytes;
contabilizar o multipart separadamente (arquivo mais até 65.536 bytes de overhead,
total máximo 5.308.416). Se a saída inicial exceder 5 MB, ajustar compressão e,
quando necessário, reduzir resolução mantendo proporção/transparência até caber no
bucket; não invalidar a entrada só pelo aumento na primeira normalização. Não inferir
MIME pela extensão do arquivo de origem.

animal-photo-read retorna bytes apenas da foto atual, após checar visibilidade e
ator. Sem redirect, URL assinada exposta, ETag/304 ou cache compartilhado. Header
Cache-Control: no-store, private em sucesso e erro. Uma requisição nova após retirar
publicação é negada; bytes previamente baixados estão fora do controle do servidor.
Respostas já em voo podem terminar; próxima solicitação revalida. No refresh/logout
o cliente invalida bytes de fotos privadas e respostas tardias por geração de sessão.

## Representação no cliente conforme a constituição 2.0.0

Modelos imutáveis e snapshots usam Freezed em lib/domain/models e nos ViewModels
quando aplicável; não importam Supabase ou Provider. Result em lib/utils permanece
independente de SDK. DTOs JSON manuais em lib/data/models representam os dados de
API. Services produzem DTOs/Result; Repositories convertem DTOs em domínio e
mantêm a fonte de verdade. Nenhuma tabela, política ou limite funcional muda por
essa reorganização. Geração .freezed.dart deve ser determinística e validada no CI.
