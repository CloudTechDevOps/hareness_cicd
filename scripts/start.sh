#!/bin/bash
set -e

APP_DIR=/home/ec2-user/python-app

cd "$APP_DIR"
source venv/bin/activate

echo "Starting application..."
nohup gunicorn -w 4 -b 0.0.0.0:8000 app:app > app.log 2>&1 &
disown

sleep 2

PID=$(pgrep -f gunicorn || true)
if [ -z "$PID" ]; then
    echo "ERROR: gunicorn failed to start. Check app.log:"
    cat app.log
    exit 1
fi

echo "Application started with PID $PID"
