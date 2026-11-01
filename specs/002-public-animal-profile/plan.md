# Planejamento — informações públicas de vermifugação e temperamento

Solicitado em 2026-10-31. Status: planejado, não implementado. Complementa a ficha
pública do protótipo screen-3 e não altera os 108 itens da adequação original.

## Escopo e aceitação futura

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

## Tarefas futuras (não executadas)

- [ ] P001 Especificar critérios de data, edição/limpeza e exposição pública com exemplos.
- [ ] P002 Escrever pgTAP de permissões, limites, data futura, idempotência e compatibilidade.
- [ ] P003 Criar migração/RPC e testar criação, atualização e remoção dos valores.
- [ ] P004 Estender DTOs/modelos/Services/Repositories com testes de mapeamento/falhas.
- [ ] P005 Testar ViewModels: validação, mensagens, ausência, rascunho e autorização.
- [ ] P006 Integrar campos no editor e ficha com Widget Tests e sem alterar layout sem autorização.
- [ ] P007 Validar Android, duas sessões, ocultação/adoção e ausência de exposição clínica.
- [ ] P008 Atualizar evidências e executar CI antes de publicar cada etapa na developer.

Enquanto planejados, a ficha identifica as duas informações como Cadastro em
planejamento. O quadro usa somente os booleanos públicos de vacinação/castração
já disponíveis. O app continua com uma foto principal, sem carrossel fictício.
