# MCP oficial Dart/Flutter

O servidor é fornecido pelo SDK Dart e iniciado com `dart mcp-server`.
No computador de desenvolvimento, está registrado globalmente no Codex como
`dart-flutter`, com o executável do SDK usado pelo projeto, os caminhos locais
do Flutter/Android/Java e `--force-roots-fallback`.

Verifique a configuração com `codex mcp get dart-flutter`. A configuração pessoal
fica fora do Git. Não inclua credenciais do Supabase nesse servidor ou documento.

## Uso comprovado em 03/11/2026

Conexão STDIO com negociação MCP `2024-11-05`: servidor
`dart and flutter tooling` versão `0.1.2`. Foram executadas as ferramentas reais
`add_roots`, `list_devices` e `analyze_files`. O celular `2311DRK48G`, Android 15,
foi encontrado como dispositivo físico; a análise retornou `No errors`.
A ferramenta `run_tests` também executou 24 testes selecionados de autenticação,
permissões e calendário: todos passaram.

Como o catálogo deste chat foi carregado antes da configuração, a validação
inicial usa um cliente STDIO local conectado ao mesmo servidor oficial. Isso
não equivale a afirmar que o catálogo do chat foi recarregado. As respostas
locais estão em `.tools/mcp/`, ignoradas pelo Git. Nas novas sessões, confira
também a disponibilidade das ferramentas no catálogo do Codex.

Para análise e testes, prefira `analyze_files` e `run_tests`. Para execução,
use `launch_app`, conecte ao DTD retornado e consulte `get_widget_tree` antes
de usar `flutter_driver`. Não invente URIs de DTD nem seletores.

O entry point de exploração, quando necessário, é separado e local, restrito
a depuração e ao backend de testes. O APK normal deve ser restaurado ao fim.
Não há mudança de layout, dependências externas ou credenciais de produção.

## Skills oficiais

Instaladas no diretório pessoal de skills do Codex, sem sobrescrever a skill de
arquitetura nem as skills Spec Kit do repositório:

- Dez skills Flutter de `flutter/agent-plugins`, revisão
  `6f5b7b84846ebda117437f700d4be94cfb67efb6`.
- Quinze skills Dart de `dart-lang/skills`, revisão
  `d07cc31c09a5e8750c56c7a94dccd1c1c7aad165`.

A instalação foi feita pelo instalador de skills do Codex. Aplicar as skills
relevantes não autoriza mudar o layout aprovado nem adicionar pacotes externos
sem a justificativa exigida pelo projeto.

Referências: [MCP no Codex](https://developers.openai.com/codex/mcp),
[ferramentas oficiais Flutter](https://docs.flutter.dev/ai/get-started).


## Exploração no celular concluída

`launch_app`, conexão DTD, `get_widget_tree`, Flutter Driver, `hot_restart` e
`stop_app` foram exercitados na gravação física. A entrada local
`lib/main_mcp_local.dart` está ignorada pelo Git e restringe execução a depuração.
Ela não é usada por `lib/main.dart`. O APK normal foi restaurado ao fim.
A escolha dos controles usa a árvore inspecionada; seletores ambíguos e rótulos
diferentes foram corrigidos no roteiro, conforme o relatório da gravação.

## Atualização sem nova instalação

Após instalar a entrada de depuração autorizada no Xiaomi, `flutter attach --machine --print-dtd --target lib/main_mcp_local.dart` conectou-se ao APK existente. Essa versão do MCP não oferece attach: a CLI forneceu a URI DTD e o MCP oficial assumiu a inspeção/Flutter Driver pela conexão. A sessão pode usar hot reload/hot restart para alterações Dart; mudanças nativas podem exigir nova instalação. O APK de depuração permanece separado da entrada de produção.

O helper local de fila também passou a substituir seu marcador temporário ao repetir um identificador concluído, corrigindo uma falha da automação que não pertence ao aplicativo. Dados de entrada com credenciais fictícias são removidos ou redigidos depois da execução.
