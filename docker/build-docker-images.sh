#!/bin/bash

echo "Run alfresco-spk withing CentOS..."
cd /spk
vagrant plugin install json-merge_patch
vagrant up build-images
