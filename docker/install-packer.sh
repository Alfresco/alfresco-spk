#!/bin/bash

yum -y install unzip

#Installing Packer
wget -q https://dl.bintray.com/mitchellh/packer/packer_0.8.6_linux_amd64.zip
mkdir -p /opt/packer; unzip -o packer_0.8.6_linux_amd64.zip -d /opt/packer
