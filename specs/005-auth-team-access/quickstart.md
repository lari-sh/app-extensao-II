# Roteiro de validação a executar na implementação

Estado atual: apenas planejamento e protótipo; os passos abaixo ainda não passaram.

## Fundação implementada — bootstrap técnico

Migration 202611010016 acrescenta perfis sem promover membros existentes; todos
continuam employee. O primeiro administrador não é criado automaticamente e a
reserva sozinha não concede manejo. Esta fundação ainda não envia convites.

Após implementar envio/aceite (T008/T014), o operador deve usar ambiente confiável:

1. Criar usuário Auth não confirmado com Admin API, sem compartilhar senha.
2. Por conexão SQL privilegiada, chamar
   `private.bootstrap_team_administrator(user_id, email, display_name)` com o ID
   retornado pelo Auth e e-mail idêntico. A função não é um endpoint público e
   anon/authenticated não têm EXECUTE. Reserva única, prazo de 1 hora, auditoria.
3. Enviar convite Auth para esse usuário ainda não confirmado. A pessoa define
   sua senha pelo fluxo de aceite antes de ativar o vínculo reservado.
4. Se o envio falhar ou expirar, reconciliar/reemitir pela operação técnica
   prevista na etapa de envio, mantendo o mesmo destinatário e nova geração.
   Nunca promover alguém via user_metadata nem remover o ledger de bootstrap
   para tentar novamente. Não aplicar este roteiro incompleto em produção.

Para validar somente a fundação local, sem reset ou usuários reais:
`supabase test db` e `python supabase/tests/fixtures/team_foundation_flow.py`.
O harness exige ALLOW_LOCAL_FIXTURES=true/URL local, usa contas próprias e remove
apenas suas fixtures. A desativação temporária do trigger na limpeza ocorre
dentro de lock exclusivo e transação, reabilitada antes do commit; não é um
procedimento de operação/produção.

## Jornadas restantes

1. Ambiente local separado ou fixtures dedicadas, preservando cadastros manuais.
   Provisionar dois administradores, um funcionário e um destinatário novo.
   Nunca aplicar bootstrap/migration diretamente em produção sem etapa própria.
2. Administrador convida funcionário; conferir Mailpit e estado pendente sem manejo.
   Abrir link no Android (processo aberto e encerrado), definir senha, aceitar e
   entrar. Funcionário maneja animais/medicações, mas gestão de equipe é negada
   tanto pela UI como por chamada direta.
3. Convidar administrador; alterar perfil, desativar e restaurar funcionário.
   Outra sessão perde autorização na próxima requisição. Proteger último admin
   sob duas requisições simultâneas e impedir ações sobre o próprio acesso.
4. Reenviar/cancelar/expirar convite; link anterior e outra identidade não ativam
   acesso. Simular timeout na resposta/envio, reconciliar sem e-mail/vínculo duplicado.
   Conta já ativa e conta Auth sem vínculo produzem os resultados especificados.
5. Login marcado/desmarcado, kill/relaunch Android, reinicialização, revogação e
   logout; desmarcado não restaura, marcado revalida antes de abrir manejo.
6. Recuperação para conta existente/inexistente com mesma mensagem; link
   frio/quente, expirado e repetido; senha nova funciona, antiga não; sem gravar
   senha em logs. Concluir recuperação retorna ao login, sem entrada automática.
7. Geração determinística, formato, analyze, Flutter unitários/Widgets, pgTAP e
   testes HTTP antes do Android. CI mantém as sete jornadas existentes e adiciona
   equipe/recuperação. Registrar execução/SHA/artifact reais em validation.md.
8. iOS requer Mac/Xcode e aparelho/galeria/links próprios; registrar pendência
   externa quando indisponível. SMTP produtivo validado separadamente.
