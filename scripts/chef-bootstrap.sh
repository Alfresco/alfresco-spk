#!/bin/bash

# Use the Chef Alfresco version of your choice, also SNAPSHOT versions
# export COOKBOOKS_URL="https://artifacts.alfresco.com/nexus/service/local/repositories/releases/content/org/alfresco/devops/chef-alfresco/0.6.11/chef-alfresco-0.6.11.tar.gz"
# DATABAGS_URL="..."

export WORK_DIR=/tmp/chef-bootstrap
export CHEF_NODE_NAME=allinone
export CHEF_INSTANCE_TEMPLATE=https://raw.githubusercontent.com/alfresco/alfresco-spk/master/instance-templates/community-allinone.json
export CHEF_LOCAL_YAML_VARS_URL=file://$WORK_DIR/local-vars.yaml

mkdir -p $WORK_DIR

# Define Local Variables in YAML format, to avoid JSON escaping nightmares
CHEF_LOCAL_YAML_VARS_URL=
cat > $WORK_DIR/local-vars.yaml << "EOF"
---
alfresco:
  install_fonts: false
nginx:
  use_nossl_config: true
EOF

# Fetch files to install alfresco
curl -L https://raw.githubusercontent.com/alfresco/alfresco-spk/master/scripts/provisioning-libs.rb > provisioning-libs.rb
curl -L https://raw.githubusercontent.com/alfresco/alfresco-spk/master/scripts/chef-bootstrap.rb > chef-bootstrap.rb

# Only for allinone, this is necessary to avoid mysql to fail
setenforce 0

yum install -y ruby
gem install json-merge_patch
ruby chef-bootstrap.rb
