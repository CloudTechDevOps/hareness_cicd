#!/bin/bash

sleep 20

STATUS=$(curl -o /dev/null -s -w "%{http_code}" http://localhost:8000/health)

if [ "$STATUS" -eq 200 ]
then

echo "Deployment Successful"

exit 0

else

echo "Deployment Failed"

exit 1

fi
