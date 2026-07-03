#!/bin/bash

echo "Stopping existing application..."

PID=$(pgrep -f gunicorn || true)

if [ ! -z "$PID" ]
then
    kill -15 $PID
    sleep 10
fi
