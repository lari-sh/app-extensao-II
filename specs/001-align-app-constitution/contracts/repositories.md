# Repository and presentation contracts

**Date**: 2026-10-31. Contratos de desenho; não são implementações.

## Fronteiras compartilhadas

- Métodos assíncronos retornam Future<Result<T>>. Comandos sem retorno usam
  Result<Unit>, não bool ambíguo. Nenhuma exceção de SDK atravessa a fronteira.
- Result contém Success(value) ou Failure(AppFailure). AppFailure possui código,
  fieldErrors opcionais e retryable; não contém objeto de exceção bruto.
- ViewModels traduzem códigos e validações para português. Repositories não
  devolvem mensagens do servidor para exibição direta.
- Streams usam Stream<Result<T>> e convertem erros. Abertura, assinatura e dispose
  devem ser testados; jamais deixar erro assíncrono não capturado no listener.
- DTOs, SupabaseClient, User, Session, XFile e StorageException ficam em data.
  Entidades usam tipos Dart, coleções imutáveis e enumerações do domínio.
- Toda implementação aceita operações/fábricas injetáveis privadas de data para
  testar mapping/catch/orquestração; closures de produção com SDK ficam no mesmo
  arquivo Repository. Fakes de domínio são usados só nos testes de ViewModel.

## AuthRepository — features/auth/domain

| Operação | Entrada | Resultado |
|---|---|---|
| restoreAccess | nenhuma | SessionAccess remoto validado ou falha |
| signIn | e-mail e senha | SessionAccess com userId e staff autorizado ou não |
| currentAccess | nenhuma | Revalida usuário/sessão e membership |
| watchAccess | nenhuma | stream de mudanças tipadas, sem dados brutos do SDK |
| signOut | nenhuma | Unit; estado privado limpo mesmo se encerramento remoto falhar |

SessionAccess diferencia visitor, authenticatedWithoutStaff e authorized; VMs
adicionam checking/unavailable de apresentação. Após login, getUser e access_context
validam acesso. Revalidar em resume e antes de ações privadas; 401/403 invalida o
acesso atual e impede publicação de resultados privados tardios. Offline no restore
não concede acesso staff com base em cache. Login inválido usa mensagem genérica.
Classificar a interrupção para o VM sem tipos do SDK: expiração recuperável ou perda
definitiva (logout, revogação, troca de usuário ou causa desconhecida). Na expiração,
EditorViewModel/tela permanecem montados, com rascunho só em memória e conteúdo
integralmente oculto; retomar apenas após validar o mesmo userId e staff ativo.
Perda definitiva, fechamento ou cancelamento descartam rascunho e pilha privada.
Falha ao reautenticar mantém a máscara e não permite Voltar para dados privados.
O logout encerra localmente a sessão e a pilha; se falhar no servidor, informar
falha sem restaurar a UI privada e permitir tentar revogar novamente. Não prometer
revogação remota enquanto não confirmada.

## AnimalsRepository — features/animals/domain

| Operação | Entrada | Resultado |
|---|---|---|
| listPublic | AnimalQuery, cursor opcional | Page<PublicAnimal>, cursor, total |
| getPublic | animalId | PublicAnimal ou notFound |
| getVisibleByIds | IDs de favoritos válidos | Só animais visíveis, sem dados clínicos |
| listManagement | status opcional, cursor | Page<ManagedAnimal> autorizada |
| getManagement | animalId | ManagedAnimal com notas/cuidados |
| getStatusCounts | nenhuma | Totais globais por status, incluindo adopted |
| saveAnimal | AnimalDraft, operationKey | Animal salvo; create/edit transacional |
| setStatus | animalId, status, operationKey | Estado confirmado |
| setPublication | animalId, published, operationKey | Estado confirmado |
| getOperation | operationKey | Resultado anterior ou ausência, somente do ator |

AnimalQuery combina nome (substring case-insensitive), espécie, porte e sexo
antes de paginar no servidor. Nome deve ser parâmetro, sem interpolar sintaxe de
consulta. Cursor ordenado por name,id evita duplicação em empate; alteração da
query reinicia cursor. Dashboard usa totais globais separados da página carregada.
getPublic de animal oculto/adotado retorna notFound, sem distinguir existência.
Views não escolhem endpoint pela role: VM seleciona operação e Repository valida.

saveAnimal não recebe foto principal nem autoria editável; banco decide UUID,
timestamps e autor. operationKey permanece estável após timeout até reconciliar.
Não repetir automaticamente login, save ou upload com nova chave. Campos mudados
após operação confirmada constituem nova submissão. Sem fila offline.

## FavoritesRepository — features/favorites/domain

- loadIds(): Result<Set<String>>; setFavorite(id, value): Result<Set<String>>.
- Chave existente favorites_v1; escrever somente após sucesso. Filtrar IDs não
  consultáveis e cruzar dados por AnimalsRepository no VM. Falha local não muda
  indicador como se tivesse persistido. Nenhuma referência a dados clínicos.

## PhotoRepository — features/photos/domain

| Operação | Entrada | Resultado |
|---|---|---|
| pickFromGallery | nenhuma | PhotoCandidate?; null significa cancelamento |
| recoverLostSelection | nenhuma | PhotoCandidate? recuperado após interrupção Android |
| uploadPrimary | animalId, candidato, operationKey | Foto confirmada ou falha/reconciliação |
| getUpload | operationKey | Estado do job e referência confirmada |
| readPrimary | animalId, photoId | PhotoContent(bytes, mime), nunca URL do Storage |

PhotoCandidate possui bytes, tamanho e tipo detectado preliminar; não XFile nem
caminho do sistema exposto ao Widget. Validar tamanho antes de ler bytes excessivos.
Permissão negada pelo plugin (incluindo PlatformException de acesso à galeria)
é capturada nesta implementação e convertida em Failure(permissionDenied), sem
objeto de exceção bruto. Cancelamento continua Success(null). O VM encerra loading,
exibe mensagem portuguesa e preserva rascunho/foto anterior; nenhum upload é iniciado.
Servidor é autoridade da validação final. Um candidato recuperado exige confirmação
e escolha/revalidação do animal e da sessão; não persistir rascunhos para associá-lo.
Durante envio usar submitting, reconciling, success ou failure; cancelamento normal
é da seleção, não rollback fictício de upload em processamento. Renderizar a imagem
anterior até confirmação da nova. Bloquear duplo clique no VM e idempotência no backend.

readPrimary ocorre no Repository via função e devolve bytes. Não usar Image.network
com URL de Storage que passe por fora da fronteira do Repository. Cache, se houver,
é memória de tela; invalidar no refresh de visibilidade e em mudança de sessão,
sem usar URL assinada como identidade permanente da imagem.

## AdoptionMessageRepository — features/home/domain

- copyInterestMessage(publicAnimal): Result<Unit>, implementação Flutter Clipboard.
- DetailViewModel calcula canAdopt (published e available) e emite comando;
  sucesso informa “Mensagem copiada. Nenhum pedido foi enviado.”.
- Widget recebe estado/mensagem, não chama Clipboard ou o Repository diretamente.

## Contrato das Views

Views recebem seus VMs. Inicialização/injeção e execução inicial ficam no bootstrap/
fábrica da rota, nunca em build. Lifecycle pode enviar eventos ao VM. Widgets só
renderizam estado/capacidades, layout e navegação declarada por eventos; não possuem
queries, validações, autorização, seleção de pacote externo ou cálculo de contadores.

Cada estado possui busy, erro amigável e dados confirmados quando aplicáveis.
Fakes de Repository fornecem Result determinístico; testes verificam ViewModel real
e Widget real. Testes não dependem de serviço, galeria ou área de transferência reais.
