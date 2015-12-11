#!/bin/bash

if [ ! -f /usr/bin/unzip ]; then
  echo "Downloadin upzip..."
  yum -y install unzip
fi

#Installing Packer
if [ ! -f /opt/packer/packer ]; then
  echo "Downloading Packer (126MB)..."
  wget -q https://dl.bintray.com/mitchellh/packer/packer_0.8.6_linux_amd64.zip
  mkdir -p /opt/packer; unzip -o packer_0.8.6_linux_amd64.zip -d /opt/packer
fi
