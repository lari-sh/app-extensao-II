# Decisões de pesquisa — revisão global v2

- **Campo fixo, sem quarta aba.** O novo pedido substitui a decisão da v1. O campo
  fica fora dos ScrollViews, abaixo dos totais. Filtros em painel próprio mantêm
  o celular utilizável; o botão de filtros não é um botão de acesso à busca.
- **Resultado global temporário.** Busca não filtra somente o que está montado no
  Kanban/lista/agenda. A área central mostra uma lista global e mantém o modo marcado;
  limpar restaura seus VMs, data, coluna e rolagem. O servidor não recebe o modo/data.
- **Código legível automático.** O schema consultado contém UUID e não contém
  animal_code. Planejar coluna+sequência/constraint/guarda de imutabilidade em
  migration futura. Não apresentar códigos do protótipo como já gerados no banco.
  UUID continua PK; código não muda com nome/situação/publicação, aceita lacunas
  e se expande além de 9999. Backfill protegido preserva todos os dados existentes.
- **Cinco filtros.** Espécie, sexo, porte e situação já têm enum/schema no app.
  Cor é texto livre no cadastro atual; usar pesquisa parcial literal, não inventar
  uma paleta incompatível ou inferir cor pela imagem. Rascunho/cancelamento no VM.
- **Nome ou código.** Código completo em formato #?A + 4+ dígitos, sem distinguir
  caixa, usa igualdade; texto diferente procura nome parcial. Cor/nome escapam
  curingas %, _ e barra, sem SQL dinâmico. Acentos não são removidos nesta versão.
- **RPC aditiva e paginação no servidor.** list_managed_animals só recebe situação
  e cursor; estender a busca por RPC própria preserva o painel e os contratos atuais.
  Total usa todos os filtros, sem limitar a item carregado ou existência de medicação.
- **Autorização/fotos atuais.** Reutilizar private.is_staff_current() e foto autorizada.
  Código não substitui autorização. Revogação descarta inclusive bytes/respostas tardios.
- **Dependências existentes.** Timer dart:async, Freezed, Provider e SDK atual bastam.
  Não há tecnologia nova que exija agente de pesquisa ou dependência adicional.

Código consultado: schema animals, DashboardMode atual (três valores),
SupabaseAnimalsService.listManagement, Domain/Repository e migração de campos públicos.
A questão técnica do identificador foi resolvida no plano; o gate pendente é a
aprovação da proposta visual v2, não falta de informação para elaborar o plano.
