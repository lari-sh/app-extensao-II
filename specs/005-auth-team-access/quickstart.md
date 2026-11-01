# Roteiro de validação a executar na implementação

Estado atual: apenas planejamento e protótipo; os passos abaixo ainda não passaram.

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
