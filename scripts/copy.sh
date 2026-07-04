#!/bin/bash
set -e

APP_DIR=/home/ec2-user/python-app
SRC_DIR=/tmp/mechanical

mkdir -p "$APP_DIR"
cp -r "$SRC_DIR"/* "$APP_DIR"/
