#!/usr/bin/env bash
set -euo pipefail

: "${SUPABASE_ANON_KEY:?Missing local public test key}"
device=emulator-5554
package=br.org.abrigodosanjos.abrigo_dos_anjos
journeys=(
  public_catalog_flow_test
  visitor_detail_flow_test
  authentication_flow_test
  management_dashboard_flow_test
  animal_editor_flow_test
  medication_calendar_flow_test
  adoption_contact_flow_test
  team_access_flow_test
  password_recovery_flow_test
  management_search_flow_test
)

for journey in "${journeys[@]}"; do
  if [[ "$(adb -s "$device" get-state)" != device ]]; then
    echo "::error::Android transport unavailable before $journey" >&2
    exit 1
  fi
  adb -s "$device" shell am force-stop "$package"
  echo "::group::Android journey: $journey"
  # A fresh Flutter process and direct VM connection avoid retaining a stale
  # DDS instance between APKs. Assertions still fail the gate; no test retries.
  status=0
  timeout --signal=TERM --kill-after=30s 8m flutter test \
    "integration_test/$journey.dart" --no-pub --no-dds -d "$device" \
    --dart-define=SUPABASE_URL=http://10.0.2.2:54321 \
    --dart-define="SUPABASE_PUBLISHABLE_KEY=$SUPABASE_ANON_KEY" \
    --dart-define=ALLOW_LOCAL_HTTP=true || status=$?
  echo '::endgroup::'
  if [[ "$status" -ne 0 ]]; then
    echo "::error::Android journey $journey failed (exit $status)" >&2
    timeout 15s adb -s "$device" get-state || true
    timeout 15s adb -s "$device" logcat -d -t 150 \
      'AndroidRuntime:E' 'flutter:E' '*:S' || true
    exit "$status"
  fi
done
