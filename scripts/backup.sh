#!/usr/bin/env bash
# Create a timestamped tarball backup of the application (excluding
# virtualenv, caches, and version control) and prune old backups
# beyond a configurable retention count.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP_DIR="${BACKUP_DIR:-$ROOT_DIR/backups}"
RETENTION="${BACKUP_RETENTION:-7}"
TIMESTAMP="$(date -u +%Y%m%dT%H%M%SZ)"
ARCHIVE_NAME="pulse-backup-${TIMESTAMP}.tar.gz"

mkdir -p "$BACKUP_DIR"

echo "[backup] archiving $ROOT_DIR -> $BACKUP_DIR/$ARCHIVE_NAME"
tar \
  --exclude="venv" \
  --exclude="__pycache__" \
  --exclude=".git" \
  --exclude="backups" \
  --exclude="*.pyc" \
  -czf "$BACKUP_DIR/$ARCHIVE_NAME" \
  -C "$(dirname "$ROOT_DIR")" "$(basename "$ROOT_DIR")"

echo "[backup] wrote $(du -h "$BACKUP_DIR/$ARCHIVE_NAME" | cut -f1)"

echo "[backup] enforcing retention of ${RETENTION} most recent backups"
# shellcheck disable=SC2012
ls -1t "$BACKUP_DIR"/pulse-backup-*.tar.gz 2>/dev/null | tail -n +$((RETENTION + 1)) | while read -r old; do
  echo "[backup] removing old backup: $old"
  rm -f "$old"
done

echo "[backup] complete"
