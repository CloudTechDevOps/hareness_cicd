#!/bin/bash
set -e

APP_DIR=/home/ec2-user/python-app
BACKUP_DIR=/home/ec2-user/backups

echo "Rolling back..."

# Stop the running app, if any
PID=$(pgrep -f gunicorn || true)
if [ -n "$PID" ]; then
    echo "Stopping gunicorn (PID $PID)..."
    kill -15 $PID
    sleep 2
fi

# Find the most recent backup
LATEST=$(ls -dt "$BACKUP_DIR"/*/ 2>/dev/null | head -1)
if [ -z "$LATEST" ]; then
    echo "No backup found in $BACKUP_DIR — cannot roll back."
    exit 1
fi
echo "Restoring from $LATEST"

# Restore
rm -rf "$APP_DIR"
cp -r "$LATEST" "$APP_DIR"

# Restart the app
cd "$APP_DIR"
source venv/bin/activate
nohup gunicorn -w 4 -b 0.0.0.0:8000 app:app > app.log 2>&1 &
disown

echo "Rollback complete."
