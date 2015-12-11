#!/bin/bash

echo "Run alfresco-spk withing CentOS..."
cd /spk
vagrant install plugin json-merge_patch
vagrant up build-images
