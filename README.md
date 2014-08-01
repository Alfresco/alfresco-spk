alfresco-boxes
================

A collection of utilities for Alfresco VM provisioning and deployment using Packer and Vagrant; the deployment and installation logic is provided by [chef-alfresco](https://github.com/maoo/chef-alfresco).

With this project you can
* Build ISO/AMI boxes with [Packer](http://www.packer.io)
  * Build and launch Virtualbox (.vdi) Image containing a complete Alfresco 4.2 stack
  * Build and upload an AWS AMI containing a complete Alfresco 4.2 stack
  * Use additional Packer provisioners, such as [shell](http://www.packer.io/docs/provisioners/shell.html)
* Develop and Run with [Vagrant](http://www.vagrantup.com)
  * Customize the VM provisioning and Alfresco configuration/deployment at any stage, simply editing a JSON file
  * Add custom logic, either via external [Chef cookbooks](https://github.com/maoo/alfresco-boxes/tree/master/common/Berksfile)
  * Create [your own VM from scratch](https://github.com/maoo/alfresco-boxes/tree/master/vagrant/dev/alfresco-allinone-dev.json)
* Setup a complete Provisioning solution using [Docker](https://www.docker.io)
  * Use exisiting Docker images for Alfresco
  * Run Alfresco Chef Cookbooks to create custom Docker images
  * Follow the step-by-step tutorials to run your Docker containers locally

Features
---
* Supports Community and Enterprise editions
* Tested with 4.2 version(s)
* Installs and configures Repository, Share and Solr
* Tested on CentOS and Ubuntu (different versions)
* Runs on Vagrant, AWS and Docker, sharing the same set of Chef cookbooks
* Handles Tomcat SSL keystore installation
* Supports AMP installation (via MMT)
* Supports Maven credentials encryption
* Can be configured for any (maven-repository-hosted) Alfresco WAR(s) version/distro
* Auto-generate and/or patch property files (alfresco-global, log4j.properties, solrcore.properties) without the need to maintain pre-defined templates

Installation
---
* Make sure that
  * [ChefDK](http://downloads.getchef.com/chef-dk) is installed
  * Ruby is installed (I'm currently running on v1.9.3, test with ```ruby -v```)
  * If you run on OSX, install XCode (version 5 or higher)
* Checkout this project ```git clone -b alfresco-boxes-<last_tag> https://github.com/maoo/alfresco-boxes.gitub alfresco-boxes```
* ```cd alfresco-boxes/common```
* Install bundler and Vagrant plugins with ```./install.sh```; if you get a ```Gem::FilePermissionError```, use ```sudo ./install.sh```
* Run Berkshelf to resolve external chef recipes ```./create-vendor-cookbooks.sh```
* Install
  * [VirtualBox](https://www.virtualbox.org) - tested with version 4.3.12-93733-OSX
  * Optional, if you want to *run VMs* with [Vagrant](http://downloads.vagrantup.com) - tested with version 1.6.2
  * Optional, if you want to *build boxes* with [Packer](http://www.packer.io/downloads.html) - tested with version 0.5.2

Try it!
---
* If you want to _build_ with Packer, follow [packer/README.md](https://github.com/maoo/alfresco-boxes/tree/master/packer)
* If you want to _run_ with Vagrant, follow [vagrant/README.md](https://github.com/maoo/alfresco-boxes/tree/master/vagrant)
* If you want to _provision_ with Docker, follow [docker/README.md](https://github.com/maoo/alfresco-boxes/tree/master/docker)

Customisations
---
You can read the [alfresco-allinone.json](https://github.com/maoo/alfresco-boxes/tree/master/packer/vbox-precise-421/precise-alf421.json) definition to check the default values that are used to install Alfresco; there are many other default values that are defined by the following Chef Recipes
* [artifact-deployer](https://github.com/maoo/artifact-deployer), you can check default values in [attributes.json](https://github.com/maoo/artifact-deployer/tree/master/attributes)
* [chef-alfresco](https://github.com/maoo/chef-alfresco), you can check default values in [attributes.json](https://github.com/maoo/chef-alfresco/tree/master/attributes)

Updating/Customising Chef Cookbooks
---
Everytime that a new version of the Chef recipes is released, it is necessary to update the ```vendor-cookbooks``` folder using ```./create-vendor-cookbooks.sh``` script.

The vendor-cookbooks folder can be optionally removed from ```.gitignore``` in order to be used by other provizioning systems, like [AWS OpsWorks](http://docs.aws.amazon.com/opsworks/latest/userguide/workingcookbook-attributes.html)
