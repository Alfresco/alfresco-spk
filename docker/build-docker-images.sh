#!/bin/bash

echo "Run alfresco-spk withing CentOS..."
cd /spk
export PACKER_BIN=/opt/packer/packer
vagrant plugin install json-merge_patch
export STACK_TEMPLATE_URL=file:///spk/stack-templates/community-allinone-docker.json
vagrant up build-images
