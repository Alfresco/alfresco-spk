#!/bin/bash

#Check if Docker is running
ps auxwf|grep "docker daemon"|grep -v grep
if [ $? -eq 1 ]; then
  sudo service docker start
fi
