## What is Alfresco SPK
Alfresco SPK is a toolset that can be used by stack operators (Devops/Architects/Engineers, Support, QA, Sales, Marketing, ...) to define stacks locally (first) and run them anywhere (later); it sits on top of existing technologies (ChefDK, Vagrant, Packer) and implements a modular, testable, consistent development workflow for Alfresco software provisioning.

## Concepts

### Instance template
A JSON file that contains provisioning configurations related to a single node of an Alfresco stack; instance templates are resolved via URL, that can point to a local or remote file.

Instance templates are [Chef nodes](https://docs.chef.io/nodes.html) that contain all configurations - also known as Chef attributes - that are involved in the instance provisioning, for example the Alfresco admin password, the db host, the amps to install and much (much) more.

Alfresco SPK provides a [list of pre-defined instance-templates](instance-templates) that are used by the sample stacks; attributes are defined, along with its defaults, by [chef-alfresco](https://github.com/Alfresco/chef-alfresco).

### Stack template
A JSON file that describes a stack in terms of instances.

Stack templates are resolved via URL, that can point to a local or remote file. The default stack template is defined in `stack-templates/community-allinone.json`, though the [stack-templates](stack-templates) folder aims to host many more examples.

You can use any stack template you want, either locally or remotely:
```
export STACK_TEMPLATE_URL=file://$PWD/stack-templates/enterprise-clustered.json
```

Each instance defined in a stack template is composed by the following items.

#### Instance template reference
A URL link that resolves an instance template (described above):
```
{
  "alfresco-allinone" : {
    "instance-template" : {
      "url" : "file://$PWD/instance-templates/allinone-community.json",
      "overlay" : {
        "alfresco" : {
          "properties" : {
            "dir.contentstore" : "/vagrant/.vagrant/alf_data",
            "db.host" : "192.168.33.10"
          }
        }
      }
    },
    ...
  }
}
```
URL can be resolved locally or remotely.

The `overlay` element contain local configurations that are [merged](https://tools.ietf.org/html/rfc7386) into the instance template; as such, the syntax is the same used by instance templates.

Configuration overlays can be specified in JSON or YAML formats; the latter is easier to define within inline scripts, avoiding the need to escape `"` chars:

```
{
  "alfresco-allinone" : {
    "instance-template" : {
      "url" : "file://$PWD/instance-templates/allinone-community.json",
      "overlayYamlUrl" : "file://$PWD/yaml-overlays/allinone.yml"
    },
    ...
  }
}
```

This snippet was taken from [community-allinone.json stack template](stack-templates/community-allinone.json) and uses [allinone.yml](yaml-overlays/allinone.yml) as YAML overlay.

#### Vagrant-related configurations
Used to run the stack locally; for example, `memory` and `cpu` control the resources allocated by Vagrant to run the instance.
```
{
  "alfresco-allinone" : {
    "local-run" : {
      "memory" : "2048",
      "cpus" : "2"
      "ip" : "192.168.33.33"
    },
    ...
  }
}
```

#### Image configurations
Used to create images based on instance template configurations; the `images` item defines
- builders; they define the nature(s) of the image(s) that you want to build; currently, the only builder implemented and extensively tested is [amazon-ebs](packer/amazon-ebs-builder.json.example) (which produces an AMI), though there have been successes for OVF and Docker images too (WIP); any [Packer builder](https://www.packer.io/docs/templates/builders.html) can be easily integrated
- provisioners; by default, the only provisioner needed is [`chef-solo`](packer/chef-solo-provisioner.json), which basically runs the same provisioning logic that runs locally; however, you can extend this list with more [Packer provisioners](https://www.packer.io/docs/templates/provisioners.html) of your choice
- variables; for each entry, a [Packer variable](https://www.packer.io/docs/templates/user-variables.html) is defined; variables can be used by provisioners and builders using the following syntax:
```
{{user `this is my property`}}
```

Below a configuration example that builds an allinone image:
```
{
  "alfresco-allinone" : {
    "images" : {
      "provisioners" : {
        "chef-solo" : "file://$PWD/packer/chef-solo-provisioner.json"
      },
      "builders" : {
        "amazon-ebs" : "file://$PWD/packer/amazon-ebs-builder.json"
      },
      "variables" : {
        "ami_description" : "Alfresco Community 5.1.c-EA - Allinone Server - {{timestamp}}",
        "ami_name" : "Alfresco Community 5.1.c-EA - Allinone Server - {{timestamp}}"
      }
    },
    ...
  }
}
```

## Requirements
* [ChefDK](https://downloads.chef.io/chef-dk)
* [Vagrant](https://www.vagrantup.com/downloads.html)
* [Packer](https://packer.io/downloads.html)

## Configure Vagrant
Vagrant needs some additional plugins:
```
vagrant plugin install vagrant-omnibus
vagrant plugin install vagrant-vbguest
vagrant plugin install json-merge_patch
```

## Development Workflow

### Checkout the project
To start using the Alfresco SPK, first you need to checkout (and cd into) this project:
```
git clone https://github.com/Alfresco/alfresco-spk.git
cd alfresco-spk
```

### Running locally
Assuming that you defined `$STACK_TEMPLATE_URL` with the proper JSON stack definition, in order to spin up the entire stack locally using Vagrant, just type `vagrant up`

This will create a [Vagrant Machine](https://docs.vagrantup.com/v2/multi-machine) for each instance that composes the stack.

Assuming that you've run your stack locally and you're happy with the instance template definitions, you can proceed with one (or both) of the following options:

### Building Immutable images
Create one or more immutable images for each of the instances involved in a given stack; instance templates will be used to dictate the provisioning configuration, whereas Local Variables - as mentioned above - will be ignored.

To create the images:
```
vagrant build-images
```

As above, you can select the stack template using:
```
export STACK_TEMPLATE_URL=file://$PWD/stack-templates/enterprise-clustered.json
```

An image will be created for each instance *and* builder; for example, if you create images for the `enterprise-clustered.json` stack, using `amazon-ebs` and `docker` as builders, you'll get 4 images created.

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

## Custom parameters
You can optionally override the following variables:
```
DOWNLOAD_CMD="curl --silent"
WORK_DIR="./.vagrant"

COOKBOOKS_URL="https://artifacts.alfresco.com/nexus/service/local/repositories/releases/content/org/alfresco/devops/chef-alfresco/0.6.10/chef-alfresco-0.6.10.tar.gz"
DATABAGS_URL=nil

STACK_TEMPLATE_URL="https://raw.githubusercontent.com/Alfresco/chef-alfresco/master/stack-templates/enterprise-clustered.json"
```

### Example of custom values
```
export COOKBOOKS_URL="https://artifacts.alfresco.com/nexus/service/local/repositories/snapshots/content/org/alfresco/devops/chef-alfresco/0.6.8-SNAPSHOT/chef-alfresco-0.6.8-20151104.130154-30.tar.gz"
export STACK_TEMPLATE_URL=file://$PWD/stack-templates/enterprise-clustered.json
```

## Using Alfresco Enterprise
In order to use an enterprise version, you must pass your artifacts.alfresco.com credentials as follows:
```
NEXUS_USERNAME=myusername
NEXUS_PASSWORD=password
```
This approach works for local, remote run and image creation (read above how to export variables on a remote run)

## Debugging
To enable Vagrant debug mode:
```
VAGRANT_LOG=debug
```

To enable Packer debug mode:
```
export PACKER_OPTS=-debug
```

If you want to check if VirtualBox is still running from previous attempps run

```
ps aux | grep VirtualBoxVM
ps aux | grep Vbox
```

To reset your local environment, run the following command

```
vagrant destroy -f && killall VBoxSVC && rm -Rf .vagrant *.lock
```
