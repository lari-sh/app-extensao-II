# Evidências

Estado atual: entrega de contatos concluída, 7/7 tarefas vigentes. CI e APK
confirmados para 432ef2d; hospedagem/compartilhamento cancelados. As seções
intermediárias abaixo preservam o histórico; o fechamento ao final é o vigente.

2026-11-01: aprovação explícita do usuário para DESIGN-CONTACT-003; preferência por
subdomínio gratuito registrada. Protótipo aprovado 73d1e55, tela 10 sem prévia.
Plano revisto contra constituição 2.0.0 e skill oficial Flutter, sem conflito.
Pesquisa delegada conforme speckit-plan; documentação oficial em research.md.
Sem hooks: .specify/extensions.yml ausente. Nenhum pacote/código Flutter alterado
nesta etapa documental. Implementação e testes de US1 ainda pendentes; US2 depende
do endereço/hospedagem e autorização final de publicação, não está concluída.


## Fundação de abertura externa — T002/T003

Testes escritos antes da implementação: vermelho por contratos ausentes. Após
implementar, 3 testes novos Service/Repository e 2 de arquitetura PASS; análise
Flutter sem problemas, formato aplicado. URLs HTTPS oficiais, encoding de nome
com acentos/caracteres reservados, dados públicos, falhas false/exceção e animal
indisponível cobertos. Nenhum envio automático nem chamada Supabase adicionada.
url_launcher 6.3.3 já existia transitivamente no lock; promovido a dependência direta
com justificativa escrita no plano. Não atualizados outros pacotes.
A tela, VM, Android e link público ainda não estão implementados/validados.


## Estado e ViewModel — T004

Estado Freezed gerado. Três testes unitários PASS: nome público, revalidação antes
de abertura, indisponibilidade, duplicate command, dispose, resposta antiga,
exceção sem detalhes crus e retry. Teste inicialmente vermelho por VM inexistente.
Não há prévia de mensagem no estado; aviso explicita URL pública ainda ausente.
VM não importa plugin ou Service. Integração visual e Android continuam pendentes.


## Tela e navegação — T005

Tela Flutter integrada à rota /adoption-contact, com ID público, composição inicial
injetando Repository/Service e disposição via Provider. CTA da ficha abre a nova
tela e preserva ficha no retorno. Sem prévia de mensagem/cartão de link. Logo,
contexto, contatos e retornos seguem tela 10 aprovada; aviso curto do rodapé relata
URL pública ainda indisponível. Não há envio ou acesso direto a plugin pela View.
Widget Tests novos passaram em 320/390 px e texto 1,4×; regressão navega da ficha
para contato e volta à mesma ficha, sem copiar mensagem. Análise sem problemas,
270 testes Flutter PASS. T006 Android/CI e US2 permanecem pendentes.


## Android local — progresso de T006

adoption_contact_flow_test.dart PASS em 14 s no emulator-5554: catálogo/ficha com
animal público real, entrada na tela sem prévia, nome correto, Voltar do topo e
rodapé para a mesma ficha e abertura externa aceita pelo SO para Instagram oficial
via plugin real. Nenhuma mensagem enviada. AVD sem janela; não representa teste
manual do usuário nem comprova comportamento de todos os aplicativos sociais.
Teste legado visitor_detail_flow_test.dart atualizado para a nova navegação.
Jornada de contato adicionada ao script Android da CI; bash -n PASS. A execução
remota e artifact dessa revisão ainda precisam de confirmação; T006 continua
aberta por esse gate. Não há alteração SQL, portanto pgTAP não foi repetido.
README atualizado; link público, fallback web e App Links continuam pendentes.


## CI de US1 confirmada — T006

Em 2026-11-01, execução [41284530212](https://github.com/lari-sh/app-extensao-II/actions/runs/41284530212),
SHA f3facb8bf364854c845f6d47b91a4a540e2b932a, developer: Flutter, backend,
Android e deliver concluídos com success. Confirmado artifact
[abrigo-dos-anjos-android-debug](https://github.com/lari-sh/app-extensao-II/actions/runs/41284530212/artifacts/13075460909),
ID 13075460909, 76.793.343 bytes, não expirado na conferência, expira em
2026-11-08 07:45:00 UTC. Digest sha256:
`a8ee26a180e5ee0b84720b0780e3a52dbc99493913b07a6ed8f9b787765b8890`.
T006 concluída com gates e artifact remotos, além de 270 testes Flutter e Android
local já registrados. APK normal local reinstalado e iniciado após integração.
Não equivale a publicação em lojas nem à entrega de link público da ficha.


## Decisão vigente — cancelamento do compartilhamento

Em 2026-11-01, usuário cancelou hospedagem gratuita e determinou remover da lista
as tarefas de envio da ficha. Referências anteriores ao link/hospedagem são
históricas e estão revogadas. T007–T011 removidas, não concluídas por implementação.
Nenhum host foi preparado/publicado. WhatsApp mantém apenas rascunho textual com
dados públicos, sem ficha/link anexado; rodapé do app/protótipo atualizado sem mudar
composição aprovada. Não há trabalho pendente de hospedagem nesta feature.


Verificação do ajuste: geração Freezed concluída, 7 testes de contato/Repository
PASS, análise sem problemas, protótipo em 320/390 px sem erros JS/overflow.
Teste confirma que o texto WhatsApp não inclui URL. Layout mantido. Janela do AVD
recuperada com renderização swiftshader, reposicionada na tela e aviso de
compatibilidade dispensado; tela inicial do app observada na janela Windows.
Nenhuma publicação de hospedagem realizada. CI da alteração será nova execução;
a aprovação remota anterior continua identificada pelo SHA acima.


## Fechamento da entrega — T012

Conferência em 2026-11-01: [execução 41286832749](https://github.com/lari-sh/app-extensao-II/actions/runs/41286832749)
concluída com success nos jobs Flutter, backend, Android e deliver, para o código
`432ef2d8f51d972e6746a66af7d6b828cdeb5dec`, na developer. O log Android confirma
quatro jornadas PASS, incluindo contato público, retorno à ficha e abertura do
Instagram oficial. Os gates incluem geração determinística, formato, análise,
testes Flutter, backend e Android antes da entrega.

Artifact confirmado:
[abrigo-dos-anjos-android-debug](https://github.com/lari-sh/app-extensao-II/actions/runs/41286832749/artifacts/13075583798),
ID 13075583798, 76.792.808 bytes, não expirado na conferência, expiração informada
pela API: 2026-11-08 08:18:34 UTC. Digest:
`sha256:63310a8990c8514ecd313b9ea2870939838d32ea5da20f958a37f47f152dd21e`.
APK debug; configuração de backend depende das variáveis públicas DEV do
repositório. Não representa versão de loja nem implantação em produção.

Revisados README, contrato, modelo, plano e tarefas: corrigidas referências antigas
a contato somente no protótipo e compartilhamento futuro; modelo documental agora
reflete ID interno do VM. Confirmados rascunho textual sem ficha/link, layout
aprovado e remoção de T007–T011 por cancelamento, sem marcá-las implementadas.
T012 concluída: 7/7 tarefas vigentes. Git revisto na developer com commits por
contexto; main preservada. Este fechamento altera somente documentação e conserva
o código aprovado pela execução acima; não é necessário repetir testes de código
por essa alteração documental. Hooks ausentes (.specify/extensions.yml).

iOS continua pendente na tarefa independente T106 de specs/001-align-app-constitution:
exige Mac/Xcode/dispositivo; Windows e CI Android não comprovam iOS. Emulador local
com janela recuperada, autenticado na conta de teste e deixado no painel de manejo
para uso do usuário. Nenhum cadastro foi alterado durante a abertura do painel.
