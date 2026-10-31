# Backend contracts: Supabase

**Date**: 2026-10-31. Leitura pública/fotos implementadas e validadas localmente;
escrita/upload/manejo pendentes. Nenhum backend de produção implantado. Modelo e permissões: [data-model.md](../data-model.md).

## Contexto de identidade

- Cliente contém apenas URL e publishable/anon key do projeto; essas chaves não
  concedem autorização administrativa. Nunca incorporar service_role/secret key.
- Auth usa sign-in com e-mail/senha de conta provisionada fora do app. Desabilitar
  autoinscrição pública no projeto. SupabaseAuthService é o único consumidor
  Dart dessas operações, mediado por AuthRepositoryImpl; nenhum token é retornado ao Widget.
- access_context RPC retorna apenas identidade do próprio usuário, estado da
  sessão e isStaffActive. Não lista equipe nem expõe auth.sessions.
- Escritas exigem helper privado que checa usuário, session_id atual existente e
  membership ativa. Tokens expirados são rejeitados; usuário em cache não é prova.
- Helpers SECURITY DEFINER com search_path vazio, nomes qualificados e grants
  mínimos. Rejeitar IDs de autor fornecidos por clientes. RLS em todas as tabelas.
- Operações SECURITY DEFINER com DML revogado ao cliente repetem autorização e
  validações. Revogar EXECUTE implícito de PUBLIC nas funções antes dos grants.

## Leitura PostgREST

| Operação | Contrato | Acesso |
|---|---|---|
| Catálogo | animals, projeção de campos públicos, filtros combinados e cursor name,id | Linhas publicadas e status diferente de adopted |
| Detalhe | animals por id | Mesmo filtro público; ausência/oculto retorna notFound |
| Favoritos | animals por conjunto de UUIDs | Mesma política; ignorar IDs legados inválidos |
| Manejo | animals + animal_internal_details + clinical_records | Staff ativo com sessão atual |
| Contadores | get_animal_status_counts RPC | Staff; agregação global sob autorização |

PublicAnimal não contém notas, cuidados detalhados ou autoria; ManagedAnimal
adiciona essas entidades somente após autorização. Mesmo select=* em animals não
encontra dados privados; consulta direta às tabelas internas é negada sem staff.
Sem views SECURITY DEFINER de leitura pública. Se uma view se tornar necessária,
usar security_invoker e comprovar grants/RLS com os mesmos testes negativos.

## RPCs transacionais

| Nome | Payload lógico | Resultado / garantia |
|---|---|---|
| access_context | nenhuma identidade arbitrária | Estado do próprio ator verificado |
| save_animal | operation_key, animal_id opcional, campos editáveis, clinical_notes, care_records | Cadastro inteiro confirmado ou rollback; autoria/UUID no servidor |
| set_animal_status | operation_key, animal_id, status | Estado confirmado; transição sob autorização |
| set_animal_publication | operation_key, animal_id, is_published | Privado por padrão; negar publicação quando adopted |
| get_write_operation | operation_key | Resultado do próprio ator ou ausência |
| get_animal_status_counts | nenhuma | Totais por situação de todos os registros acessíveis à equipe |

Todas as RPCs de escrita validam membership/sessão, enums e limites de caracteres,
independentemente da validação do VM. RPCs públicas de manejo não aceitam photo_id,
owner, timestamp ou campo privilegiado livre. Chave de operação com payload igual
repete resultado; diferente retorna conflito. Resultado perdido exige consulta
get_write_operation; retorno de timeout do cliente não significa rollback no servidor.

Erros do banco/RPC são capturados no Service e garantidos como Result pelo Repository; ViewModels nunca recebem
PostgrestException. Resultado de negócio de RPC é envelope tipado ou código
documentado, sem mensagens SQL destinadas à UI.

## Função animal-photo-read

**Método**: GET `/functions/v1/animal-photo-read?animal_id=<uuid>&photo_id=<uuid>`.
**Identidade**: visitante permitido para animal público; Bearer de usuário precisa
ser verificado para acesso staff. Requisição com token inválido não concede acesso
privado. Leitura pública não exige fabricar sessão de usuário anônimo.

A configuração de gateway admite visitante nessa função específica; handler faz
autenticação opcional e autorização obrigatória conforme o recurso. Essa abertura
não se aplica a upload/cleanup. Chave pública em apikey conforme o gateway do projeto;
não tratar apikey como identidade de staff. Configuração deve ser ensaiada com
publishable keys e JWTs do ambiente, sem desabilitar validação em todo o projeto.

1. Validar UUIDs e consultar foto atual/animal. Nunca aceitar um caminho Storage
   arbitrário ou servir qualquer job por UUID sem vínculo atual.
2. Permitir se publicado e não adopted, ou se usuário e sessão são válidos com
   membership ativa. Rechecar antes de servir se houve operação demorada.
3. Baixar objeto privado internamente e retornar bytes com MIME validado,
   Content-Length e Cache-Control: no-store, private. Não emitir redirect nem URL
   assinada; não responder 304; retornar também Pragma: no-cache.
4. Erros de oculto/inexistente respondem 404 sem revelar existência. Para operações
   privadas explicitamente autenticadas, 401/403 são traduzidos pelo Service/Repository em perda de acesso.

Nova leitura após despublicação/adoção deve falhar. O plano não emite acessos
temporários ao Storage; assim não depende de expiração de URL de 60 s nem de CDN.
Bytes anteriormente baixados e respostas já em voo não são apagáveis; testar a
negação de pedidos novos e invalidação do cache de tela no app.

## Função animal-photo-upload

**Método**: POST `/functions/v1/animal-photo-upload`.
**Entrada**: multipart com animal_id, operation_key e file JPEG/PNG até 5.242.880
bytes de arquivo. O corpo completo pode ter até 5.308.416 bytes, incluindo até
65.536 bytes de delimitadores/campos; apenas esses três campos são aceitos, sem
duplicatas. animal_id deve ser UUID e operation_key deve corresponder aos 24 bytes
base64url previstos no contrato. O overhead não reduz o limite aceito de arquivo.
**Saída**: job_id, photo_id atual, estado confirmado e correlation_id não sensível.
**Consulta de reconciliação**: GET na mesma função por operation_key, somente do
ator autenticado e autorizado que iniciou a operação.

Validar JWT com Auth e sessão/membership atuais antes de processar corpo. Contar
separadamente bytes do arquivo (máximo 5.242.880) e do multipart (máximo 5.308.416),
limitando a leitura efetiva; não confiar apenas em Content-Length ou File.type.
Detectar assinatura, decodificar e normalizar JPEG/PNG no servidor e remover metadata.
Se a primeira saída ultrapassar 5.242.880 bytes, ajustar compressão e, se necessário,
reduzir resolução preservando proporção e transparência, sem ampliar a imagem,
até produzir saída compatível. Não rejeitar entrada válida apenas pelo crescimento
da primeira saída. Rejeitar conteúdo não decodificável. Usar dependências WASM
fixadas e testar limites de CPU/memória no runtime alvo antes de liberar.

Criar photo_upload_jobs antes da gravação Storage e usar caminho imutável. Arquivo
e metadata ficam privados. Finalização transacional service-only faz lock no animal,
revalida ator/sessão/membership e estado validated do job, troca primary_photo_id,
marca attached e enfileira foto anterior. Excluir foto antiga só depois do commit.
Não remover candidato apenas porque o cliente recebeu timeout.

Falha pré-commit preserva foto antiga e deixa candidato rastreado para limpeza;
falha pós-commit de limpeza não desfaz a foto nova e mantém pendência operacional.
Concorrência: cada job associa no máximo uma vez; uma foto substituída não pode ser
reativada por replay; repetição devolve resultado original e estado atual em separado.
GET de reconciliação distingue pendente, confirmado, falho e inexistente; pendente
nunca vira confirmação de sucesso. Mesmo operation_key com bytes diferentes é conflito.

O acesso privilegiado de Storage ocorre apenas após autorização explícita do handler;
esse cliente server-side ignora RLS e não pode ser usado sem essa checagem.

## Função animal-photo-cleanup

Invocação interna agendada a cada 15 minutos com credencial específica guardada
no servidor, nunca no Flutter. Nenhum acesso de visitante/staff pelo cliente.
Processar jobs pending antigos e fila com retry/backoff. Para cada objeto, verificar
que não é foto atual e que não pode voltar a ser associado; usar lock/estado terminal
antes de remover pelo Storage API. Não apagar diretamente storage.objects via SQL.
Falha fica rastreada para nova tentativa; responder apenas resumo operacional sem
conteúdo clínico. Testar worker interrompido e dois workers concorrentes.

## Semântica de erro externa

| Código HTTP / categoria | Mapeamento em AppFailure |
|---|---|
| 400 entrada inválida | validation, fieldErrors conhecidos |
| 401 sessão inválida | unauthenticated; invalidar acesso privado |
| 403 sem autorização | forbidden; reavaliar SessionViewModel |
| 404 ausente ou oculto | notFound, sem distinguir existência |
| 409 chave/payload incompatível | conflict; reconciliar antes de nova chave |
| 413 bytes excedidos / 415 formato inválido | validation com mensagem portuguesa no VM |
| 422 conteúdo não decodificável | validation; manter imagem anterior |
| 429 temporário | network/temporary, retryable sem reenvio cego de escrita |
| 5xx, rede, timeout | failure tipada; consultar operação antes de repetir escrita |

Não devolver tokens, caminhos internos ou stack traces. Logs do servidor usam
correlation_id e códigos, não corpo de formulário, fotos, senha ou prontuário.

## Provas de segurança obrigatórias

1. Visitante e conta sem staff: ler notas, cuidados, autoria, jobs, membership e
   executar cada RPC restrita; todos negados, inclusive select=* e joins.
2. JWT ainda válido com membership removida ou sessão encerrada: cada operação
   privada negada, inclusive upload/finalize; novos pedidos não usam claims antigas.
3. Foto privada por endpoint e por Storage direto, listagem e createSignedUrl:
   negados; não existe bucket público alternativo.
4. Foto antes/depois de despublicar/adotar: novo pedido negado imediatamente,
   Cache-Control no-store e nenhum redirect ou URL reaproveitável fornecida.
5. Extensão falsa, arquivo corrompido, arquivo de 5 MB exatos aceito com overhead
   multipart permitido e 5 MB + 1 byte de arquivo rejeitado; corpo completo além de
   5.308.416 bytes rejeitado. Normalização inicialmente maior que 5 MB deve ser
   ajustada e aceita quando o arquivo de origem é válido; proporção preservada e
   imagem anterior intacta nas falhas.
6. Gravação de animal/cuidados falha em metade do payload: rollback integral.
7. Mesma chave após resposta perdida: um animal/associação; payload diferente conflita.
8. Dois uploads concorrentes, perda de resposta e limpeza falha: foto atual sempre
   referenciada e nenhuma exclusão prematura; órfão permanece rastreado até limpeza.

## Evidência de implementação da leitura

Migration 004 adiciona resolve_photo_read service-only e policies restritivas de
bucket para animal-photos. GRANTs de tabela padrão não concedem acesso ao bucket:
RLS nega clientes mesmo com uma policy permissiva adicional. O handler verifica
JWT de usuário quando aplicável e passa ator/sessão verificados ao resolver.
Revalida o recurso após baixar bytes. Negociação Accept permite octet-stream ao
SDK functions_client e image/png ou image/jpeg ao consumidor HTTP comum, sempre
com no-store/private, sem redirect nem 304. Testes em validation.md.
