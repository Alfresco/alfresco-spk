#!/bin/bash

# Run alfresco-spk (within coreOS)
cd /spk
vagrant install plugin json-merge_patch
vagrant up build-images
