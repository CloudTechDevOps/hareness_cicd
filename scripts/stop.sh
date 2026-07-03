#!/bin/bash

echo "Taking Backup..."

mkdir -p /home/ec2-user/backups

if [ -d /home/ec2-user/python-app ]
then

cp -r /home/ec2-user/python-app \
/home/ec2-user/backups/python-app-$(date +%Y%m%d%H%M%S)

fi
