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
* Install [ChefDK](http://downloads.getchef.com/chef-dk)
* Checkout this project with ```git https://github.com/maoo/alfresco-boxes.gitub alfresco-boxes```
* Install [VirtualBox](https://www.virtualbox.org) - latest tested version 4.3.14.r95030 (you can optionally use VMWare Player/Fusion)
* Install Vendor Chef Cookbooks with ```cd alfresco-boxes/common && ./create-vendor-cookbooks.sh```
  * This step needs to be executed everytime that ```common/Berksfile``` is edited
  * Cookbooks are fetched and locally cached into ```common/vendor-cookbooks``` folder
  * By default ```common/vendor-cookbooks``` folder is git-ignored (via ```.gitignore```), but it could be pushed in order to be used by other provisioning systems, like [AWS OpsWorks](http://docs.aws.amazon.com/opsworks/latest/userguide/workingcookbook-attributes.html)

Creating a box
---
* If you want to _build_ with Packer, follow [packer/README.md](https://github.com/maoo/alfresco-boxes/tree/master/packer)
* If you want to _run_ with Vagrant, follow [vagrant/README.md](https://github.com/maoo/alfresco-boxes/tree/master/vagrant)
* If you want to _provision_ with Docker, follow [docker/README.md](https://github.com/maoo/alfresco-boxes/tree/master/docker)

Known Issues
---
If you're using Ubuntu as guest machines and you're running alfresco-boxes behind a firewall, you must ensure that [port 11371 is open/reachable](http://support.gpgtools.org/kb/faq/im-behind-a-firewall-eg-in-a-big-company-and-cant-reach-any-key-server-what-now)
