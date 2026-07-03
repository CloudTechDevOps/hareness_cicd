#!/usr/bin/env bash
# Probe the app's liveness and readiness endpoints. Exits non-zero
# if either check fails, suitable for cron, CI smoke tests, or a
# container orchestrator's health probe.
set -euo pipefail

HOST="${HEALTHCHECK_HOST:-localhost}"
PORT="${PORT:-5000}"
BASE_URL="http://${HOST}:${PORT}"
TIMEOUT="${HEALTHCHECK_TIMEOUT:-5}"

check() {
  local path="$1"
  local url="${BASE_URL}${path}"
  if curl -fsS --max-time "$TIMEOUT" "$url" > /dev/null; then
    echo "[healthcheck] OK   ${path}"
    return 0
  else
    echo "[healthcheck] FAIL ${path}"
    return 1
  fi
}

status=0
check "/healthz" || status=1
check "/readyz"  || status=1

if [ "$status" -eq 0 ]; then
  echo "[healthcheck] app is healthy"
else
  echo "[healthcheck] app is UNHEALTHY"
fi

exit "$status"
