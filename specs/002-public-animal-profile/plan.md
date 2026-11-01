# Planejamento — dados públicos do animal cadastrados pela equipe

Solicitado em 2026-10-31. Status: implementação e validação local concluídas; CI remota em acompanhamento. Complementa a ficha
pública do protótipo screen-3 e não altera os 108 itens da adequação original.

## Escopo e aceitação

Complemento da responsável: incluir peso (kg), cor e vacinação (data e tipo),
preservando castração pública. Vermifugação expõe somente a data; vacinação expõe
somente data e tipo. Nenhuma nota clínica deve ser copiada para esses campos.
O indicador legado de vacinação não é uma fonte para preencher data/tipo.

- Data da última vermifugação aplicada (date opcional) e resumo público de temperamento
  (texto opcional, 1–120 caracteres quando preenchido), cadastrados pela equipe.
- Publicação deliberada desses dados; não inferir datas/temperamento de textos de
  prontuário nem expor prescrições, doses, autoria ou histórico clínico privado.
- Ausência deve ser distinguida de resposta negativa; não preencher dados fictícios.
- Visitante lê somente animal publicado e não adotado; salvar os novos campos exige
  usuário/equipe ativos, sessão atual e RPC transacional idempotente.

## Plano técnico

1. Revisar com a responsável os rótulos públicos e a finalidade dos dados antes da
   implementação. Data representa aplicação já realizada; próxima dose não pertence
   a este campo nem deve gerar evento de calendário automaticamente.
2. Migração adiciona last_dewormed_on date nullable e temperament text nullable à
   projeção pública de animals, com limite no banco. Validar data não futura no
   fuso America/Sao_Paulo e preservar a data civil, sem conversão de timezone na UI.
3. Estender save_animal com campos opcionais, normalização, digest da operação,
   validações e manutenção dos valores antigos quando cliente legado omitir campos.
   Sem grants de DML direto. Não migrar texto clínico para o resumo público.
4. DTOs/Services → Repository → modelos Freezed → Editor/Detail ViewModels.
   Validações nos VMs e servidor; Views apenas exibem estado e enviam eventos.
5. Editor mantém a seção de manejo do protótipo e explica a visibilidade pública;
   ficha apresenta valores confirmados, distinguindo campos não preenchidos.
6. Nenhuma dependência Flutter nova é necessária. Atualizar geração, documentação,
   testes e CI antes de marcar esta funcionalidade concluída.

## Tarefas e situação atual

- [x] P001 Especificar critérios de data, edição/limpeza e exposição pública com exemplos.
- [x] P002 Escrever pgTAP de permissões, limites, data futura, idempotência e compatibilidade.
- [x] P003 Criar migração/RPC e testar criação, atualização e remoção dos valores.
- [x] P004 Estender DTOs/modelos/Services/Repositories com testes de mapeamento/falhas.
- [x] P005 Testar ViewModels: validação, mensagens, ausência, rascunho e autorização.
- [x] P006 Integrar campos no editor e ficha com Widget Tests e sem alterar layout sem autorização.
- [x] P007 Validar Android, duas sessões, ocultação/adoção e ausência de exposição clínica.
- [ ] P008 Atualizar evidências e executar CI antes de publicar cada etapa na developer.
- [x] P009 Definir contrato de peso, cor e registros públicos de vacinação (data/tipo),
  incluindo normalização, limites, limpeza e compatibilidade de clientes antigos.
- [x] P010 Estender migração/RPC e testes pgTAP para peso, cor e vacinação, sem expor
  doses, notas, prescrições ou autoria; preservar RLS e idempotência.
- [x] P011 Integrar peso, cor e vacinação às camadas MVVM e ao cadastro/ficha pública,
  com testes unitários e de interface; preservar o desenho autorizado.
- [x] P012 Validar os campos adicionais no Android e em segunda sessão, atualizar
  documentação e publicar os contextos validados na developer.

A ficha apresenta os dados públicos confirmados pelo backend. Ausências aparecem
como Não informado; vacinação usa aplicações com data/tipo, sem inferir valores
do booleano legado. O app mantém uma foto principal e o painel em duas colunas.

## Contrato público definido

Peso opcional: número em kg, maior que zero e até 1.000; cor opcional com até
80 caracteres. Vacinação: lista de até 100 aplicações, cada uma somente com
applied_on (data civil não futura) e vaccine_type (1–120 caracteres). Lista vazia
remove as aplicações públicas. Não gerar aplicações a partir do booleano legado.
Omissão preserva valores; null explícito limpa campos opcionais. A lista de vacinas
é substituída atomicamente pelo editor, como os demais dados do animal.

## Validação atual

- Supabase local: 127 testes pgTAP aprovados em sete arquivos (28 do perfil público).
- Flutter: 181 testes aprovados, análise limpa, geração determinística e formatação
  de 176 arquivos sem alterações. Nenhuma dependência nova.
- Android API 37: jornada de cadastro/edição/ficha aprovada (36 s) e jornada
  visitante aprovada (10 s); confirmação em segunda sessão e leitura anônima.
- APK debug normal reinstalado e aberto no emulador. Dados descartáveis removidos.
- CI inclui a jornada do editor. P008 permanece pendente até confirmar a execução
  remota; não confundir os resultados locais com a entrega do artifact.

Evidências e limites em validation.md. Migrações aplicadas somente no ambiente
local. Não foi realizada validação iOS nem implantação em produção.
