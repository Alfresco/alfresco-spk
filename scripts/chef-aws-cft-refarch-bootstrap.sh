#!/bin/bash

export WORK_DIR=/tmp/chef-bootstrap
mkdir -p $WORK_DIR

# Use the Chef Alfresco version of your choice, also SNAPSHOT versions
# export COOKBOOKS_URL="https://artifacts.alfresco.com/nexus/service/local/repositories/releases/content/org/alfresco/devops/chef-alfresco/0.6.9/chef-alfresco-0.6.9.tar.gz"
# DATABAGS_URL="..."

export CHEF_NODE_NAME=allinone
export CHEF_INSTANCE_TEMPLATE=https://raw.githubusercontent.com/maoo/alfresco-boxes/newchefalfresco/instance-templates/allinone-community.json

# Manage Alfresco License retrieval
mkdir /opt/alflicense
curl -L ",{"Ref": "AlfrescoTrialLicense"}," -o /opt/alflicense/license.lic

# Open SELinux restrictions to allow haproxy/nginx to run
semanage port -a -t http_port_t -p tcp 2100
semanage permissive -a httpd_t
semanage permissive -a haproxy_t

# Define Local Variables in YAML format, to avoid JSON escaping nightmares
CHEF_LOCAL_YAML_VARS_URL=$WORK_DIR/local-vars.yaml
cat > $CHEF_LOCAL_YAML_VARS_URL << "EOF"
---
run_list: ["alfresco::redeploy"]
artifact-deployer:
  maven:
    repositories:
      private:
        username: '{"Ref": "ArtifactRepoUsername"}'
        password: '{"Ref": "ArtifactRepoPassword"}'
alfresco:
  public_hostname: '{"Fn::GetAtt": ["ElasticLoadBalancer","DNSName"]}'
  properties:
    s3.accessKey: '{"Ref":"CfnKeys"}'
    s3.secretKey: '{"Fn::GetAtt":["CfnKeys","SecretAccessKey"]}'
    hz_aws_access_key: '{"Ref":"CfnKeys"}'
    hz_aws_secret_key: '{"Fn::GetAtt":["CfnKeys","SecretAccessKey"]}'
    db.host: '{"Fn::GetAtt": ["RDSDBInstance","Endpoint.Address"]}'
    db.dbname: '{"Ref": "RDSDBName"}'
    db.username: '{"Ref": "RDSUsername"}'
    db.password: '{"Ref": "RDSPassword"}'
    s3.bucketName: '{"Ref": "S3BucketName"}'
    s3.bucketLocation: '{"Ref": "AWS::Region"}'
    s3.bucketRegion: '{"Ref": "AWS::Region"}'
    s3service.s3-endpoint: 's3-{"Ref": "AWS::Region"}.amazonaws.com'
    hz_aws_sg_name: 'AWS_SG_NAME'
EOF

export CHEF_LOCAL_YAML_VARS_URL=file://$CHEF_LOCAL_YAML_VARS_URL

# Fetch files to install alfresco
curl -L https://raw.githubusercontent.com/maoo/alfresco-boxes/newchefalfresco/scripts/provisioning-libs.rb > provisioning-libs.rb
curl -L https://raw.githubusercontent.com/maoo/alfresco-boxes/newchefalfresco/scripts/chef-bootstrap.rb > chef-bootstrap.rb

# Run Alfresco installation
yum install -y ruby
gem install json-merge_patch
ruby chef-bootstrap.rb
