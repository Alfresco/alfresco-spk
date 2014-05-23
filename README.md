alfresco-boxes
================

A collection of utilities for Alfresco VM provisioning and deployment using Packer and Vagrant; the deployment and installation logic is provided by [chef-alfresco](https://github.com/maoo/chef-alfresco).

With this project you can
* Build ISO/AMI boxes with Packer (```cd packer/ubuntu```)
  * Build and launch Virtualbox (.vdi) Image containing a complete Alfresco 4.2 stack
  * Build and upload an AWS AMI containing a complete Alfresco 4.2 stack
  * Use additional [Packer provisioners](https://github.com/maoo/alfresco-boxes/tree/master/packer/ubuntu/alfresco-allinone.json#L136), such as ```shell```
* Develop and Run with Vagrant (check the [README](https://github.com/maoo/alfresco-boxes/tree/master/vagrant/README.md) to know more)
  * Customize the VM provisioning and Alfresco configuration/deployment at any stage, simply editing a JSON file
  * Add custom logic, either via external [Chef cookbooks](https://github.com/maoo/alfresco-boxes/tree/master/common/Berksfile)
  * Create [your own VM from scratch](https://github.com/maoo/alfresco-boxes/tree/master/vagrant/dev/alfresco-allinone-dev.json)

Features
---
* Supports Community and Enterprise editions
* Tested with 4.2 version(s)
* Installs and configures Repository, Share and Solr
* Tested on CentOS and Ubuntu (different versions)
* Handles Tomcat SSL keystore installation
* Supports AMP installation (via MMT)
* Supports Maven credentials encryption
* Can be configured for any (maven-repository-hosted) Alfresco WAR(s) version/distro
* Auto-generate and/or patch property files (alfresco-global, log4j.properties, solrcore.properties) without the need to maintain pre-defined templates

Installation
---
* Make sure that
  * Ruby is installed (I'm currently running on v1.9.3, test with ```ruby -v```)
  * If you run on OSX, install XCode (version 5 or higher)
* Install
  * [VirtualBox](https://www.virtualbox.org) - tested with version 4.3.12-93733-OSX
  * Optional, if you want to *run VMs* with [Vagrant](http://downloads.vagrantup.com) - tested with version 1.6.2
  * Optional, if you want to *build boxes* with [Packer](http://www.packer.io/downloads.html) - tested with version 0.5.2
* Checkout this project ```git clone git@github.com:maoo/alfresco-boxes.git alfresco-boxes```
* ```cd alfresco-boxes/common```
* Install bundler and Vagrant plugins with ```./install.sh```
* Run Berkshelf to resolve external chef recipes ```./create-vendor-cookbooks.sh```
* (Optional) Install Docker:
```
brew install boot2init
brew install docker
boot2docker up
boot2docker init #Starts the docker daemon
export DOCKER_HOST=tcp://localhost:4243 #Identifies the docker server; must be done on the same shell where the ```packer``` command is executed
```

```
sudo su
curl https://raw.githubusercontent.com/noplay/docker-osx/0.11.1/docker-osx > /usr/local/bin/docker-osx
docker-osx shell
docker-osx start
```

For more info on Docker installation ckeck the [Docker docs](http://docs.docker.io/installation/)

Creating VirtualBox/Vagrant box
---
```
cd alfresco-boxes/packer/ubuntu
packer build -only virtualbox-iso alfresco-allinone.json
```
This will create a output-virtualbox-iso/<box-name>.ovf and output-virtualbox-iso/<box-name>.vdmk, ready to be imported into VirtualBox.

The user/password to login (and check the local IP - ifconfig - that is assigned by DHCP) is vagrant/vagrant
You can also create a Vagrant box by adding a Packer post-processor in alfresco-allinone.json](https://github.com/maoo/alfresco-boxes/tree/master/packer/ubuntu/alfresco-allinone.json#L150)

Uploading AMI to AWS
---
```
cd alfresco-boxes/packer/ubuntu
packer build -only amazon-ebs -var 'aws_access_key=YOUR ACCESS KEY' -var 'aws_secret_key=YOUR SECRET KEY' alfresco-allinone.json
```
The AMI is based on an existing Ubuntu 12.04 AMI ([ami-de0d9eb7](http://thecloudmarket.com/image/ami-de0d9eb7--ubuntu-images-ebs-ubuntu-precise-12-04-amd64-server-20130222))

Customisations
---
You can read the [alfresco-allinone.json](https://github.com/maoo/alfresco-boxes/tree/master/packer/ubuntu/alfresco-allinone.json) definition to check the default values that are used to install Alfresco; there are many other default values that are defined by the following Chef Recipes
* [artifact-deployer](https://github.com/maoo/artifact-deployer), you can check default values in [attributes.json](https://github.com/maoo/artifact-deployer/tree/master/attributes)
* [chef-alfresco](https://github.com/maoo/chef-alfresco), you can check default values in [attributes.json](https://github.com/maoo/chef-alfresco/tree/master/attributes)

Updating/Customising Chef Cookbooks
---
Everytime that a new version of the Chef recipes is released, it is necessary to update the ```vendor-cookbooks``` folder:
* Edit Berksfile and update the chef cookbook list
* ```rm -Rf alfresco-boxes/common/vendor-cookbooks```
* ```cd alfresco-boxes/common && bundle exec berks install --path vendor-cookbooks```

The vendor-cookbooks folder can be optionally removed from ```.gitignore``` in order to be used by other provizioning systems, like [AWS OpsWorks](http://docs.aws.amazon.com/opsworks/latest/userguide/workingcookbook-attributes.html)
