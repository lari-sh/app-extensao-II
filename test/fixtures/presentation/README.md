# Fotos ilustrativas para testes

Amora, Bento e Mel são personagens fictícios. Os JPEGs são as mesmas imagens
ilustrativas autorizadas em supabase/demo/animals.json (Unsplash); URLs, licença,
SHA-256 e tamanho estão naquele manifesto. Não representam os animais reais do
abrigo. Arquivos locais versionados tornam os testes offline e determinísticos.
Não há downloads durante flutter test. Testes de imagem validam a decodificação,
identificação e estados de falha, em vez de depender de um PNG vazio de 1 pixel.
