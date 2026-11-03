# Convites e recuperação de senha na nuvem

Projeto de avaliação: `tcdmiudchyptbgjzrotj`. Acompanhamento: T063 em
`specs/006-management-search/tasks.md`. Não contém credenciais SMTP ou tokens.

## Configuração aplicada em 03/11/2026

O painel Auth apresentava Site URL `http://localhost:3000` e nenhum redirect.
A CLI oficial Supabase 2.122.0 aplicou somente as duas propriedades declaradas em
`supabase/environments/cloud/supabase/config.toml`:

| Propriedade | Valor |
|---|---|
| Site URL (retorno padrão) | `br.org.abrigodosanjos.app://auth/recovery` |
| Redirect de convite | `br.org.abrigodosanjos.app://auth/invite` |
| Redirect de recuperação | `br.org.abrigodosanjos.app://auth/recovery` |

O app instalado é necessário para abrir esses esquemas; não existe página web de
recuperação nem hospedagem da ficha pública. Convite e recuperação solicitam seus
redirects explicitamente no servidor e no Service, respectivamente. A lista é
exata, sem curingas. Não adicionar localhost ao ambiente hospedado de avaliação.

Reprodução a partir da raiz do repositório, com CLI já autenticada:

```powershell
npx --yes supabase@2.122.0 config diff --project-ref tcdmiudchyptbgjzrotj --workdir supabase/environments/cloud --agent no --output-format text
npx --yes supabase@2.122.0 config push --project-ref tcdmiudchyptbgjzrotj --workdir supabase/environments/cloud --agent no --output-format text
```

Revisar o diff antes de confirmar. A CLI nessa versão preserva propriedades não
declaradas: confirmações, MFA, limites, pooler e Storage não foram alterados.
Não usar o config.toml local completo para esta implantação. Nova leitura após
aplicar: `0 update, 8 remote-only, 0 local-only`; remote-only não será sobrescrito.

## Dependência externa: serviço SMTP

Inspeção do painel Authentication → Emails → SMTP Settings em 03/11/2026:
`Enable custom SMTP` desativado. Nenhuma credencial foi consultada ou gravada.
O serviço padrão do Supabase restringe destinatários aos membros da organização
e não é adequado para convidar a equipe do abrigo. As contas de avaliação em
`example.test` não possuem caixas de entrada para teste de entrega.

Antes de concluir T063, definir com a responsável um provedor SMTP, remetente
verificado e endereço real autorizado para teste. Inserir host, porta, usuário e
senha SMTP diretamente no painel Supabase; nunca no chat, APK, Git ou neste
arquivo. Confirmar o domínio/remetente no provedor conforme suas instruções.
Não contratar plano pago, adicionar membros à organização para contornar a
restrição de email nem alterar contas existentes para simular uma entrega.

No painel Authentication → Emails, revisar os templates de convite e recuperação
em português, preservando `{{ .ConfirmationURL }}` como destino de confirmação.
Não substituir esse destino diretamente por `.SiteURL` ou `.RedirectTo`: a
confirmação precisa passar pelo Auth antes do retorno ao app. Desativar rastreamento
de links do provedor caso ele reescreva links de autenticação. Preservar limites
de envio existentes durante a primeira validação.

## Roteiro de aceitação após configurar SMTP

1. Confirmar remetente verificado, SMTP ativo e allow-list exata por leitura de
   retorno. Não registrar senha, URL completa de confirmação, código ou token.
2. Com destinatário de teste autorizado e ainda não cadastrado, convidar pelo app
   usando administrador; conferir recebimento, remetente, texto e retorno
   `auth/invite` no Android. Confirmar o perfil de funcionário pelo fluxo normal.
3. Conferir que funcionário não convida equipe e visitante não acessa manejo;
   testar link inválido/expirado sem conceder acesso. Não usar o professor como
   destinatário automático de ensaios.
4. No Android, solicitar recuperação para a conta real de teste, no próprio app.
   Abrir o email no mesmo aparelho/instalação para preservar o verificador PKCE.
   Conferir retorno `auth/recovery`, salvar nova senha e realizar novo login.
   Não solicitar recuperação para uma conta de avaliação compartilhada sem
   combinar a mudança de senha com a responsável.
5. Reutilizar link consumido e confirmar recusa; conferir encerramento de sessão
   após recuperação. Repetir retorno com app aberto e encerrado, sem apagar os
   dados do app entre solicitação e abertura do link PKCE.
6. Registrar horários, cenário, resultado, identificadores não sensíveis e
   evidência de recebimento sanitizada. Resposta HTTP de envio aceita, isoladamente,
   não comprova entrega nem conclusão do fluxo no Android.

Até concluir esses passos, T063 permanece aberta. Testes locais/CI com SMTP
isolado não substituem esta validação. A configuração dos redirects não exige
rebuild do APK; o código já contém os dois caminhos.

Fontes oficiais: [SMTP](https://supabase.com/docs/guides/auth/auth-smtp),
[deep links móveis](https://supabase.com/docs/guides/auth/native-mobile-deep-linking)
e [templates](https://supabase.com/docs/guides/auth/auth-email-templates).
