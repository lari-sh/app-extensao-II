# Evidências

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
