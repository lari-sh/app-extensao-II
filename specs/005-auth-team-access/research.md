# Decisões e referências

## Cadastro e perfis

Decisão confirmada pelo usuário: primeiro administrador provisionado; convites
pelo app. Papéis em tabela protegida e reconsultados no comando. Evitar
user_metadata editável como fonte de autorização. Alternativas rejeitadas:
autoinscrição pública como admin e exigir Supabase do funcionário.
[Supabase Users](https://supabase.com/docs/guides/auth/users).

## Envio privilegiado

Auth Admin inviteUserByEmail somente em Edge Function com segredo de servidor,
após verificar papel atual. Alternativa rejeitada: incluir service_role no Flutter.
[Admin invite](https://supabase.com/docs/reference/javascript/auth-admin-inviteuserbyemail).
Envio e transação de banco são separados: operação durável, estado incerto e
reconciliação necessários. Callback de convite não usa PKCE, pois remetente e
destinatário podem usar aparelhos diferentes.
[Restrição documentada](https://supabase.com/docs/reference/python/auth-admin-inviteuserbyemail).

Conta já confirmada retorna erro; não apagar/recriar a conta nem sobrescrever
senha como contorno. Usuário de convite ainda não confirmado admite novo envio
pela Admin Invite API. Definir expiração de 1 hora no Auth e no convite local;
validar prazo/geração no servidor mesmo após obter uma sessão de link.
[Implementação Auth](https://github.com/supabase/auth/blob/master/internal/api/invite.go).

## Recuperação e persistência

Recuperação utiliza resetPasswordForEmail e updateUser do SDK, com resposta neutra,
link permitido e evento passwordRecovery. Não usar um nome de rota como prova
de recuperação. Sessão válida é verificada; aceite também confere convite server-side.
[Reset](https://supabase.com/docs/reference/dart/auth-resetpasswordforemail),
[Update](https://supabase.com/docs/reference/dart/auth-updateuser).

O SDK instalado 2.18.3 oferece LocalStorage, SharedPreferencesLocalStorage e
EmptyLocalStorage. Adaptar persistência, mantendo senha apenas durante submissão.
Não limpar PKCE indiscriminadamente ao desmarcar lembrar sessão. Não adicionar
pacote de links: supabase_flutter já integra callbacks. Armazenamento criptografado
novo não foi incluído implicitamente; a limitação do armazenamento SDK atual deve
ser revisada antes de produção. Preferência não substitui autorização remota.

## Aprovação e ambientes

Protótipo é ilustrativo e não implementa autenticação. SMTP real, URL allow-list,
primeiro admin e validação iOS pertencem à implantação/etapas explícitas. Testes
locais usam Mailpit; não enviar convites a pessoas reais nesta etapa.
[E-mail local](https://supabase.com/docs/guides/auth/passwords).
