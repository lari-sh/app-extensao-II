# Acesso e convites da equipe

Data: 2026-11-01 | Branch de trabalho: developer | Estado: planejamento e proposta visual.
Escopo adicional à versão Android fechada; nenhum backend/app implementado nesta etapa.

## Decisões confirmadas

O primeiro administrador é provisionado pelo responsável técnico na implantação.
Depois, o abrigo convida e administra sua equipe pelo aplicativo, sem usar o
painel Supabase. Cada pessoa tem sua conta. Continua sendo um único abrigo;
personalização e isolamento entre organizações não pertencem a esta entrega.
O pedido anterior de Permanecer logado/Esqueci a senha continua incluído no plano.

## Histórias e aceitação

### US1 — gerenciar equipe (P1)
Administrador vê pessoas ativas/inativas e convites pendentes, convida por nome,
e-mail e perfil e altera/desativa acessos. Funcionário realiza o manejo existente,
sem ver ou executar gestão de equipe. Convite não concede acesso antes do aceite.

### US2 — aceitar convite (P1)
Convidado abre o e-mail no dispositivo, confere abrigo/perfil/e-mail, define e
confirma sua senha e ativa a conta. Convite expirado, revogado, já consumido ou
vinculado a outro usuário é recusado. Somente a versão vigente pode ser aceita.
Após sucesso, volta ao login normal; nome/perfil vêm do servidor.

### US3 — controlar persistência (P2)
Permanecer logado controla restauração após encerrar o processo. Desmarcado:
sessão apenas em memória, sem guardar senha ou tokens de sessão no disco.
Marcado: SDK pode restaurar a sessão, sempre revalidando usuário/equipe no servidor.
Pausar o app não significa encerrá-lo. Sair remove persistência nos dois modos.

### US4 — recuperar senha (P2)
Usuário informa e-mail, recebe resposta neutra, abre link de recuperação, define
nova senha e retorna ao login. Sem criação pública de conta ou concessão de perfil.
Estado inválido/expirado permite solicitar outro link sem expor tokens.

## Requisitos

- **005-FR-001**: dois perfis server-side: administrator e employee. Ambos mantêm
  manejo/fotos/publicação/calendário; somente administrator gerencia equipe.
- **005-FR-002**: bootstrap técnico do primeiro administrador, auditado e único;
  nunca promover todos os funcionários legados ou aceitar papel vindo da UI.
- **005-FR-003**: convite com nome (1–100 caracteres), e-mail normalizado e perfil;
  padrão Funcionário. Confirmação da operação não promete entrega na caixa postal.
- **005-FR-004**: listagem paginada de equipe e convites; reenviar/cancelar convite,
  alterar perfil e desativar/restaurar acesso sem apagar o histórico de manejo.
- **005-FR-005**: validade proposta de 1 hora por convite; reenvio respeita limite
  de 60 s, invalida gerações anteriores e não duplica pessoa/convite ativo.
- **005-FR-006**: aceite prova identidade pelo Supabase Auth, confere destinatário,
  validade/geração, só ativa o vínculo após senha definida e confirmação atômica.
- **005-FR-007**: impedir desativar/rebaixar o último administrador, inclusive em
  concorrência; próprio administrador não desativa/rebaixa o próprio acesso.
- **005-FR-008**: revogação/rebaixamento afetam a próxima operação no servidor;
  invalidar contexto privado no app sem aguardar expiração do JWT. Auditoria
  guarda autor real, horário do servidor, alvo e ação, nunca senha/token.
- **005-FR-009**: falhas/duplicatas/timeout reconciliados por chave de operação;
  nenhuma falha de envio pode criar funcionário ativo ou elevar privilégios.
- **005-FR-010**: implementar a escolha de persistência sem perder verificador
  PKCE necessário à recuperação; não salvar senha nem registrar sessão em logs.
- **005-FR-011**: recuperação responde de forma neutra para e-mail existente ou
  inexistente, respeita limites do servidor; senha mínima de 12 caracteres e
  confirmação igual no aceite/redefinição, sem truncar/registrar o valor.
- **005-FR-012**: retorno de e-mail configurado em Android/iOS e allow-list
  Supabase, com callbacks separados para convite e recuperação e erros amigáveis.
  iOS permanece dependente de validação Mac/Xcode, sem alegar prova via Windows.
- **005-FR-013**: preservar login atual, logo e paleta, habilitando seus controles;
  novas telas e entrada Equipe no painel dependem de aprovação visual explícita.
  Voltar sempre à esquerda; botões de administração ausentes para Funcionário.
- **005-FR-014**: conta já ativa retorna Já faz parte da equipe; convites pendentes
  são reenviados, não recriados. Conta Auth existente sem vínculo não tem senha
  sobrescrita nem recebe papel automático: rejeitar com orientação ao suporte
  nesta primeira entrega. Mostrar esta limitação ao administrador e testá-la.
- **005-CR-001**: MVVM/Freezed, Repository abstrato, SDK/plugins somente Services,
  Result tipado, mensagens portuguesas; sem novo pacote nesta fase de planejamento.
- **005-CR-002**: regras de VM/Repository/Service com unitários, caminho feliz de
  cada tela com Widget, negações/concorrência SQL e HTTP, jornadas Android e CI.
- **005-CR-003**: commits por contexto na developer; documentação/tarefas atualizadas
  após evidência, não implementar telas antes da aprovação do desenho.

## Matriz de permissões

| Ação | Visitante | Funcionário | Administrador |
|---|---|---|---|
| Catálogo e ficha pública | Sim | Sim | Sim |
| Manejo, fotos, publicação, medicações | Não | Sim | Sim |
| Ver e gerenciar equipe | Não | Não | Sim |
| Convidar administrador | Não | Não | Sim |
| Definir própria senha por link válido | Sem manejo automático | Sim | Sim |
| Alterar dados clínicos de autoria passada | Não | Não por esta função | Não por esta função |

## Fora do escopo

Autoinscrição pública de abrigo/administrador, múltiplos abrigos, cobrança, novos
perfis, exclusão de usuários/histórico, MFA no app e publicação em lojas.
SMTP produtivo precisa ser configurado antes do uso real; testes locais usam
Mailpit. O protótipo não envia e-mails nem grava contas.
