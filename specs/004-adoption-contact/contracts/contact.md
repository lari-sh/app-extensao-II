# Contratos

AdoptionContactRepository.open(channel, PublicAnimal): Future<Result<Unit>>.
Repository valida disponibilidade, usa catálogo fechado de URLs e constrói mensagem
WhatsApp com Uri(queryParameters) para codificar acentos/espaços/caracteres especiais.
ExternalLinkService.open(Uri): Future<Result<Unit>>; implementação usa plataforma,
nenhum Widget/VM importa url_launcher. False e erro são falha amigável.
VM usa AnimalsRepository.getPublic(id) antes de abrir; chama contrato só após
revalidação bem-sucedida. Instagram/Facebook não recebem dados do animal no URL.
Success significa abertura aceita pelo SO; nunca mensagem enviada ou adoção criada.
Link público só é anexado quando endereço real e validação US2 estiverem disponíveis.
