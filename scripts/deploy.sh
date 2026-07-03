#!/bin/bash

echo "Deploying..."

rm -rf /home/ec2-user/python-app

mkdir -p /home/ec2-user/python-app

unzip python-app.zip -d /home/ec2-user/python-app
