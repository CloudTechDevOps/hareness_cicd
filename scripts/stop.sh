#!/bin/bash
set -e

echo "Stopping existing application..."

PID=$(pgrep -f gunicorn || true)
if [ -n "$PID" ]; then
    echo "Found gunicorn process(es): $PID"
    kill -15 $PID
    sleep 10

    # Verify it actually stopped
    STILL_RUNNING=$(pgrep -f gunicorn || true)
    if [ -n "$STILL_RUNNING" ]; then
        echo "gunicorn did not stop gracefully, forcing kill..."
        kill -9 $STILL_RUNNING
        sleep 2
    fi

    echo "Application stopped."
else
    echo "No running gunicorn process found."
fi
