vagrant-alfresco-boxes
================

A collection of utilities for Alfresco VM provisioning and deployment using Packer and Vagrant; the deployment and installation logic is provided by [chef-alfresco](https://github.com/maoo/chef-alfresco).

With this project you can
* Build and launch Virtualbox (.vdi) Image containing Alfresco 4.2 stack
* Build and upload an AWS AMI containing Alfresco 4.2 stack
* Customize the Alfresco stack at any level, importing external Chef recipes (see [Berksfile](https://github.com/maoo/vagrant-alfresco-boxes/https://github.com/maoo/vagrant-alfresco-boxes/tree/master/Berksfile))

Configuring your host machine
---
* Make sure that Ruby is installed (I'm currently running on v1.9.3)
* Checkout this project and cd into the root folder
* Install (please respect the exact mentioned versions)
  * [Vagrant 1.3.5](http://docs.vagrantup.com/v2/installation/index.html)
  * [VirtualBox 4.3.2](https://www.virtualbox.org)
  * [Packer 0.5.2](http://www.packer.io/downloads.html)
* Install bundler with ```gem install bundler && bundle install```
* Run Berkshelf to resolve external chef recipes; this step will have to be executed everytime you change the Berksfile definition with ```bundle exec berks install --path vendor-cookbooks```

Uploading AMI to AWS
---
```
packer build  -var 'aws_access_key=YOUR ACCESS KEY'  -var 'aws_secret_key=YOUR SECRET KEY' packer-allinone.json
```
The AMI is based on an existing Ubuntu 12.04 AMI ([ami-de0d9eb7](http://thecloudmarket.com/image/ami-de0d9eb7--ubuntu-images-ebs-ubuntu-precise-12-04-amd64-server-20130222))

Creating Vagrant box
---
```
packer build -only virtualbox-iso packer-allinone.json
```

Running VM on Vagrant
---

Before you run the first time, install the needed plugins (@TODO - test without, shouldn't be used/needed anymore)
```
vagrant plugin install vagrant-berkshelf
vagrant plugin install vagrant-omnibus
vagrant plugin install vagrant-vb
```

To run the VM run ```vagrant up```

Debugging
---
For debugging purposes, prepend
* ```PACKER_LOG=1``` to ```packer``` commands
* ```VAGRANT_LOG=debug``` to ```vagrant``` commsnds

Troubleshooting
---
If you want to check if VirtualBox is still running from previous attempps run

```
ps aux | grep VirtualBoxVM
ps aux | grep Vbox
```

To reset your local environment, run the following command

```
vagrant destroy -f && killall VBoxSVC && rm -Rf .vagrant *.lock
```
