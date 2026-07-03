#!/usr/bin/env bash
# Restore the most recent backup produced by backup.sh and restart
# the app. Used automatically by deploy.sh on a failed health check,
# or manually: ./scripts/rollback.sh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP_DIR="${BACKUP_DIR:-$ROOT_DIR/backups}"

LATEST_BACKUP="$(ls -1t "$BACKUP_DIR"/pulse-backup-*.tar.gz 2>/dev/null | head -n 1 || true)"

if [ -z "$LATEST_BACKUP" ]; then
  echo "[rollback] no backups found in $BACKUP_DIR — cannot roll back"
  exit 1
fi

echo "[rollback] stopping the app"
"$ROOT_DIR/scripts/stop.sh" || true

echo "[rollback] restoring $LATEST_BACKUP"
TMP_RESTORE_DIR="$(mktemp -d)"
tar -xzf "$LATEST_BACKUP" -C "$TMP_RESTORE_DIR"

RESTORED_DIR="$TMP_RESTORE_DIR/$(basename "$ROOT_DIR")"
if [ ! -d "$RESTORED_DIR" ]; then
  echo "[rollback] unexpected archive layout, aborting"
  rm -rf "$TMP_RESTORE_DIR"
  exit 1
fi

rsync -a --delete \
  --exclude venv \
  --exclude backups \
  --exclude .git \
  "$RESTORED_DIR/" "$ROOT_DIR/"

rm -rf "$TMP_RESTORE_DIR"

echo "[rollback] restarting the app"
"$ROOT_DIR/scripts/start.sh" &
disown
sleep 3

"$ROOT_DIR/scripts/healthcheck.sh" && echo "[rollback] app restored and healthy"
