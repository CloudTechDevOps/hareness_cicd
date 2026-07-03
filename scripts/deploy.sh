#!/usr/bin/env bash
# Simple, safe deploy flow: backup current state, pull latest code,
# install deps, restart the app, then verify it's healthy. Rolls
# back automatically if the post-deploy health check fails.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "=== [deploy] $(date -u +%FT%TZ) starting deploy ==="

echo "[deploy] step 1/5 — backing up current state"
"$ROOT_DIR/scripts/backup.sh"

echo "[deploy] step 2/5 — pulling latest code"
if [ -d .git ]; then
  git fetch --quiet origin
  git reset --hard --quiet origin/"$(git rev-parse --abbrev-ref HEAD)"
else
  echo "[deploy] not a git checkout, skipping pull (assuming code was staged externally)"
fi

echo "[deploy] step 3/5 — installing dependencies"
"$ROOT_DIR/scripts/install.sh"

echo "[deploy] step 4/5 — restarting the app"
"$ROOT_DIR/scripts/stop.sh" || true
"$ROOT_DIR/scripts/start.sh" &
disown
sleep 3

echo "[deploy] step 5/5 — verifying health"
if "$ROOT_DIR/scripts/healthcheck.sh"; then
  echo "=== [deploy] succeeded ==="
  exit 0
else
  echo "=== [deploy] health check failed — rolling back ==="
  "$ROOT_DIR/scripts/rollback.sh"
  exit 1
fi
