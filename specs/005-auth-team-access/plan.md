# Plano — acesso e equipe

Branch real: developer. Feature documental 005-auth-team-access. Data: 2026-11-01.
Gerado com SPECIFY_FEATURE_DIRECTORY e SPECIFY_FEATURE_NO_PERSIST=1; a identificação
de feature emitida pelo script não cria nem troca a branch de trabalho.

## Contexto e etapas

Flutter 3.41.1/Dart 3.11; Supabase Flutter 2.18.3, PostgreSQL 17, Edge Functions
Deno existentes. Provider/Freezed, flutter_test e integration_test existentes.
Nenhuma dependência Flutter nova planejada: SharedPreferences guarda somente a
preferência; LocalStorage do SDK é adaptado em Service para aplicar a escolha.
Armazenamento de sessão segue a infraestrutura atual do SDK; não alegar que isso
introduz criptografia de tokens. Revisão de armazenamento/backup pertence ao gate
de segurança da implantação. Não coletar nem persistir senha da equipe.

1. Aprovar proposta visual; migrar regras de perfil e bootstrap com testes.
2. Implementar convites/aceite e UI de equipe com testes de autorização.
3. Habilitar persistência/recuperação mantendo a composição do login.
4. Validar Android, CI, e-mails locais, documentação e pacote debug.

## Arquitetura

- Domain: modelos imutáveis TeamMember, TeamInvitation, TeamState e contratos
  TeamRepository/AuthRepository; SessionAccess passa a expor capacidades de equipe.
- Data Services: SupabaseTeamService, SupabaseAuthService e SessionStorageService.
  SDK Auth/Functions/Storage, callback e preferências encapsulados. Composição
  inicial é a única exceção de inicialização do SDK.
- Repositories: TeamRepositoryImpl/AuthRepositoryImpl, mapeamento DTO/Result,
  coordenação de sessão/operação incerta, sem chave administrativa no aplicativo.
- UI: lib/ui/features/team/{view_models,views}/ e auth/{view_models,views}/.
  VMs controlam permissões, validações e estado; Views recebem estado/callbacks.
- App: bootstrap/router/AuthApplication injetam dependências e direcionam callbacks
  para aceite/recuperação antes de abrir manejo. Recuperação não navega sozinha
  para painel; concluir senha, sair da sessão temporária e pedir login normal.

## Backend e integridade

Migration seguinte disponível (sem renumerar migrations existentes) acrescenta
role e version a staff_members, convites e eventos privados. Backfill de membros
legados: employee; primeiro administrator é promovido explicitamente pelo operador.
Não expor bootstrap público. Role real é consultada na tabela protegida, não em
user_metadata fornecido pelo usuário ou JWT desatualizado.

Bootstrap é um comando técnico com segredo de servidor que cria a reserva de
convite do primeiro administrador e envia o e-mail de definição de senha. Não
compartilhar senha temporária. O vínculo fica sem acesso ativo até o aceite;
o caminho técnico só admite a reserva inicial e registra ator de sistema.

Edge Function team-invitation valida JWT/sessão/admin, reserva uma operação e chama
Auth Admin no servidor. Revalida administrador e geração ao finalizar, após chamada
externa. Falha deixa convite não aceito e nenhum vínculo ativo. Requisições com
mesma chave retomam/reconciliam a operação em vez de reenviar e-mail às cegas.
Admin API e PostgreSQL não são uma transação única: persistir estados de envio
e comprovante de resposta; reconciliar timeout antes de novo envio. Limitar
frequência/volume no servidor, além de respeitar Auth rate limits.

Aceite associa auth.uid verificado ao destinatário vinculado à reserva do convite;
ignora role/user_id sugeridos pelo cliente. Transação bloqueia geração/convite,
confere prazo, revogação e senha definida, ativa membro e registra evento uma vez.
Para contas novas criadas pelo convite, a prova de senha é consultada no servidor
em auth.users (hash não vazio, nunca retornado ao cliente), não um booleano vindo
da tela. A query privilegiada é restrita ao usuário reservado para aquele convite.
Se a senha foi salva e o aceite falhou, o vínculo segue pendente e a operação
pode ser retomada; não exigir troca de senha repetida para ativar o mesmo convite.
Novos convites não ativam staff_members antes desta transação. Reenvio/revogação
invalidam a geração anterior. Conta Auth já existente sem vínculo recebe resultado
controlado existing_account; não redefinir senha ou promover como contorno.

Alterações de perfil/estado usam versão esperada e lock comum para proteger último
admin sob concorrência. Sessão atual e role são revalidadas no ponto da escrita,
inclusive após locks. Auditoria append-only conserva autores das medicações.
Mesmo se a sessão Auth de convite continuar válida, convite revogado não pode
ativar membro e a pessoa sem vínculo ativo continua sem manejo.

## E-mail, callbacks e persistência

Convite por inviteUserByEmail não usa PKCE; planejar callback de invite tratado
pelo SDK, sem assumir exchangeCodeForSession. Recuperação usa fluxo suportado
resetPasswordForEmail/passwordRecovery/updateUser com PKCE do SDK. Nunca registrar
URL completa, códigos, tokens ou senha. URI específica do aplicativo + hosts/path
distintos por finalidade, allow-list exata, tratamento de link frio/quente e estados
inválidos. Deep link de e-mail não equivale a hospedagem da ficha de adoção cancelada.
SMTP e templates dependem da configuração de implantação, não do aparelho do abrigo.
Prazo inicial de 1 hora alinhado à configuração Email OTP Expiration; efetividade
é o menor prazo entre Auth e convite. Reenviar usa novamente a Admin Invite API
para usuário não confirmado, não auth.resend(type: invite), que não é suportado.

Permanecer logado marcado mantém comportamento atual de restauração. Desmarcado
limpa a sessão persistida antes de autenticar e impede novas escritas de sessão;
token em memória continua válido enquanto o processo vive. Verificador PKCE é
separado e limitado à operação, permitindo retorno de recuperação após fechar o
processo. Sair cancela operações, limpa sessão e preserva bloqueio de acesso
existente. Falha no armazenamento não concede login persistente silencioso.

## Constitution Check — antes e após desenho técnico

| Princípio | Evidência no plano |
|---|---|
| Arquitetura Flutter | UI por feature, dados/domínio por tipo; VM/Repository/Service |
| Widgets enxutos | Sem consultas/Supabase nem decisões de perfil em build |
| Estado e validações | Freezed, ChangeNotifier, capacidades explícitas |
| Persistência e SDK | Somente Services/composição; Admin API só servidor |
| Erros | Result, mensagens neutras/amigáveis, reconciliação |
| Testes | Unitários por regra, Widget por tela, SQL/HTTP/Android/CI |
| Pacotes | Nenhum novo pacote planejado |
| Nomes e idioma | Inglês em código, português na interface |
| Commits | Conventional Commits com 005-FR/CR, developer |
| Design | Proposta separada, aprovação pendente antes de código de UI |

Checagem arquitetural conforme; gate de implementação visual ainda fechado.
Nenhum arquivo em lib/, migrations, Functions ou pubspec será alterado nesta fase.


### Dependência de teste para a meta de 95% (2026-11-02)

Adicionar `shared_preferences_platform_interface: 2.4.2` somente em dev_dependencies.
A versão já integra o lockfile como dependência transitiva de shared_preferences.
Justificativa: usar o armazenamento oficial em memória para testar a composição
real da aplicação e o ciclo de sessão/favoritos sem acessar preferências do
computador. Não muda o armazenamento produtivo nem adiciona pacote ao app.
