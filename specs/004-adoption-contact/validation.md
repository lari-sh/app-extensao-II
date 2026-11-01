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
