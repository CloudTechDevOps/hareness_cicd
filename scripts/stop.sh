#!/usr/bin/env bash
# Gracefully stop the Gunicorn master process using its pidfile.
set -euo pipefail

PIDFILE="${GUNICORN_PIDFILE:-/tmp/pulse.pid}"

if [ ! -f "$PIDFILE" ]; then
  echo "[stop] no pidfile at $PIDFILE — is the app running?"
  exit 0
fi

PID="$(cat "$PIDFILE")"

if ! kill -0 "$PID" 2>/dev/null; then
  echo "[stop] process $PID not running, cleaning up stale pidfile"
  rm -f "$PIDFILE"
  exit 0
fi

echo "[stop] sending SIGTERM to gunicorn master (pid $PID) for a graceful shutdown"
kill -TERM "$PID"

for _ in $(seq 1 15); do
  if ! kill -0 "$PID" 2>/dev/null; then
    echo "[stop] stopped cleanly"
    rm -f "$PIDFILE"
    exit 0
  fi
  sleep 1
done

echo "[stop] process did not exit in time, sending SIGKILL"
kill -KILL "$PID" || true
rm -f "$PIDFILE"
