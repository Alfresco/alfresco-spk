alfresco-boxes
================

A collection of examples for the creation, provisioning and virtualization of Alfresco boxes (VMs, images, bare-metal, ...) that sits on top of:
- [Packer](http://www.packer.io), for creation
- [chef-alfresco](https://github.com/maoo/chef-alfresco), for provisioning
- [Docker](https://www.docker.io), for (smart) virtualization

With this project you can
* Build Alfresco (custom) images of [any nature](http://www.packer.io/docs/templates/builders.html) with Packer, without worrying about the provisioning part
* Run on-the-fly [Vagrant boxes](http://www.vagrantup.com) with Alfresco stack fully configured
* Integrate additional provisioning logic using [Packer provisioners](http://www.packer.io/docs/templates/provisioners.html)
* Setup a complete Provisioning solution using [Alfresco-boxes images for Docker](https://hub.docker.com/u/maoo)
* Build your custom [hierarchy]() of Alfresco images

Features
---
* Supports Community and Enterprise editions
* Tested with latest 4.2.3 and 5.0.a versions
* Installs and configures Repository, Share and Solr application
* Tested on CentOS and Ubuntu
* Runs on Vagrant, Packer and Docker, sharing the same set of Chef cookbooks
* Compatible with AWS, DigitalOcean, OpenStack and many other cloud provisioning services
* Handles Tomcat SSL keystore installation
* Supports AMP installation (via MMT)
* Supports custom Maven repositories (and credentials encryption)
* Can be configured for any Alfresco WAR(s) version/distro; artifacts can be resolved by (local FS) path, url or Maven coordinates
* Auto-generate and/or patch property files (alfresco-global.properties, share-config-custom.xml, log4j.properties, solrcore.properties) without the need to maintain pre-defined templates

Installation
---
* Install [ChefDK](http://downloads.getchef.com/chef-dk)
* Checkout this project with ```git https://github.com/maoo/alfresco-boxes.gitub alfresco-boxes```
* Install [VirtualBox](https://www.virtualbox.org) - you can optionally use VMWare Player/Fusion
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
