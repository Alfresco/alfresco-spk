#!/bin/bash

export WORK_DIR=/tmp/chef-bootstrap
mkdir -p $WORK_DIR

# Use the Chef Alfresco version of your choice, also SNAPSHOT versions
export COOKBOOKS_URL="https://artifacts.alfresco.com/nexus/service/local/repositories/releases/content/org/alfresco/devops/chef-alfresco/0.6.9/chef-alfresco-0.6.9.tar.gz"
# DATABAGS_URL="..."

export CHEF_NODE_NAME=allinone
export CHEF_INSTANCE_TEMPLATE=https://raw.githubusercontent.com/maoo/alfresco-boxes/newchefalfresco/instance-templates/allinone-community.json

# Define Local Variables in YAML format, to avoid JSON escaping nightmares
CHEF_LOCAL_YAML_VARS_URL=$WORK_DIR/local-vars.yaml
cat > $CHEF_LOCAL_YAML_VARS_URL << "EOF"
---
alfresco:
  install_fonts: false
nginx:
  use_nossl_config: true
EOF

export CHEF_LOCAL_YAML_VARS_URL=file://$CHEF_LOCAL_YAML_VARS_URL

# Fetch files to install alfresco
curl -L https://raw.githubusercontent.com/maoo/alfresco-boxes/newchefalfresco/scripts/provisioning-libs.rb > provisioning-libs.rb
curl -L https://raw.githubusercontent.com/maoo/alfresco-boxes/newchefalfresco/scripts/chef-bootstrap.rb > chef-bootstrap.rb

yum install -y ruby
gem install json-merge_patch
ruby chef-bootstrap.rb
