#!/bin/bash

# This script will install chef-alfresco into your box, fetching all
# artifacts needed from remote locations
#
# An example of how to use it in a Cloudformation template:
#
# export SKIP_CHEF_RUN=true
# export NODE_NAME=share
# export COOKBOOKS_TARBALL_URL=https://artifacts.alfresco.com/nexus/service/local/repositories/releases/content/org/alfresco/devops/chef-alfresco/$CHEF_ALFRESCO_VERSION/chef-alfresco-$CHEF_ALFRESCO_VERSION.tar.gz
# curl -L https://raw.githubusercontent.com/Alfresco/chef-alfresco/master/install-alfresco.sh --no-sessionid | bash -s

# Allowed values
#NODE_NAME=share
#NODE_NAME=solr

if [ -z "$NODE_NAME" ]; then
  NODE_NAME=allinone
fi

if [ -z "$CHEF_ALFRESCO_VERSION" ]; then
 CHEF_ALFRESCO_VERSION="0.6.7"
fi

if [ -z "$INSTANCE_TEMPLATE_URL" ]; then
  INSTANCE_TEMPLATE_URL=https://raw.githubusercontent.com/Alfresco/chef-alfresco/master/nodes/$NODE_NAME.json
fi

if [ -z "$COOKBOOKS_TARBALL_URL" ]; then
 COOKBOOKS_TARBALL_URL=https://artifacts.alfresco.com/nexus/service/local/repositories/releases/content/org/alfresco/devops/chef-alfresco/$CHEF_ALFRESCO_VERSION/chef-alfresco-$CHEF_ALFRESCO_VERSION.tar.gz
 # temporary fix to get always snapshot version
 # COOKBOOKS_TARBALL_URL=https://artifacts.alfresco.com/nexus/service/local/repositories/snapshots/content/org/alfresco/devops/chef-alfresco/0.6.8-SNAPSHOT/chef-alfresco-0.6.8-20151027.170814-11.tar.gz
fi

# Install Chef - latest version
curl https://www.opscode.com/chef/install.sh | bash

# Download chef-alfresco tar.gz into /tmp folder
curl -L $COOKBOOKS_TARBALL_URL > /tmp/cookbooks.tar.gz

# Unpack it in /tmp
rm -rf /etc/chef/cookbooks
tar xvzf /tmp/cookbooks.tar.gz -C /etc/chef

if [ -n "$DATABAGS_TARBALL_URL" ]; then
 curl -L $DATABAGS_TARBALL_URL > /tmp/databags.tar.gz
 rm -rf /etc/chef/data_bags
 tar xvzf /tmp/databags.tar.gz -C /etc/chef
fi

# Download Chef JSON attribute
curl -L $INSTANCE_TEMPLATE_URL > /etc/chef/attributes.json

# Run chef
# It can be skipped, in case you need to replace some properties
# in your chef attributes file
if [ "$SKIP_CHEF_RUN" -ne "true" ]; then
  cd /etc/chef
  chef-client -z -j /etc/chef/attributes.json
fi
