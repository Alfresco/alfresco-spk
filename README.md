## What is Alfresco SPK
Alfresco SPK is a toolset that can be used by stack operators (Devops/Architects/Engineers, Support, QA, Sales, Marketing, ...) to define stacks locally (first) and run them anywhere (later); it sits on top of existing technologies (ChefDK, Vagrant, Packer) and implements a modular, testable, consistent development workflow for Alfresco software provisioning.

## Concepts

### Instance template
A JSON file that contains provisioning configurations related to a single node of an Alfresco stack; instance templates are resolved via URL, that can point to a local or remote file.

Instance templates are [Chef nodes](https://docs.chef.io/nodes.html) that contain all configurations - also known as Chef attributes - that are involved in the instance provisioning, for example the Alfresco admin password, the db host, the amps to install and much (much) more.

Attributes are defined, along with its defaults, by [chef-alfresco](https://github.com/Alfresco/chef-alfresco) provides the definition of such attributes, along with its defaults.

Alfresco SPK provides a [list of pre-defined instance-templates](instance-templates) that are used by the sample stacks.

### Stack template
A JSON file that describes a stack in terms of instances; each instance is composed by
- An instance template, as described above
- Vagrant-related configurations, that are used to run the stack locally; for example, `memory` and `cpu` control the resources allocated by Vagrant to run the instance. `localVars` is a JSON snippet that [merges](https://tools.ietf.org/html/rfc7386) the instance template JSON; it allows to overlay instance template configurations that are needed for local runs with Vagrant; this configuration is not involved in any other SPK feature, rather than running locally with Vagrant.
- Packer-related configurations, that are used to create images based on instance template configurations; the `packer` item defines
  - builders; they define the nature(s) of the image(s) that you want to build; currently, the only builder implemented and extensively tested is [amazon-ebs](packer/amazon-ebs-builder.json.example) (which produces an AMI), though there have been successes for OVF and Docker images too (WIP); any [Packer builder](https://www.packer.io/docs/templates/builders.html) can be easily integrated
  - provisioners; by default, the only provisioner is needed is [`chef-solo`](packer/chef-solo-provisioner.json), which basically runs the same provisioning logic that runs locally; however, you can extend this list with more [Packer provisioners](https://www.packer.io/docs/templates/provisioners.html) of your choice

Stack templates are resolved via URL, that can point to a local or remote file. The default stack template is defined in `stack-templates/community-allinone.json`, though the [stack-templates](stack-templates) folder aims to host many more examples.

You can use any stack template you want, either locally or remotely:
```
export STACK_TEMPLATE_URL=file://$PWD/stack-templates/enterprise-clustered.json
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

### Packaging images
Create an immutable image for each of the instances involved in a given stack; instance templates will be used to dictate the provisioning configuration, whereas `localVars` - as mentioned above - will be ignored.

To create the images:
```
vagrant packer
```

As above, you can select the stack template using:
```
export STACK_TEMPLATE_URL=file://$PWD/stack-templates/enterprise-clustered.json
```

An image will be created for each instance *and* builder; for example, if you create images for the `enterprise-clustered.json` stack, using `amazon-ebs` and `docker` as builders, you'll get 4 images created.

### Running remotely on AWS (or any other packer-supported builder)
Test instance templates against AWS, or any other cloud provider that is [supported by Packer](https://www.packer.io/docs/templates/builders.html)

...TODO - chef-bootstrap.sh

## Custom parameters
You can optionally override the following variables:
```
DOWNLOAD_CMD="curl --silent"
WORK_DIR="./.vagrant"

COOKBOOKS_URL="https://artifacts.alfresco.com/nexus/service/local/repositories/releases/content/org/alfresco/devops/chef-alfresco/0.6.7/chef-alfresco-0.6.7.tar.gz"
DATABAGS_URL=nil

STACK_TEMPLATE_URL="https://raw.githubusercontent.com/Alfresco/chef-alfresco/master/stack-templates/enterprise-clustered.json"
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
