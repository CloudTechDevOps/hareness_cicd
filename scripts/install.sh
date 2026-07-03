#!/bin/bash

cd /home/ec2-user/python-app

python3 -m venv venv

source venv/bin/activate

yum install python3-pip -y
yum install git -y
pip install -r requirements.txt
