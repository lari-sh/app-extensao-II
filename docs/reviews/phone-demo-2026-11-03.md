# Demonstração Android no celular — 03/11/2026

Arquivo local: `.tools/videos/2026-11-03/abrigo-dos-anjos-demonstracao-celular.mp4`.
Roteiro: `README.txt` na mesma pasta. Vídeo não publicado no Git.

- Dispositivo físico: Xiaomi 2311DRK48G, Android 15/API 35.
- Duração: 06:55; tamanho: 14971575 bytes.
- Exportação H.264, 720×1600, 30 fps, sem áudio; captura Android de frequência variável.
- SHA-256: `0ba97b65897c5d8a87d457369b593c8c9b694ee1d5f7c917101e0616c44b3be8`.
- Decodificação integral FFmpeg PASS; quadros dos capítulos revisados.
- Kanban recapturado com margens reduzidas, títulos de 11 sp, altura uniforme e prévia de até 80 caracteres/3 linhas; seis cenas substituídas, preservando duração e capítulos.

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

## Atualização do Kanban aprovado

T055: seis intervalos substituídos por capturas atuais do mesmo celular, controladas pelo MCP oficial. Sem sobreposição de um quadro artificial: cada cena mostra o aplicativo real. Intervalos (segundos): 45,50–49,00; 82,00–90,20; 144,40–153,00; 247,00–255,00; 277,00–287,50; 328,00–334,00. Revisadas entradas e saídas para eliminar aparições do quadro anterior.

Cenas recapturadas com os dados atuais (Aurora já disponível após as aplicações concluídas), sem alterar tratamentos ou animais. Os demais fluxos são os registros originais; a montagem demonstra funcionalidades e não representa uma tomada contínua nem uma nova execução de todas as operações. O screenrecord omite quadros finais estáticos; o último quadro nativo foi mantido durante esse intervalo real para conservar a duração.

Duração mantida em 415,33 s, capítulos preservados, nova decodificação integral FFmpeg PASS e revisão visual dos seis cortes. Temporários de vídeo removidos somente após conferir o hash do arquivo final. get_runtime_errors na recaptura: No runtime errors found. APK normal reinstalado e aberto no painel administrativo.

## Cartões uniformes e conexão mantida

Após a nova solicitação, as mesmas seis cenas foram recapturadas com altura uniforme e observações limitadas a 80 caracteres/3 linhas. O clique no card de Amora abriu o editor e mostrou a nota completa; não houve edição ou salvamento dos dados. Capturas de conferência: .tools/mcp/uniform-cards-phone.png e uniform-note-full-phone.png. Nova montagem com duração/capítulos preservados, revisão das seis cenas e decodificação integral PASS.

A versão de depuração instalada com autorização ficou conectada por flutter attach e MCP; hot_reload retornou Hot reload succeeded, sem nova instalação. Essa conexão foi mantida para reduzir os pedidos de instalação enquanto a responsável descansa. O entry point de produção permanece sem Driver.
