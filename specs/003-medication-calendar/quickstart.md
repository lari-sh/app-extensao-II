# Roteiro de validação — calendário de medicamentos

Este roteiro é planejado: os novos testes/RPCs/telas ainda não existem. Não é
uma evidência de aprovação e não deve ser executado como implantação em produção.

## Preparação

Branch developer; Flutter/Android SDK e Docker/Supabase locais já provisionados.
Reutilizar supabase/.env.local ignorado e controlador loopback para credenciais
descartáveis em runtime. Nunca compilar senha nem service_role. Preservar o AVD e
o app usados nos testes manuais. Aprovar a proposta visual antes das novas Views.

## Gates após implementar

```powershell
flutter pub run build_runner build --delete-conflicting-outputs
dart format --output=none --set-exit-if-changed lib test integration_test
flutter analyze
flutter test
npx --yes supabase@2.122.0 test db
python supabase/tests/fixtures/medication_flow.py
```

Os scripts locais devem rejeitar URL remota e limpar apenas suas próprias fixtures.
A integração Android usa integration_test/medication_calendar_flow_test.dart e
configuração pública local no emulador 10.0.2.2. Seguir o mesmo procedimento de
controlador e dart-defines do quickstart da feature 001; sem inserir credencial no APK.

## Cenários independentes

- US1: animal existente → tratamento com horários fixos 08h/20h → quatro aplicações
  no exemplo da spec; depois intervalo 8h atravessando meia-noite. Repetir chave
  não duplica. Datas/limites inválidos não gravam nada.
- US2: mês com 28/29/30/31 dias, selecionar dia, duas aplicações simultâneas de animais
  diferentes, mais de 100 itens e agenda vazia. Alterar fuso do aparelho preserva
  horários do abrigo; concorrência entre páginas pede recarregar snapshot.
- US3: concluir aplicação devida, conferir autor/hora reais na segunda sessão.
  Corrida entre dois funcionários, conclusão futura negada, timeout depois do
  commit reconciliado pela chave. Revogação invalida leitura/escrita e recibo.
- US4: editar/interromper série preservando atrasadas/realizadas; corrigir com motivo
  mantendo evento original. Salvar ficha geral não recria/apaga medicações. Adoção
  não interrompe automaticamente nem torna agenda pública.

## Interfaces e segurança

Widget Tests felizes separados: medication_editor_panel_test.dart,
medication_calendar_panel_test.dart e medication_application_details_sheet_test.dart.
Regressões dashboard/editor/catálogo, 320 px e texto ampliado. Conferir visualmente
contra a composição aprovada e o protótipo. Anon e usuário sem equipe não podem
ler tratamentos, eventos ou operações nem quando o animal está publicado.

## Entrega

Incluir jornada na .github/scripts/android_management.sh; confirmar os jobs Flutter,
backend, Android e deliver e artifact da execução. Registrar links e limitações em
validation.md, a ser criado na implementação. Reinstalar o APK normal após testes
integration_test (eles removem o app de teste) e abrir para validação manual.
Sem alterar main, sem produção/lojas; iOS permanece dependente de Mac/Xcode.

## Estado executável de US1/US2

Com migrations até 013 e fixtures locais preparadas, executar:

```text
python supabase/tests/fixtures/medication_flow.py
flutter test integration_test/medication_calendar_flow_test.dart -d emulator-5554 [defines locais do Supabase]
python supabase/tests/fixtures/medication_flow.py --cleanup
```

O teste Android recebe a senha descartável em runtime pelo controlador local
android_auth_control.py (porta 58763); não inserir senha em código/defines. Usar
SUPABASE_URL=http://10.0.2.2:54321 e ALLOW_LOCAL_HTTP=true somente no emulador local.
Após reinstalar o APK normal: Acesso Voluntário / Funcionário → login de equipe →
Animais do abrigo → Calendário. Setas navegam o mês; tocar no dia abre sua agenda.
Hoje usa a data do abrigo; Carregar mais aplicações percorre páginas de 100.
Conclusão/detalhes auditados são a próxima etapa; o calendário atual é de consulta.
