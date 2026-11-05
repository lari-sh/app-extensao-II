# Ferramentas de desenvolvimento

- Use o servidor MCP oficial Dart/Flutter para análise, testes, dispositivos,
  inspeção de widgets e operações de execução que ele oferecer. Registre a
  ferramenta utilizada e o resultado real. Se ela estiver indisponível ou não
  suportar a operação, explique a limitação antes do fallback pela linha de comando.
- Antes de interagir com a interface pelo MCP, consulte `get_widget_tree` e use
  somente seletores observados. Use uma entrada de depuração separada para Flutter
  Driver; nunca habilite essa extensão no entry point de produção.
- ADB continua permitido para recursos do Android, como captura da tela,
  transporte USB e seletor nativo. Evite gravar galerias, notificações ou contas
  pessoais; capture somente o aplicativo e os dados fictícios autorizados.
- Preserve a constituição, a arquitetura vigente, o design aprovado e os commits
  por contexto na branch `developer`. As tarefas continuam em
  `specs/006-management-search/tasks.md` e nos documentos apontados pela skill
  `speckit-implement`; não copie a lista de tarefas para skills ou este arquivo.

Configuração e verificação: [docs/development/flutter-mcp.md](docs/development/flutter-mcp.md).
