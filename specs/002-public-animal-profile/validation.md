# Validação dos dados públicos do animal

Ambiente: Supabase local descartável, Flutter 3.41.1, Android AVD
Abrigo_Anjos_Test_API37. Nenhuma migração aplicada em produção.

- Banco: 127 testes pgTAP aprovados em sete arquivos; 28 casos no contrato público.
- Flutter: 181 testes aprovados, incluindo regras de data civil, peso, textos,
  DTOs, Repository, ViewModels e widgets do editor/ficha.
- Análise estática sem problemas.
- Android: animal_editor_flow_test aprovado em 36 segundos. Cadastro e edição
  pela interface, confirmação dos campos em uma segunda sessão, publicação, leitura
  anônima, ficha com peso/cor/vacina, limpeza de data/peso e reabertura do editor.
  Notas internas preservadas e ausentes da ficha. O teste usa credencial descartável
  obtida em runtime pelo controlador local, sem gravá-la no APK.
- Regressão visitante aprovada em 10 segundos: ficha, foto, favoritos, cópia e fechamento. APK normal compilado, instalado com sucesso e aberto no emulador. Dados descartáveis do editor removidos.
- Geração Freezed determinística e formato de 176 arquivos sem alterações.

Os registros públicos de vacina contêm apenas data e tipo. Notas e cuidados
internos permanecem em seu contrato privado. Não há migração automática do
prontuário nem geração de aplicações com base no booleano legado de vacinação.
A ausência aparece como Não informado. Peso é em kg; datas são civis.

O cliente usa a referência civil UTC-3 atual do abrigo para validação prévia;
o servidor aplica America/Sao_Paulo e decide a validade final. Não há nova
dependência. Um eventual ajuste futuro do fuso do abrigo requer rever a
validação prévia do cliente.

A esteira Android inclui a jornada de cadastro/edição além do painel. O resultado
do GitHub Actions precisa ser acompanhado separadamente; aprovação local não
significa publicação de artifact nem aprovação de execução remota.

Foi corrigida uma regressão revelada pela jornada: os campos do editor retido
precisam ser atualizados quando a verificação de acesso termina. A composição
registra/remove o listener de acesso; o ViewModel notifica a View. Widget Test
confirma desabilitação e reativação sem descartar o rascunho.


## Resultado remoto confirmado

[CI 41259640949](https://github.com/lari-sh/app-extensao-II/actions/runs/41259640949) concluída com sucesso para
2a036c85126a3a5213195cb34135c00e89fefbe6. Flutter, backend, Android e deliver
aprovados; artifact abrigo-dos-anjos-android-debug id 13065725073 disponível na
execução (76.483.274 bytes, retenção sete dias). Todos os itens P001–P012 concluídos.
O APK entregue usa configuração pública de desenvolvimento; se as variáveis do
repositório estiverem ausentes, apresenta serviço não configurado. A evidência
não significa implantação Supabase em produção nem validação iOS.
