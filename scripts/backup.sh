#!/bin/bash
set -e

APP_DIR=/home/ec2-user/python-app
BACKUP_DIR=/home/ec2-user/backups

echo "Taking Backup..."
mkdir -p "$BACKUP_DIR"

if [ -d "$APP_DIR" ]; then
    TIMESTAMP=$(date +%Y%m%d%H%M%S)
    cp -r "$APP_DIR" "$BACKUP_DIR/python-app-$TIMESTAMP"
    echo "Backup created at $BACKUP_DIR/python-app-$TIMESTAMP"
else
    echo "No existing app directory found at $APP_DIR — skipping backup."
fi
