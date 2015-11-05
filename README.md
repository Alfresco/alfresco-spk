## What is Alfresco SPK
Alfresco SPK is a toolset that can be used by stack operators (Devops/Architects/Engineers, Support, QA, Sales, Marketing, ...) to define stacks locally (first) and run them anywhere (later); it sits on top of existing technologies (ChefDK, Vagrant, Packer) and implements a modular, testable, consistent development workflow for Alfresco software provisioning.

## Concepts
* Instance template - a JSON file that contains provisioning configurations related to a single node of an Alfresco stack; instance templates are resolved via URL, that can point to a local or remote file
* Stack template - a JSON file that describes a stack in terms of instances; each instance will link to an instance template JSON file; stack templates are resolved via URL, that can point to a local or remote file. The default stack template is defined in `stack-templates/community-allinone.json`; you can use another stack template simply setting the `$STACK_TEMPLATE_URL` environment variable:

```
export STACK_TEMPLATE_URL=file://$PWD/stack-templates/community-allinone.json
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

### Running remotely on AWS (or any other packer-supported builder)
If your local run works and you're happy with it, you can test it against AWS, or any other cloud provider that is [supported by Packer](https://www.packer.io/docs/templates/builders.html)
...

### Packaging images
...

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
For debugging purposes, prepend
* ```VAGRANT_LOG=debug``` to ```vagrant``` commsnds

## Troubleshooting
If you want to check if VirtualBox is still running from previous attempps run

```
ps aux | grep VirtualBoxVM
ps aux | grep Vbox
```

To reset your local environment, run the following command

```
vagrant destroy -f && killall VBoxSVC && rm -Rf .vagrant *.lock
```
