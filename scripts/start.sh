#!/usr/bin/env bash
# Start the application with Gunicorn in the foreground (or as a
# daemon with --daemon). Intended for use inside a container or by
# a process supervisor (systemd, supervisord, etc).
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

export APP_ENV="${APP_ENV:-production}"
export PORT="${PORT:-5000}"

VENV_DIR="${VENV_DIR:-$ROOT_DIR/venv}"
if [ -d "$VENV_DIR" ]; then
  # shellcheck disable=SC1091
  source "$VENV_DIR/bin/activate"
fi

echo "[start] launching gunicorn on :${PORT} (env=${APP_ENV})"
exec gunicorn --config scripts/gunicorn.conf.py app:app
