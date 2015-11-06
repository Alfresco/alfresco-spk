#!/bin/bash

# Use the Chef Alfresco version of your choice, also SNAPSHOT versions
COOKBOOKS_URL="https://artifacts.alfresco.com/nexus/service/local/repositories/releases/content/org/alfresco/devops/chef-alfresco/0.6.8/chef-alfresco-0.6.8.tar.gz"
# DATABAGS_URL="..."

CHEF_NODE_NAME=allinone
CHEF_INSTANCE_TEMPLATE=https://raw.githubusercontent.com/maoo/alfresco-boxes/newchefalfresco/instance-templates/allinone-community.json

# Define Local Variables in YAML format, to avoid JSON escaping nightmares
CHEF_LOCAL_YAML_VARS_URL=file://$WORK_DIR/local-vars.yaml
cat > $CHEF_LOCAL_YAML_VARS_URL << "EOF"
---
alfresco:
  install_fonts: false
nginx:
  use_nossl_config: true
EOF

ruby chef-bootstrap.rb
