# Abrigo dos Anjos

Primeira versão Flutter do aplicativo de adoção e manejo do Abrigo dos Anjos, desenvolvido para a disciplina Extensão II. Prioridade Android, com estrutura iOS gerada e código Dart compartilhado.

## Implementado

- Tela inicial com o logo original e paleta vermelha/marrom do protótipo.
- Catálogo, busca por nome, filtros de espécie/porte/sexo e favoritos.
- Detalhes, disponibilidade para adoção e cópia de mensagem de interesse.
- Área de demonstração do voluntário, explicitamente sem login real.
- Painel Kanban com arraste por toque prolongado, alteração de status por menu e visualização em lista.
- Cadastro/edição, vacinação, vermifugação e medicações de exemplo.
- Persistência local dos cadastros de demonstração e favoritos, com tratamento de erro ao salvar.
- Interface em português brasileiro e suporte à rolagem em telas pequenas.

## Executar

Requer Flutter 3.41.1 / Dart 3.11 ou versão compatível e SDK Android configurado.

```sh
flutter pub get
flutter devices
flutter run -d <id-do-dispositivo>
```

No computador onde o projeto foi iniciado, o SDK está em `C:\Users\Larissa\.puro\envs\stable\flutter`. Se `flutter` não estiver no PATH, no PowerShell:

```powershell
& "$env:USERPROFILE\.puro\envs\stable\flutter\bin\flutter.bat" pub get
& "$env:USERPROFILE\.puro\envs\stable\flutter\bin\flutter.bat" run
```

Para Android: concluir o assistente do Android Studio, instalar SDK/Build Tools/Command-line Tools, executar `flutter doctor --android-licenses` e conectar um celular com depuração USB ou iniciar um emulador. Conferir com `flutter doctor -v`.

Para iOS: usar um Mac com Xcode e configurar assinatura/identificador de aplicativo antes de executar no dispositivo. A compilação iOS ainda não foi validada.

## Verificar e gerar APK

```sh
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build apk --debug
```

O APK fica em `build/app/outputs/flutter-apk/app-debug.apk`. O workflow GitHub Actions executa essas verificações e disponibiliza o APK de depuração como artifact quando a execução é bem-sucedida. Não é uma versão assinada para publicação na loja.

## Estrutura

- `lib/models`: modelo de animal e dados fictícios.
- `lib/data`: armazenamento local de demonstração.
- `lib/screens`: início, catálogo, detalhes, painel e formulário.
- `lib/widgets`: elementos visuais compartilhados.
- `lib/theme.dart`: identidade visual.
- `assets/images/logo.png`: logo fornecido no protótipo.
- `test`: testes de navegação, cadastro e persistência.

## Limites desta entrega

Esta versão é uma demonstração funcional, não um sistema de produção. Usa dados fictícios e ícones provisórios em lugar de fotos. Não oferece autenticação, permissões por perfil, backend, sincronização entre dispositivos, upload/câmera, notificações, exclusão ou envio real de solicitações de adoção. O canal oficial de contato ainda precisa ser informado pelo abrigo.

O armazenamento em preferências é exclusivo para a demonstração. Não inserir dados pessoais reais, prontuários ou informações críticas. A próxima etapa deve substituir esse armazenamento por um repositório com banco, autenticação e controle de acesso; a tela de demonstração não representa uma barreira de segurança.

Os valores de saúde exibidos são exemplos de interface, não orientações clínicas.

## Próxima etapa

1. Definir backend, perfis e regras de acesso com o abrigo.
2. Implementar login e persistência em banco, separando campos públicos dos registros internos.
3. Integrar fotos e contato oficial para adoção.
4. Validar em dispositivo Android e preparar assinatura/publicação.
5. Validar o projeto iOS no macOS.

Referência visual: protótipo `abrigo-dos-anjos-figma.html`, consultado pelo MCP, com as cores atualizadas do logo. O canvas/editor do protótipo não faz parte do app final.
