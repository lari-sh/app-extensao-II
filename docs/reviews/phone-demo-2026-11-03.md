# Demonstração Android no celular — 03/11/2026

Arquivo local: `.tools/videos/2026-11-03/abrigo-dos-anjos-demonstracao-celular.mp4`.
Roteiro: `README.txt` na mesma pasta. Vídeo não publicado no Git.

- Dispositivo físico: Xiaomi 2311DRK48G, Android 15/API 35.
- Duração: 06:55; tamanho: 14045553 bytes.
- Exportação H.264, 720×1600, 30 fps, sem áudio; captura Android de frequência variável.
- SHA-256: `a02020362bc9dc3afdca78965d7dbcb4976edc03496e5178d4da08553ad0897b`.
- Decodificação integral FFmpeg PASS; quadros dos capítulos revisados.
- A gravação antecede a solicitação posterior de reduzir margens do Kanban.

## Fluxos demonstrados

| Área | Evidência |
| --- | --- |
| Visitante | Catálogo, pesquisa por espécie/sexo, ficha com foto, vacinas por nome/data, vermifugação, peso, cor, castração e temperamento |
| Favoritos e contato | Adicionar/remover favorito de demonstração; canais oficiais de adoção; contatos do Sobre e cópia do Pix |
| Autenticação | Login, saída, recuperação real por e-mail local, nova senha e entrada com a senha alterada |
| Permanecer logado | Sessão administrativa restaurada após hot restart pelo MCP, sem repetir credenciais |
| Manejo | Kanban, Lista, calendário, filtros, cadastro de Aurora, situação manual e publicação |
| Fotos | Candidato JPEG ilustrativo, envio e confirmação; seletor pessoal omitido por privacidade |
| Medicações | Programação fixa criada, alternativa por intervalo visualizada, tratamento interrompido sem apagar atrasadas, conclusão e correção com histórico |
| Situação automática | Aurora manteve tratamento com pendências; após ambas serem concluídas, atualização do painel mostrou 5 disponíveis, 3 em tratamento, 1 em quarentena |
| Equipe | Convite/aceitação de funcionária fictícia; menus por perfil; alteração de perfil, desativação e restauração apenas de Marina |

Todas as alterações desta demonstração usam dados fictícios do backend local.
Nenhuma mensagem externa foi enviada. Aurora usa foto ilustrativa, não representa
um animal real do abrigo. O favorito anterior de Thor foi preservado. A conta
Marina voltou a funcionária ativa, e o APK normal ficou autenticado no painel.

## MCP, testes e limites

Servidor oficial `dart and flutter tooling` 0.1.2, conectado por STDIO real.
`add_roots`, `list_devices`, `analyze_files`, `run_tests`, `launch_app`, conexão
DTD, inspeção de widgets, comandos Flutter Driver, hot restart e `stop_app`
foram utilizados. Análise sem erros; 24 testes selecionados PASS pelo MCP.
A suíte integral anterior permanece em 593 PASS, 7010/7077 linhas = 99,05%.

A leitura final de `get_runtime_errors` retornou dois registros da automação:
um `waitFor` com rótulo singular diferente do texto atual e um seletor de texto
ambíguo entre o campo preenchido e o cartão Aurora. As seleções foram corrigidas
e os fluxos concluídos; esses registros não são tratados como exceções do
código funcional. O catálogo ainda exibia a flexão cosmética “1 animais
encontrados” nesta captura. Não se declara cobertura visual de todos os cenários.

Galeria e launcher pessoais foram excluídos dos arquivos. A captura final mostra
somente o aplicativo; esperas e digitação foram cortadas. Depois da validação,
os brutos, prévias e a gravação anterior desatualizada foram removidos.

## Capítulos

00:00 — Início
00:06 — Visitantes: busca, ficha, favorito e adoção
00:28 — Sobre: contatos e doação Pix
00:45 — Painel: Kanban, Lista e filtros
00:56 — Aplicação e correção com histórico
01:26 — Cadastro do animal
01:39 — Foto, situação e publicação
02:35 — Convidar e aceitar acesso da equipe
03:11 — Medicações: programação e interrupção
04:02 — MCP: busca, agenda e situação automática
04:52 — Recuperar acesso e definir nova senha
05:20 — Permanecer logado e restaurar a sessão
05:33 — Equipe: perfis, desativação e restauração
06:19 — Conferência pública: ficha, favorito, contato e Pix

CI remota: conferir após os últimos contextos, conforme orientação da responsável;
resultado registrado em `specs/006-management-search/validation.md`.
