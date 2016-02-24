#!/bin/bash

curl -L --no-sessionid https://github.com/Alfresco/alfresco-spk/raw/packer-plugin-improvs/pkg/vagrant-packer-plugin-0.5.0.gem > ~/.vagrant.d/vagrant-packer-plugin-0.5.0.gem

vagrant plugin install ~/.vagrant.d/vagrant-packer-plugin-0.5.0.gem
