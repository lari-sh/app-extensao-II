# Validar

1. flutter pub get; flutter pub run build_runner build --delete-conflicting-outputs.
2. dart format --output=none --set-exit-if-changed lib test integration_test.
3. flutter analyze; flutter test --coverage; conferir fronteiras de arquitetura.
4. Android: catálogo -> ficha -> contato; nome certo, canais oficiais, nenhum
   preview de mensagem; Voltar do topo/rodapé/sistema retorna à mesma ficha.
5. Abrir cada canal sem apps sociais instalados; conferir destino sem enviar nada.
6. WhatsApp: rascunho com nome, sem autoenvio; ausência de URL real é limitação
   explícita até US2. Testar erro/duplo clique/animal ocultado entre telas.
7. Com host publicado autorizado: App Links verified, cold/warm start via link
   externo, fallback sem instalação e animal oculto/removido. adb com package
   forçado não comprova associação HTTPS. Registrar CI/APK e limitações reais.
