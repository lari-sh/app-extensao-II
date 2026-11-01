#!/usr/bin/env bash
set -euo pipefail
python3 supabase/tests/fixtures/android_auth_control.py > .tools/controller.log 2>&1 &
controller_pid=$!
cleanup() {
  local status=$?
  trap - EXIT
  python3 supabase/tests/fixtures/medication_flow.py --cleanup || status=$?
  python3 supabase/tests/fixtures/android_auth_control.py --cleanup-editor || status=$?
  kill "$controller_pid" 2>/dev/null || true
  exit "$status"
}
trap cleanup EXIT
ready=0
for attempt in $(seq 1 30); do
  if curl -s -o /dev/null --fail http://127.0.0.1:58763/fixture-password; then ready=1; break; fi
  sleep 1
done
if [ "$ready" -ne 1 ]; then
  echo "Local Android fixture controller did not start." >&2
  exit 1
fi
flutter test integration_test/public_catalog_flow_test.dart integration_test/visitor_detail_flow_test.dart integration_test/authentication_flow_test.dart integration_test/management_dashboard_flow_test.dart integration_test/animal_editor_flow_test.dart integration_test/medication_calendar_flow_test.dart integration_test/adoption_contact_flow_test.dart --no-pub -d emulator-5554 \
  --dart-define=SUPABASE_URL=http://10.0.2.2:54321 \
  --dart-define="SUPABASE_PUBLISHABLE_KEY=$SUPABASE_ANON_KEY" \
  --dart-define=ALLOW_LOCAL_HTTP=true
