# Exemplos de apresentação local — DEMO-FR-001

Solicitação/autorização em 2026-11-02: exemplos realistas com fotos ilustrativas,
substituindo a aparência técnica das fixtures no catálogo de visitantes.
**Não são animais reais do Abrigo dos Anjos.** Nome, idade, sexo, peso, cor,
temperamento, castração, datas/tipos de vacina e vermifugação são fictícios.
Não usar estes registros como prontuário, recomendação veterinária ou dados de produção.
As descrições públicas são textos de apresentação, sem avisos técnicos de fixture.

## Fonte das fotos

O manifesto animals.json registra URL de cada foto no Unsplash, SHA-256 e tamanho.
Licença consultada em 2026-11-02: https://unsplash.com/license — permite download e
uso; não revender imagens isoladas nem criar um banco de imagens concorrente.
Fotos reais são **ilustrativas**, sem relação afirmada com identidade/histórico
ou com os animais efetivamente acolhidos pelo abrigo. O script não usa API de busca.
Os JPEGs ficam em .tools/demo_animals/photos e são enviados ao bucket privado pelo
fluxo autenticado animal-photo-upload. Leitura pública passa por animal-photo-read;
não há URL pública de Storage nem alteração da autorização do aplicativo.

## Executar

Pré-requisitos: Supabase local em 127.0.0.1:54321, funções locais ativas, schema
migrado e conta fixture-staff@example.test provisionada. Credenciais somente em
supabase/.env.local ignorado pelo Git; ALLOW_LOCAL_FIXTURES=true explícito.

```powershell
python supabase/demo/prepare_presentation.py          # só mostra o plano
python supabase/demo/prepare_presentation.py --apply  # aplica no projeto local
```

A guarda recusa host/porta remotos. Baixa e confere todos os hashes antes de criar
registros. Cadastro, foto e publicação usam os mesmos endpoints autenticados do app,
com chaves idempotentes. Reexecutar não cria animais/fotos duplicados. Fichas já
existentes não são sobrescritas silenciosamente por um novo payload.

Depois de validar as oito fotos publicamente, oculta apenas o campo is_published
dos 60 IDs técnicos conhecidos que ainda mantêm nome e descrição originais de
fixture. Não exclui animais, fotos, medicações, históricos nem notas. Preserva os
três animais de agenda e cadastros manuais. Backup das publicações anteriores em
.tools/demo_animals/technical-publication-backup.json; resultado em import-result.json.
Se alguém editar um exemplo depois, reavalie a importação antes de reaplicar.

## Testes automatizados e apresentação

Este perfil é **manual e local**, não uma migration nem parte da CI. As 60 fixtures
técnicas permanecem no banco para testes. Rodar setup.ts pode republicá-las e
reinicializar os dados técnicos; use ambiente descartável de testes e reaplique
conscientemente o perfil de apresentação depois. Não execute reset do banco que
contém os cadastros manuais. Dados de produção devem ser cadastrados pelo abrigo.

## Validação — 2026-11-02

- Compilação sintática Python e dry-run PASS.
- Duas aplicações: 8 exemplos, sem duplicação; 60 fixtures preservadas/ocultas.
- Cadastro, upload JPEG, publicação e leitura **anônima** de cada foto PASS.
- Catálogo anônimo: 8 fichas, nenhuma descrição com “Fixture isolada”.
- Android normal: catálogo com 8 animais; ficha de Amora com foto, 12,4 kg,
  pelagem, temperamento, castração, datas/tipos de vacina e vermifugação conferidos.
- Nenhuma alteração em layout, código Flutter ou dependências do aplicativo.
