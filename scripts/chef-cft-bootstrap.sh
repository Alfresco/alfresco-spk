#!/bin/bash

# Use the Chef Alfresco version of your choice, also SNAPSHOT versions
COOKBOOKS_URL="https://artifacts.alfresco.com/nexus/service/local/repositories/releases/content/org/alfresco/devops/chef-alfresco/0.6.8/chef-alfresco-0.6.8.tar.gz"
# DATABAGS_URL="..."

WORK_DIR=/tmp/chef-bootstrap
CHEF_NODE_NAME=allinone
CHEF_INSTANCE_TEMPLATE=https://raw.githubusercontent.com/maoo/alfresco-boxes/newchefalfresco/instance-templates/allinone-community.json

# Setup /etc/hosts
export LOCALIP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
export LOCALNAME=$(curl http://169.254.169.254/latest/meta-data/local-hostname)
export LOCALSHORTNAME=$(curl http://169.254.169.254/latest/meta-data/hostname|awk -F. '{print $1}')

# Manage Alfresco License retrieval
mkdir /opt/alflicense
curl -L ",{"Ref": "AlfrescoTrialLicense"}," -o /opt/alflicense/license.lic

# Open SELinux restrictions to allow haproxy/nginx to run
semanage port -a -t http_port_t -p tcp 2100
semanage permissive -a httpd_t
semanage permissive -a haproxy_t

# Define Local Variables in YAML format, to avoid JSON escaping nightmares
CHEF_LOCAL_YAML_VARS_URL=file://$WORK_DIR/local-vars.yaml
cat > $CHEF_LOCAL_YAML_VARS_URL << "EOF"
---
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

ruby chef-bootstrap.rb
