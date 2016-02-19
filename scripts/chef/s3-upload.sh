#!/bin/bash

# Uploads a file to an S3 location
# It also ensures that aws commandline is installed

# Example:
# 
# BOX_LOCATION="~/.vagrant.d/data/packer-build/*.box"
# S3_FOLDER_URL="https://s3.amazon.com/..."
# curl -L https://raw.githubusercontent.com/Alfresco/alfresco-spk/master/scripts/chef/s3-upload.sh --no-sessionid | bash -s -- $BOX_LOCATION $S3_FOLDER_URL

if [ "$#" -ne 2 ]; then
    echo "Usage: s3-upload.sh <LocalPath> <S3Uri>"
    exit 1
fi

curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "/tmp/awscli-bundle.zip"
unzip /tmp/awscli-bundle.zip -d /tmp
/tmp/awscli-bundle/install -i /tmp/aws

/tmp/aws/bin/aws s3 cp $1 $2
