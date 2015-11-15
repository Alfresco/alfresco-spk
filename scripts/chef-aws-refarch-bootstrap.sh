#!/bin/bash

# Bootstraps "Alfresco Community 5.1.c-EA - Allinone Server" AMI,
# built with Alfresco SPK.
#
# Copy/paste this script into Userdata configuration of
# any EC2 instance launch; as such, it can be reused in
# any cloudformation or AWS-specific orchestration tool;
# more info on
# http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html

export WORK_DIR=/tmp/chef-bootstrap
mkdir -p $WORK_DIR

export CHEF_NODE_NAME=allinone
export CHEF_INSTANCE_TEMPLATE=https://raw.githubusercontent.com/alfresco/alfresco-spk/master/instance-templates/allinone-community.json

export FQDN=$(curl http://169.254.169.254/latest/meta-data/public-hostname)

# Open SELinux restrictions to allow haproxy/nginx to run
# semanage port -a -t http_port_t -p tcp 2100
# semanage permissive -a httpd_t
# semanage permissive -a haproxy_t

# Define Local Variables in YAML format, to avoid JSON escaping nightmares
CHEF_LOCAL_YAML_VARS_URL=$WORK_DIR/local-vars.yaml
cat > $CHEF_LOCAL_YAML_VARS_URL << ENDOFCONTENT
---
run_list: ["alfresco::redeploy"]
alfresco:
  public_hostname: '$FQDN'
ENDOFCONTENT

export CHEF_LOCAL_YAML_VARS_URL=file://$CHEF_LOCAL_YAML_VARS_URL

# Fetch files to install alfresco
curl -L https://raw.githubusercontent.com/alfresco/alfresco-spk/master/scripts/provisioning-libs.rb > provisioning-libs.rb
curl -L https://raw.githubusercontent.com/alfresco/alfresco-spk/master/scripts/chef-bootstrap.rb > chef-bootstrap.rb

# Run Alfresco installation
yum install -y ruby
gem install json-merge_patch
ruby chef-bootstrap.rb
