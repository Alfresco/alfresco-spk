#!/bin/bash

if [ ! -f /usr/bin/vagrant ]; then
  echo "Installing Vagrant..."
  wget -q https://releases.hashicorp.com/vagrant/1.7.4/vagrant_1.7.4_x86_64.rpm
  rpm -ihv vagrant_1.7.4_x86_64.rpm
fi
