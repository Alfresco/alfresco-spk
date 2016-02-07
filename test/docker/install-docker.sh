#!/bin/bash

#Installing Docker
if [ ! -f /usr/bin/docker ]; then
  echo "Installing and starting Docker..."
  curl -sSL https://get.docker.com/ | sh
  service docker start
fi

