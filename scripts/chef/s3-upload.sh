#!/bin/bash

# Uploads a file to an S3 location
# It also ensures that aws commandline is installed

if [ "$#" -ne 2 ]; then
    echo "Usage: s3-upload.sh <LocalPath> <S3Uri>"
    exit 1
fi

curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "/tmp/awscli-bundle.zip"
unzip /tmp/awscli-bundle.zip -d /tmp
/tmp/awscli-bundle/install -i /tmp/aws

/tmp/aws/bin/aws s3 cp $1 $2
