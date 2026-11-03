# Convites e recuperação de senha na nuvem

Projeto de avaliação: `tcdmiudchyptbgjzrotj`. Acompanhamento: T063 em
`specs/006-management-search/tasks.md`. Não contém credenciais SMTP ou tokens.

## Entrega real do convite — 03/11/2026

Com o APK release corrigido em T066, administrador autenticado abriu Equipe →
Convidar pessoa e enviou um único convite de funcionário ao destinatário real
autorizado. O app confirmou o envio; banco registrou status pending, geração 1,
versão 2, criação às 22:23:13 UTC (19:23:13 em São Paulo) e validade de uma hora.
Brevo Transactional → Logs confirmou Sent e Delivered às 19h23, com o assunto
em português. Nenhum email foi enviado ao professor.

Isso comprova a integração Auth/Function/SMTP e a entrega ao servidor destinatário.
O aceite ainda não foi confirmado: a responsável deve abrir o link no próprio
celular e definir sua senha diretamente no app. Depois, conferir vínculo de
funcionário e testar a recuperação solicitada na mesma instalação, inclusive
recebimento, retorno PKCE e nova autenticação. T063 continua aberta.

Na conferência posterior, a responsável informou não ter recebido o convite.
O assunto não foi localizado na busca do Proton em Todos os emails; a pasta
Spam inspecionada estava vazia. Brevo manteve o evento Delivered e o destinatário
foi conferido, mas não apresentou nessa tela a resposta SMTP detalhada do receptor.
Portanto, não considerar recebimento na caixa de entrada ou abertura humana como
comprovados pelo evento do provedor. O convite continua pending, sem accepted_at.
Nenhum reenvio automático foi feito. Solicitado outro endereço da responsável,
mediante autorização, para um ensaio comparativo antes de concluir o diagnóstico.
Não modificar filtros antispam pessoais nem atribuir causa definitiva ao Proton
ou ao domínio do remetente sem evidência adicional.

## Comparação com Gmail e retorno ao aplicativo — 03/11/2026

Após autorização de um segundo destinatário, um único convite de funcionário foi
enviado pelo APK às 23:06:23 UTC (20:06:23 em São Paulo). A responsável confirmou
recebimento no Gmail, mas relatou navegador em branco ao abrir o link. O convite
permaneceu pending, sem accepted_at; o Auth já apresentava email confirmado e
last_sign_in_at às 23:06:35 UTC. Isso não comprova aceite, definição de senha ou
recebimento da sessão pelo aplicativo. Não atribuir o consumo da confirmação à
ação humana ou a um scanner sem evidência.

O endereço apresentado contém um redirecionamento do Google e outro de tracking
do Brevo. Não foi seguido pela automação nem armazenado no repositório. A
documentação Supabase alerta para reescrita de links por provedores de email,
mas essa evidência isolada não determina a causa da falha observada.

No Brevo, Settings → Transactional email → Tracking expôs apenas Anonymous
email tracking, cuja descrição mantém aberturas e cliques rastreados, removendo
a associação ao contato. Nenhuma opção foi alterada; anonimização não deve ser
registrada como desativação da reescrita. Não adicionar atributos ou cabeçalhos
de outros provedores aos templates como suposta correção.

MCP oficial Dart/Flutter list_devices confirmou o Android físico conectado.
ADB cmd package resolve-activity, com o endereço público auth/invite sem token,
resolveu para MainActivity do APK instalado. Essa consulta não abriu o link,
não mudou a sessão e não valida o percurso Gmail/Brevo/Auth até o app.
Solicitada confirmação de onde ocorreu a abertura: celular com APK instalado
ou Arc no computador. O fluxo atual exige abertura no Android; não existe
aplicação web de aceite no computador. Recuperação e aceite continuam pendentes.

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

## SMTP Brevo configurado em 03/11/2026

Inspeção inicial do painel Authentication → Emails → SMTP Settings em 03/11/2026:
`Enable custom SMTP` desativado. Nenhuma credencial foi consultada ou gravada.
O serviço padrão do Supabase restringe destinatários aos membros da organização
e não é adequado para convidar a equipe do abrigo. As contas de avaliação em
`example.test` não possuem caixas de entrada para teste de entrega.

Após a responsável criar/confirmar a conta gratuita Brevo e autorizar o uso
temporário de seu email pessoal, foi criada a credencial exclusiva
`Supabase Abrigo dos Anjos`, variante Standard, validade até 03/11/2027.
A responsável concluiu a verificação de identidade do provedor e autorizou
explicitamente a criação e conexão. O painel informa também inativação de chaves
após 90 dias sem envio; verificar essa condição antes de retomar um ambiente parado.

Configuração salva no Supabase e conferida após recarregar: SMTP personalizado
ativo, host `smtp-relay.brevo.com`, porta `587`, login SMTP específico do Brevo,
remetente temporário verificado e nome `Abrigo dos Anjos`. A credencial foi
transferida pelo botão Copiar e colada diretamente no campo protegido do painel.
Não foi escrita em arquivo, configuração versionada ou APK. A área de transferência
foi substituída por texto público após salvar. Não registrar o email pessoal no
repositório; ele poderá ser trocado pelo remetente oficial sem rebuild do app.

O Brevo mostra o remetente como verificado, com aviso de domínio de email gratuito
sem autenticação DKIM/DMARC própria. Isso ainda exige confirmar a entrega efetiva;
não implica aprovação para produção. Não adicionar membros à organização Supabase
para contornar restrições nem mudar as contas já entregues ao professor.

Os dois templates em `supabase/environments/cloud/supabase/templates/` foram
publicados pela CLI 2.122.0: assuntos e corpos HTML de convite/recuperação em
português, links `{{ .ConfirmationURL }}` preservados e nenhuma imagem/script
externo. Assuntos e fontes conferidos no painel; preview de recuperação revisado.
O `config diff` mostra os assuntos, mas o `config push` carrega também os arquivos
`content_path` e os publica como mudanças de conteúdo. Conferir ambos no painel
após publicar, sem considerar apenas o diff dos assuntos como prova do corpo.

Na etapa inicial de configuração, entrega e conclusão ainda não haviam sido
testadas. MCP oficial
Dart/Flutter `list_devices` não encontrou aparelho Android na conferência desta
etapa; foram listados apenas Windows, Chrome e Edge. Nenhum email de teste foi
disparado naquela etapa de configuração. A entrega posterior está registrada
no início deste documento.

Para repetir a implantação em outro ambiente, definir com a responsável um provedor
SMTP, remetente verificado e endereço real autorizado para teste. Inserir host, porta, usuário e
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
