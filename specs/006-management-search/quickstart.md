# Roteiro de validação — busca global

## Revisão visual v2

Abrir design/management-search-proposal.html. URL local da sessão:
http://127.0.0.1:58800/management-search-proposal.html?revision=search-global-v2
Use ?preview=search para ver só o celular; mode=calendar&q=Luna demonstra busca
ativa sem sair do Calendário. Prévia local temporária, HTML versionado no repo.

1. Confirmar campo abaixo dos totais e somente três abas, sem precisar entrar em busca.
2. Em cada modo, digitar Luna: duas fichas/códigos. Digitar #a0024: uma ficha.
3. No Calendário, selecionar dia 3 e procurar Amora (sem evento nesse dia): ficha
   aparece; limpar devolve agenda do dia 3. Conferir a posição fixa ao rolar.
4. Abrir filtros e combinar Cachorro/Fêmea/Pequeno/Quarentena/preto com Luna;
   aplicar retorna Luna #A0107. Cancelar alterações no painel mantém a busca.
5. Limpar só texto mantém filtros; limpar busca remove tudo e restaura o modo.
6. Conferir vazio/loading/erro-retry na lateral e imagens a 320/390 px.
7. Registrar aprovação expressa desta revisão em design-approval.md antes de Flutter/SQL.

## Validação da implementação

- Ambiente separado ou fixtures exclusivas; nunca resetar cadastros manuais.
- Validar backfill/imutabilidade/concorrência de código e crescimento >9999, sem
  alterar UUID, fotos, medicações ou auditoria. Atualizar factories de testes/DTOs.
- Unitários de VM/Repository/Service: critérios, cinco filtros, Timer, paginação,
  rascunho/cancelamento, respostas antigas/fotos, erros, logout/revogação e dispose.
- Widgets nos três modos: campo fixo, resultados globais, retorno à ficha/data/rolagem,
  homônimos com códigos, vazio/retry e 320/390 px/texto ampliado. Cobertura >=95%.
- pgTAP/HTTP: filtros/total/cursor/literais, visitante, sem vínculo, funcionário,
  administrador e sessão revogada. Animal além da primeira página e sem evento no dia.
- Jornada Android: Kanban→nome/código→Lista→filtros→Calendário→Amora sem evento→limpar
  restaura dia→ficha/retorno→logout. Não remover as nove jornadas existentes da CI.
- Geração/formato/analyze/test/SQL/HTTP/Android/CI; registrar SHA/run/artifact reais.

iOS requer Mac/Xcode. Nenhuma dependência nova. Ver plano, contrato e tasks para detalhes.


## Testar no app Android

1. Entrar com uma conta de equipe ativa e abrir **Animais do abrigo**.
2. Usar o campo fixo por nome (ex.: Luna) ou código mostrado no resultado.
3. Abrir **Filtros**, selecionar critérios e aplicar; cancelar preserva a consulta.
4. Trocar entre Kanban, Lista e Calendário durante a busca. Limpar busca restaura
   o conteúdo anterior; limpar somente texto mantém filtros ativos.
5. Abrir ficha, voltar e conferir que critérios e dados atualizados permanecem.

Gates: `flutter analyze --no-pub`, `flutter test --no-pub --coverage` e
`python .github/scripts/check_coverage.py`. Backend local:
`supabase test db` e `python supabase/tests/fixtures/management_search_flow.py`.
A CI prepara fixtures isoladas para as dez jornadas; nunca execute reset/setup
sobre o ambiente manual para reproduzi-las. Evidências e limites em validation.md.
