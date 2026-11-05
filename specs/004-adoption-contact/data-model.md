# Modelo

AdoptionChannel: whatsapp, instagram, facebook. Conjunto fechado, sem URL do usuário.
AdoptionContactState (Freezed): loading, opening, animalName, canContact, message,
contactNotice. O ID é mantido internamente pelo VM e passado pela rota;
dados públicos vêm de PublicAnimal já existente, sem campos privados.
VM mantém ID e geração de carregamento; reconsulta o animal público a cada ação.
Dispose invalida
futuros. load(id) -> pronto/indisponível/erro; open(channel) -> revalidar -> abrir
-> pronto/erro. Oculto/adotado cancela ação. Nenhuma gravação Supabase nesta feature.
Sem modelo ou configuração de URL da ficha: funcionalidade cancelada.
