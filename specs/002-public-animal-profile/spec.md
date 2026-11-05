# Especificação — dados públicos do animal cadastrados pela equipe

Data: 2026-10-31. Escopo autorizado: implementação conforme plan.md.

## Complemento solicitado pela responsável em 2026-10-31

- **002-FR-007**: Peso, cor, situação de castração, vacinação e vermifugação são
  informações públicas cadastradas pelo administrador. Temperamento continua no
  escopo já autorizado. A ficha pública utiliza os valores confirmados pelo backend,
  sem inferir essas informações de notas clínicas internas.
- **002-FR-008**: A informação pública de vermifugação contém somente a data de
  aplicação. Não expor medicamento, dose, prescrições, observações ou autoria.
- **002-FR-009**: Cada informação pública de vacinação contém a data de aplicação
  e o tipo de vacina. O booleano legado isVaccinated não substitui esses dados e
  não permite inventar data ou tipo. Não expor dose, lote, prescrições ou notas.
- **002-FR-010**: Peso é informado em kg e deve ser positivo quando preenchido;
  cor é uma descrição pública. Campos ainda não cadastrados aparecem como
  Não informado. A castração mantém o campo público existente, sem divulgar notas
  cirúrgicas. Não transformar ausência de datas em afirmação de não vacinação ou
  não vermifugação.

Os critérios de testes devem cobrir cadastro, edição, limpeza e leitura pública
desses campos, além de garantir que notas clínicas permaneçam privadas. A adição
dos dados foi solicitada; mudanças na composição do protótipo continuam sujeitas
à regra de autorização de layout da constituição.

- **002-FR-001**: Equipe ativa cadastra/edita/remove data da última vermifugação
  aplicada e resumo público de temperamento, sem importar informações do prontuário.
- **002-FR-002**: Data civil opcional, entrada DD/MM/AAAA, armazenamento YYYY-MM-DD.
  Rejeitar calendário inválido e aplicação futura; servidor usa America/Sao_Paulo.
  Campo vazio limpa para NULL, sem converter datas civis em instantes/timezones.
- **002-FR-003**: Temperamento opcional, espaços externos normalizados, 1–120 pontos
  de código quando preenchido. Vazio limpa para NULL. Texto explicitamente público.
- **002-FR-004**: RPC save_animal preserva transação, autoria, autorização por sessão,
  locks e idempotência. Chave igual/payload diferente conflita; omissão por cliente
  antigo preserva valores existentes. NULL explícito remove. Sem grants de DML direto.
- **002-FR-005**: Visitante lê esses dados somente em animal publicado não adotado;
  ausência aparece como Não informado. Preservar notas/histórico privados e foto/status.
- **002-FR-006**: Services/DTOs e Repositories mapeiam os campos; VMs validam, formatam
  e expõem estados imutáveis. Formulário explica a visibilidade; ficha mantém layout.
- **002-CR-001**: Testes de regras em flutter_test, Widget Tests de cadastro/ficha,
  pgTAP de RLS/datas/limites/idempotência e jornada Android com segunda sessão.
  Documentação e commits por contexto na developer. Nenhum pacote novo necessário.

Exemplos: 29/02/2024 é válido; 31/02/2026 é inválido; amanhã é inválido. A data de
hoje do abrigo é válida. Calmo e sociável é texto público; notas clínicas não são
copiadas. Limpar o campo remove a informação pública. Ausência não significa
animal não vermifugado nem temperamento negativo. O cadastro novo permanece privado.

O cliente aplica validação prévia com relógio injetável para testes; a decisão final
usa relógio/fuso IANA do servidor, independente do relógio/configuração do aparelho.
