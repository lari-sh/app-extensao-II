#!/usr/bin/env bash
set -euo pipefail
python3 supabase/tests/fixtures/android_auth_control.py > .tools/controller.log 2>&1 &
controller_pid=$!
cleanup() {
  python3 supabase/tests/fixtures/android_auth_control.py --cleanup-editor
  kill "$controller_pid" 2>/dev/null || true
}
trap cleanup EXIT
for attempt in $(seq 1 30); do
  if curl -s -o /dev/null --fail http://127.0.0.1:58763/fixture-password; then break; fi
  sleep 1
done
flutter test integration_test/management_dashboard_flow_test.dart --no-pub -d emulator-5554 \
  --dart-define=SUPABASE_URL=http://10.0.2.2:54321 \
  --dart-define="SUPABASE_PUBLISHABLE_KEY=$SUPABASE_ANON_KEY" \
  --dart-define=ALLOW_LOCAL_HTTP=true
