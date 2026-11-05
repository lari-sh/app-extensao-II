# APK Android para avaliação na nuvem

Requisito 006-FR-015. Entrega de avaliação conferida em 03/11/2026, com backend
Supabase hospedado e APK release normal instalado no celular. O computador da
aluna não serve o backend desse pacote; internet continua necessária.

## Projeto implantado

- Projeto: projeto-extensao-II, organização lari-sh, plano gratuito.
- Referência: tcdmiudchyptbgjzrotj; região us-east-1.
- API: https://tcdmiudchyptbgjzrotj.supabase.co.
- 21 migrations existentes aplicadas e histórico remoto conferido.
- Functions animal-photo-read, animal-photo-upload, animal-photo-cleanup e
  team-invitation implantadas pela CLI oficial 2.122.0.
- Todas as tabelas públicas com RLS; bucket animal-photos privado.
- PHOTO_CLEANUP_SECRET exclusivo configurado nas Functions, fora do aplicativo.

Implantação feita com project-ref explícito, sem reset, seed de testes ou alteração
no banco local. Foram usados db push --dry-run, db push, db query e functions deploy.
A autenticação da CLI foi autorizada pela responsável. Não houve consulta com
--reveal nem extração de service_role/secret key para o computador.

## Contas e exemplos

A responsável criou e confirmou as duas contas no painel Auth. Uma operação SQL
administrativa verificou as identidades exatas, associou administrador e funcionário
e registrou evaluation_provisioned no histórico. Esta é a alternativa de
provisionamento manual solicitada, sem enviar convites ou emails.

O acesso do professor usa avaliacao.funcionario@example.test. A senha deve ser
comunicada pela responsável separadamente. O acesso de administrador não acompanha
o pacote. O TXT e o JSON temporários com senhas foram apagados após os testes;
nenhuma senha foi colocada no Git, no manual ou no APK.

Oito exemplos fictícios com fotos ilustrativas foram cadastrados pelos endpoints
autenticados existentes: Amora, Bento, Luna, Thor, Mel, Nina, Simba e Theo. Fotos
locais conferidas pelo SHA-256 do manifesto antes do upload; todas as oito foram
lidas anonimamente pela Function pública, mantendo o Storage privado. Origem/licença
em supabase/demo/animals.json. Nenhum prontuário ou usuário local foi exportado.

Agenda simulada de 3 a 5 de novembro de 2026: Amora e Bento em tratamento, Mel em
quarentena; horários fixos e intervalos. Dia 03 com seis aplicações. A contagem
inicial do manejo é 5 disponíveis, 2 em tratamento e 1 em quarentena, total 8;
pode evoluir com as operações e o encerramento dos tratamentos.

## Verificações executadas

- 15 verificações HTTP PASS: catálogo público, bloqueio dos dados internos,
  medicações/equipe sem login, bloqueio de upload/convite/limpeza sem autorização,
  sessões de funcionário e administrador, restrição de equipe do funcionário,
  manejo de oito animais e edição de ficha sem perder foto/dados públicos.
- Criação de oito fichas, upload e publicação com usuário funcionário PASS.
- Agenda com seis aplicações simuladas via RPC autenticada PASS.
- MCP oficial list_devices identificou o Xiaomi 2311DRK48G Android 15/API 35.
- APK release instalado via ADB PASS, sem transporte ADB reverse para o backend.
- No celular: catálogo com oito animais e fotos, ficha de Amora com vacinas no
  formato nome/data, login de funcionário, Kanban com totais 5/2/1 e agenda PASS.
- Aplicação simulada de Bento às 08h concluída no celular; autor Funcionário de
  avaliação e horário real 03/11/2026 às 15h21 confirmados na interface e por RPC.
  O banco registrou 2026-11-03T18:21:38.504225+00:00; não foi usado relógio do app.

MCP usado para ferramentas oferecidas, testes AppConfig e análise na preparação.
Release não expõe a árvore/Flutter Driver: interface final foi validada por ADB.
Não afirmar que esta conferência manual exercitou todas as jornadas da CI.
Evidências locais em .tools/cloud, sem credenciais nos arquivos de validação.

## Arquivo para compartilhar

Caminho local: entrega-professor/abrigo-dos-anjos-avaliacao.apk.

- Versão 1.0.0+1; Android mínimo API 24/Android 7.
- 59.896.931 bytes, aproximadamente 60 MB ou 57,1 MiB.
- SHA-256 atual: abe3a1dae090df2b20ef36ebc01a6e71fc0881f2a5e8f37b82dba97efb2f52cf.
- Release pelo entry point lib/main.dart, sem Flutter Driver ou HTTP local.
- Assinatura de avaliação Android Debug, verificada com apksigner.
- Certificado SHA-256: 966af201b6ef1563a13d3d24c286c1a4a0d258598900f02ffde312b52fa275ad.

É o mesmo arquivo instalado no celular da responsável. Assinatura de teste serve
para avaliação por instalação manual; não é uma publicação na Play Store.
APK, configurações públicas locais e pacote de entrega são ignorados pelo Git.
O manual de instalação fica em docs/user-guide e é copiado para a pasta de entrega.

Atualização em 03/11/2026: menu Equipe e acessos desvinculado do carregamento dos
animais, preservando autorização administrativa real. Release atualizado no
celular; menu e listagem das duas contas confirmados. 38 testes selecionados e
análise/formato pelo MCP oficial PASS. O hash anterior added5799... identifica
o APK antes dessa correção; a CI #194 abaixo validou a revisão anterior, não este
novo commit. A CI da correção será conferida separadamente.

## Reproduzir o build

Criar .env.cloud.json ignorado com somente SUPABASE_URL e
SUPABASE_PUBLISHABLE_KEY do projeto hospedado. Não incluir senhas, ALLOW_LOCAL_HTTP,
service_role, sb_secret ou token de gestão. O helper recusa campos extras,
URL local, chave privilegiada e anon JWT de outro projeto; o preflight confere
as colunas públicas atuais, mas não substitui os testes de autorização.

```powershell
python scripts/build_cloud_apk.py --config .env.cloud.json --check-only
python scripts/build_cloud_apk.py --config .env.cloud.json --flutter <caminho-do-flutter.bat>
```

Usar Flutter 3.41.1, JDK 21, SDK Android configurado e dependências aprovadas no
lockfile. O helper usa --pub para atualizar os registros nativos ao sair dos testes
para release. O primeiro build com --no-pub falhou por referência residual de
integration_test; o build normal e a regressão Python passaram depois da correção.
Não editar registrantes gerados ou fontes do SDK manualmente.

## Limites conhecidos

Convite e recuperação na nuvem validados em 04/11/2026 (T063): convite
recebido/aceito no Android, vínculo de funcionário confirmado no banco, recuperação
recebida, senha redefinida e novo login confirmados pela responsável. Evidência
manual distinta da CI. SMTP Brevo com remetente pessoal temporário autorizado e
templates em português; trocar pelo remetente oficial antes de operação do abrigo.
Nenhum email foi enviado ao professor. iOS não foi compilado nem validado neste
ambiente. Procedimento, histórico e cenários não repetidos nesta etapa em
[email hospedado](../development/cloud-auth-email.md).

O vínculo GitHub não substitui os gates. A integração foi discutida com a
responsável; a automação não habilitou deploy automático ou plano pago. Conferir
as opções do painel antes de ligar produção a uma branch.

CI final [#194](https://github.com/lari-sh/app-extensao-II/actions/runs/41697176200)
aprovada no commit `404a7bfeacba51ecb7dc0e7d3bc919321aab956a`: Flutter,
backend, Android e deliver concluídos com sucesso. Foram aprovados 599 testes
Flutter, 11 testes de empacotamento e dez jornadas Android; cobertura global de
99,06% (7034/7101 linhas).

Após essa confirmação, foi aberto o [PR #1](https://github.com/lari-sh/app-extensao-II/pull/1)
de `developer` para `main`, sem merge. O commit documental que registra este
fechamento dispara novas verificações; o resultado acima corresponde ao código
e à documentação do commit identificado, sem antecipar o resultado dessas novas
execuções. A validação manual de emails remotos foi concluída em T063 em
04/11/2026, conforme os limites descritos acima.

Referências: [ambientes e migrations](https://supabase.com/docs/guides/deployment/managing-environments),
[Functions](https://supabase.com/docs/guides/functions/deploy) e
[chaves públicas e de servidor](https://supabase.com/docs/guides/getting-started/api-keys).

## Manual atualizado após validar email

A revisão de 04/11/2026 está em
[guia_instalacao_android.docx](../user-guide/guia_instalacao_android.docx)
e na pasta local entrega-professor. Ela esclarece que a conta fictícia não recebe
emails e que convite/recuperação foram validados em conta real. Após a responsável
fechar o Word, as cópias originais foram atualizadas; não é necessário enviar uma
segunda versão do manual ao professor.

## Verificação após concluir os emails e revisar o manual

A CI do PR [#219](https://github.com/lari-sh/app-extensao-II/actions/runs/41923716563),
commit 82da7c8, aprovou Flutter, backend e as dez jornadas Android. A espera de um
membro da equipe fora da área inicial foi corrigida somente no teste, com
regressão Widget e 48 testes da equipe PASS via MCP oficial. T063 e T067 concluídas;
sem pendências Android na lista 006. O resultado completo da CI do último commit
documental é registrado no [PR #1](https://github.com/lari-sh/app-extensao-II/pull/1),
que permanece sem merge. Não confundir o artefato debug da CI com o APK release
conectado à nuvem na pasta entrega-professor.
