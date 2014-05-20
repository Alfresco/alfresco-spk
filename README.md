alfresco-boxes
================

A collection of utilities for Alfresco VM provisioning and deployment using Packer and Vagrant; the deployment and installation logic is provided by [chef-alfresco](https://github.com/maoo/chef-alfresco).

With this project you can
* Build ISO/AMI boxes with Packer (```cd packer```)
  * Build and launch Virtualbox (.vdi) Image containing a complete Alfresco 4.2 stack
  * Build and upload an AWS AMI containing a complete Alfresco 4.2 stack
  * Use additional [Packer provisioners](https://github.com/maoo/alfresco-boxes/tree/master/packer/ubuntu/alfresco-allinone.json#L136), such as ```shell```
* Develop and Test with Vagrant (check the [README](https://github.com/maoo/alfresco-boxes/tree/master/vagrant/README.md) to know more)
  * Customize the VM provisioning and Alfresco configuration/deployment at any stage, simply editing a JSON file
  * Add custom logic, either via external [Chef cookbooks](https://github.com/maoo/alfresco-boxes/tree/master/common/Berksfile)
  * Create [your own VM from scratch](https://github.com/maoo/alfresco-boxes/tree/master/vagrant/dev/alfresco-allinone-dev.json)

Configuring your host machine
---
* Make sure that Ruby is installed (I'm currently running on v1.9.3)
* Install (should also work with latest versions, but have not been tested yet)
  * [Vagrant 1.3.5](http://downloads.vagrantup.com/tags/v1.3.5)
  * [VirtualBox 4.3.2](https://www.virtualbox.org)
  * [Packer 0.5.2](http://www.packer.io/downloads.html)
* Checkout this project
* ```cd alfresco-boxes/common```
* Run ```install.sh``` or
  * Install bundler with ```gem install bundler && bundle install```
  * Run Berkshelf to resolve external chef recipes; this step will have to be executed everytime you change the Berksfile definition with ```bundle exec berks install --path vendor-cookbooks``` (use ```bundle exec berks vendor vendor-cookbooks``` syntax as of Berkshelf 3 onwards); the vendor-cookbooks folder will be created; it can be optionally removed from ```.gitignore``` in order to be used by other provizioning systems, like [AWS OpsWorks](http://docs.aws.amazon.com/opsworks/latest/userguide/workingcookbook-attributes.html)

Creating VirtualBox/Vagrant box
---
```
cd alfresco-boxes/packer/ubuntu
packer build -only virtualbox-iso alfresco-allinone.json
```
This will create a output-virtualbox-iso/<box-name>.ovf and output-virtualbox-iso/<box-name>.vdmk, ready to be imported into VirtualBox.
After importing - and before launching your VM - change the Network settings: switch the network card type from ```NAT``` to ```bridged```

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
