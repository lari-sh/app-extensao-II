#!/usr/bin/env bash
set -euo pipefail
mkdir -p .tools
supabase functions serve --env-file supabase/.env.local > .tools/functions.log 2>&1 &
for attempt in $(seq 1 60); do
  code=$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:54321/functions/v1/animal-photo-read || true)
  if [ "$code" = 400 ] || [ "$code" = 404 ]; then
    exit 0
  fi
  sleep 2
done
echo 'Local function health check failed.' >&2
exit 1
