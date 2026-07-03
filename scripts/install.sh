#!/bin/bash

mkdir /home/ec2-user/python-app

cd /home/ec2-user/python-app

python3 -m venv venv

source venv/bin/activate

sudo yum install python3-pip -y
pip3 install -r requirements.txt
