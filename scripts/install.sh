#!/bin/bash
set -e

APP_DIR=/home/ec2-user/python-app
SRC_DIR=/tmp/mechanical

mkdir -p "$APP_DIR"
cp -r "$SRC_DIR"/* "$APP_DIR"/

cd "$APP_DIR"
sudo yum install python3-pip -y
python3 -m venv venv
source venv/bin/activate
pip3 install -r requirements.txt
