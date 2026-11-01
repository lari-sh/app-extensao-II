# Modelo

AdoptionChannel: whatsapp, instagram, facebook. Conjunto fechado, sem URL do usuário.
AdoptionContactState (Freezed): loading, opening, animalName, canContact, message,
linkNotice, animalId. Dados públicos vêm de PublicAnimal já existente; nada privado.
VM mantém apenas animal público atual e geração de carregamento; dispose invalida
futuros. load(id) -> pronto/indisponível/erro; open(channel) -> revalidar -> abrir
-> pronto/erro. Oculto/adotado cancela ação. Nenhuma gravação Supabase nesta feature.
URL futura: base HTTPS controlada + ID codificado; sem segredos ou dados clínicos.
