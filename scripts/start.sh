#!/bin/bash

cd /home/ec2-user/python-app

source venv/bin/activate

nohup gunicorn \
-w 4 \
-b 0.0.0.0:8000 \
app:app > app.log 2>&1 &
