# Fixtures locais descartáveis

Preparação: T006. Execução: T023, somente após migrations T018/T019/T021.
Não requer save_animal, finalize ou outras RPCs futuras. Não importa demo_animals_v1.

Use .env.local ignorado, SUPABASE_URL=http://127.0.0.1:54321, chave administrativa
**local**, FIXTURE_PASSWORD exclusiva com 12+ caracteres e ALLOW_LOCAL_FIXTURES=true.
Executar da raiz: `npx --yes deno@2.8.3 task --config supabase/functions/deno.json fixtures`.
Carregue as variáveis no processo antes do comando; não as coloque na linha de comando.

Prepara 60 animais com paginação, publicado/privado/adotado, notas internas, PNGs,
contas staff/não staff e staff revogável. Visitante é cliente sem sessão, não conta.
Testes criam sessão do ator revogável e removem/revogam-na durante o cenário.
O script recusa hosts remotos e não registra tokens/senhas. Idempotente no banco
local reservado a esta suíte; não executar simultaneamente com testes mutáveis.
Imagens inválidas são bytes de texto com MIME de imagem; rejeição é testada no upload.
Nunca usar fixtures em homologação compartilhada ou produção.
