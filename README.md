Checkout the [Alfresco SPK presentation](http://www.slideshare.net/m.pillitu/alfresco-spkalfrescoday) at Alfresco Day.

## What is Alfresco SPK
Alfresco SPK is a toolset that can be used by stack operators (Devops/Architects/Engineers, Support, QA, Sales, Marketing, ...) to define Alfresco immutable Images, testing them locally first, also for arbitrarily complex architectures.

It allows you to:
1. Run an arbitrarily complex stack locally
2. Build (immutable) image(s) with the exact same provisioning logic used for local run
3. Test immutable images locally
4. Run a stack on any orchestration tool with the same provisioning logic used for local runs

## Installation
Alfresco SPK uses ([Vagrant](https://www.vagrantup.com) and) [vagrant-packer-plugin](https://github.com/Alfresco/vagrant-packer-plugin) to build images and [chef-alfresco](https://github.com/Alfresco/chef-alfresco) to install Alfresco inside the boxes.

Please install:
* [Vagrant](https://www.vagrantup.com/downloads.html)
* [Packer](https://packer.io/downloads.html)

To install the Vagrant Packer Plugin:
```
curl -L --no-sessionid https://github.com/Alfresco/alfresco-spk/raw/vagrant-packer-plugin/pkg/vagrant-packer-plugin-0.5.0.gem > ~/.vagrant.d/vagrant-packer-plugin-0.5.0.gem
vagrant plugin install ~/.vagrant.d/vagrant-packer-plugin-0.5.0.gem
```

## Run a stack locally
```
cd stacks/community-allinone
vagrant up
```
Browse [stacks](stacks) folder and change `VAGRANT_VAGRANTFILE` to test the stack of your choice; to customize it, read more about `Stack definitions` below.

## Build an Image
```
cd stacks/community-allinone
vagrant packer-build
```
This will build an Amazon AMI, but could also create an OVF, Vagrant .box or any other nature [supported by Packer](https://www.packer.io/docs/templates/builders.html)

## Concepts

### What is an Instance template
An Instance Template is a JSON file that includes all information to build an immutable image; it contains:
1. chef-alfresco configuration, using Chef attributes syntax; it also includes the list of recipes to invoke (`run_list`)
2. vagrant-packer configuration, using Packer syntax

Alfresco SPK provides a [list of pre-defined instance-templates](instance-templates) that are used by the sample stacks.

### Stack definitions
In every [stack example](stack-examples) you will find the following items:
```
# Where the instance template is located
instance_template_path = "../instance-templates/allinone-community.json"

# chef-alfresco binary
cookbooks_url = "https://artifacts.alfresco.com/nexus/service/local/repositories/releases/content/org/alfresco/devops/chef-alfresco/0.6.20/chef-alfresco-0.6.20.tar.gz"

# chef-alfresco recipes to invoke
run_list = ["alfresco::default"]
```

Single-instance stacks - such as [Alfresco Community Allinone](stacks/community-allinone.vagrant.rb) - are simpler to start with; if you're looking for multi-machine configurations, check [Alfresco Enterprise Clustered](stacks/enterprise-clustered.vagrant.rb)

### Alfresco Enterprise
```
cd stacks/enterprise-clustered
export NEXUS_USERNAME=<your_nexus_user>
export NEXUS_PASSWORD=<your_nexus_password>
vagrant up
```

### Integrating with AWS (or any other packer-supported builder)
When AMIs are (or not) in place and provisioning logic have been tested locally, it is possible to configure other orchestration tools and/or Cloud providers in order to spin up the same stack remotely.

Alfresco SPK provides a [chef-bootstrap.sh](scripts/chef-bootstrap.sh) that can be used to easily integrate with the orchestration tool of your choice; below we provide an integration example using AWS Cloudformation (and [UserData](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html) attribute)

```
CHEF_NODE_NAME=allinone
CHEF_INSTANCE_TEMPLATE=https://raw.githubusercontent.com/alfresco/alfresco-spk/master/instance-templates/allinone-community.json

CHEF_LOCAL_YAML_VARS_URL=file://$WORK_DIR/local-vars.yaml
cat > $CHEF_LOCAL_YAML_VARS_URL << "EOF"
---
alfresco:
  public_hostname: '{"Fn::GetAtt": ["ElasticLoadBalancer","DNSName"]}'
EOF

ruby chef-bootstrap.rb
```

The expression `{"Fn::GetAtt": ["ElasticLoadBalancer","DNSName"]}` is Cloudformation-specific and reads the `DNSName` value of an `ElasticLoadBalancer` instance defined in the same Cloudformation template.
