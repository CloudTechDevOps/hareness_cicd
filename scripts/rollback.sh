#!/bin/bash

echo "Rolling back..."

PID=$(pgrep -f gunicorn || true)

if [ ! -z "$PID" ]
then
kill -15 $PID
fi

rm -rf /home/ec2-user/python-app

LATEST=$(ls -dt /home/ec2-user/backups/* | head -1)

cp -r "$LATEST" /home/ec2-user/python-app

cd /home/ec2-user/python-app

source venv/bin/activate

nohup gunicorn \
-w 4 \
-b 0.0.0.0:8000 \
app:app > app.log 2>&1 &
