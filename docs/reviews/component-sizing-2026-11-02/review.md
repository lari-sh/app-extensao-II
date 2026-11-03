# Revisão de tamanhos e acessibilidade — 2026-11-02

Status: diagnóstico e recomendações; layout do aplicativo preservado. Nenhuma
revisão visual nova foi aprovada ou implementada por este relatório.

## Método e alcance

Inventário de todas as 32 fontes de views/widgets/tema em lib/ui: 509 declarações
de fonte, largura, altura, padding, limites de linhas ou área de toque em
source-dimensions.csv; lista completa em source-files.txt. Valores declarados
não equivalem necessariamente à área final de toque: Material pode acrescentar
padding, enquanto SizedBox pode restringi-la. Dimensões de imagens decorativas
não devem ser tratadas como falhas de alvo interativo.

Medição renderizada dos três modos do painel com tema de produção, busca fixa,
um animal em tratamento e agenda fictícia: larguras 320/390/600/1440 dp, fontes
1x e 2x, altura 1000 dp (24 cenários). Evidência em dashboard-runtime.json.
AndroidTapTargetGuideline, textContrastGuideline e cortes de RenderParagraph
foram coletados como achados, não como gates aprovados. O coletor diagnóstico
completou oito execuções; isso NÃO significa oito aprovações de acessibilidade.

Somente elementos montados/visíveis entram na avaliação semântica; com texto
ampliado, itens podem sair da área visível e deixar de ser avaliados. Ausência
de achado nessas condições não demonstra conformidade. Teclado, rolagem completa,
TalkBack e demais telas ainda exigem avaliação renderizada específica; o restante
do aplicativo recebeu inventário/revisão estática, não certificação automática.

## Evidências prioritárias

| Componente | Medida atual | Avaliação | Proposta para revisão visual |
|---|---|---|---|
| Cartão Kanban, tela 320 dp | 79,3 dp de largura | Três colunas comprimem texto e ações | Colunas com largura mínima proposta de 272–304 dp e rolagem horizontal no celular |
| Cartão Kanban, tela 390 dp | 102,7 dp de largura | Nome, menu e observação disputam espaço | Preservar três situações; mostrar uma coluna legível e parte da próxima |
| Menu do cartão Kanban | 24 × 48 dp renderizados | Falha confirmada no guideline Android | Área de toque mínima 48 × 48 dp; ícone visual pode continuar menor |
| Menu na Lista | Restrição de largura 40 dp | Mesmo risco confirmado pelo guideline | 48 × 48 dp |
| Fontes do Kanban | Nome 12; apoio/resumo/publicação 10; cabeçalho 10 | Hierarquia pequena para leitura frequente | Nome 16, conteúdo 14, apoio 12 como ponto inicial de projeto |
| Resumo clínico | Até três linhas, com reticências | Texto real foi cortado a 320/390 dp | Maior largura, texto legível e acesso ao conteúdo completo pela ficha |
| Setas do mês | 32 × 32 dp | Falha confirmada | 48 × 48 dp |
| Hoje | Altura 30 dp, shrinkWrap | Falha confirmada | Área mínima de toque 48 dp |
| Dias do calendário | Em 390 dp: cerca de 43,3 × 32 dp | Falha confirmada | Rever grade e padding; manter agenda e navegação legíveis em largura compacta |
| Abrir aplicação | 30 × 30 dp | Falha confirmada, embora cartão também abra | 48 × 48 dp, evitando ações concorrentes sobrepostas |
| Cabeçalhos/totais/busca | Região superior fixa | Consome espaço útil com fonte ampliada | Revisar altura e rolagem responsiva mantendo a busca no contexto aprovado |

A 320 dp e texto 2x houve três overflows de coluna no Kanban, e cartões deixaram
de ser montados. A 390 dp/2x o cartão ficou com 398 dp de altura para apenas
102,7 dp de largura. Isso mostra que simplesmente aumentar a altura não resolve.
Não existe uma largura oficial universal de cartão Kanban: 272–304 dp é proposta
específica de design, sujeita à aprovação e validação no celular.

## Revisão das demais famílias de componentes

| Família | Situação no código | Encaminhamento |
|---|---|---|
| Botões principais e secundários globais | Tema define altura mínima 52 dp | Boa base; confirmar retângulo semântico e texto longo por tela |
| Abas Kanban/Lista/Calendário | Visual mínimo 38 dp; padding Material pode aumentar alvo | Medir área real; não confundir fundo de botão com alvo |
| Catálogo/favoritos | Nome 17, apoio 11, selo 9 no componente compartilhado | Priorizar apoio e selos, coração/filtros e teste 2x |
| Ficha pública/contato | Textos/ações com estilos próprios | Revisar grid de dados e retorno com fonte 2x; preservar composição aprovada |
| Login | Nome do campo e controles auxiliares 12/13; logo 140 | Revisar fonte/teclado/checkbox/recuperação; logo decorativo não precisa ter 48 dp |
| Recuperação/nova senha | Campo 13, rótulo/helper 10, corpo 12 | Padronizar hierarquia tipográfica após revisão visual |
| Equipe/convites | Botões compartilhados mínimos 49; cabeçalho auxiliar 9, corpo 12/13 | Manter botões e revisar textos pequenos/ações por perfil |
| Editor de animal | Controles de formulário Material e seções variáveis | Medir dropdowns, vacinas/cuidados, salvar/voltar e mensagens com teclado |
| Fotos | Seleção, envio, progresso e recuperação | Avaliar foco/área de toque e rótulos nos estados de erro e envio |
| Programação/detalhes de medicação | Campos, datas, confirmação e histórico | Medir ações críticas, calendário de datas e conteúdo expandido |
| Início/sobre/acesso | Botões do tema; corpo 13 em trechos da entrada | Validar rolagem e leitura; imagens de marca são decorativas |

## Referências e critérios

- Flutter: https://docs.flutter.dev/ui/accessibility/ui-design-and-styling
- Flutter testes: https://docs.flutter.dev/ui/accessibility/accessibility-testing
- Android: https://developer.android.com/guide/topics/ui/accessibility/apps
- Android alvos: https://support.google.com/accessibility/android/answer/7101858

Android recomenda alvos de pelo menos 48 × 48 dp. O desenho do ícone pode ser
menor dentro dessa região. Texto normal precisa de contraste 4,5:1; texto grande,
3:1 nos critérios documentados. O guideline de contraste não encontrou violações
nos elementos visíveis do cenário sintético do painel; outras combinações de
status/estados e telas não estão certificadas. Fontes 14/16 sugeridas acima são
uma hierarquia de projeto, não uma regra universal imposta por Flutter/Android.

Manter escala do sistema, evitar alturas fixas que cortem conteúdo, testar nomes
longos e notas clínicas reais. Em 320 dp, sete alvos de 48 dp já exigem 336 dp
sem qualquer espaçamento; por isso a grade do calendário requer solução adaptativa,
não apenas aumento da altura. Tokens de espaçamento e tipografia compartilhados
reduzem divergência entre telas, preservando a identidade visual do abrigo.

## Próximas etapas

1. Preparar revisão do protótipo com colunas de Kanban legíveis e controles de
   calendário acessíveis, explicando a mudança de composição no celular.
2. Obter aprovação antes da implementação visual, conforme a constituição.
3. Implementar tokens e componentes por contexto, com testes de tamanho semântico,
   texto 1x/1,4x/2x, 320/390 dp, rolagem e orientação.
4. Validar manualmente no celular e rodar CI/cobertura, sem misturar o coletor
   diagnóstico com uma suíte que exige conformidade.
