alfresco-boxes
================

A collection of utilities for Alfresco VM provisioning and deployment using Packer and Vagrant; the deployment and installation logic is provided by [chef-alfresco](https://github.com/maoo/chef-alfresco).

With this project you can
* Package with Packer (```cd packer```)
  * Build and launch Virtualbox (.vdi) Image containing Alfresco 4.2 stack
  * Build and upload an AWS AMI containing Alfresco 4.2 stack
  * Use additional [Packer provisioners](https://github.com/maoo/alfresco-boxes/tree/master/packer/packer-allinone.json#L46), such as ```shell```
* Develop and Test with Vagrant (```cd vagrant```)
  * Customize the VM provisioning and Alfresco configuration/deployment at any stage, simply editing a JSON file
  * Add custom logic, either via external [Chef cookbooks](https://github.com/maoo/alfresco-boxes/tree/master/vagrant/built-with-packer/Berksfile.dev)
  * Create [your own VM from scratch](https://github.com/maoo/alfresco-boxes/tree/master/vagrant/built-with-packer/Vagrantfile)

Configuring your host machine
---
* Make sure that Ruby is installed (I'm currently running on v1.9.3)
* Checkout this project and cd into the root folder
* Install (please respect the exact mentioned versions)
  * [Vagrant 1.3.5](http://downloads.vagrantup.com/tags/v1.3.5)
  * [VirtualBox 4.3.2](https://www.virtualbox.org)
  * [Packer 0.5.2](http://www.packer.io/downloads.html)
* Run ```install.sh``` or
  * Install bundler with ```gem install bundler && bundle install```
  * Run Berkshelf to resolve external chef recipes; this step will have to be executed everytime you change the Berksfile definition with ```bundle exec berks install --path vendor-cookbooks``` (use ```bundle exec berks vendor vendor-cookbooks``` syntax as of Berkshelf 3 onwards); the vendor-cookbooks folder will be created; it can be optionally removed from ```.gitignore``` in order to be used by other provizioning systems, like [AWS OpsWorks](http://docs.aws.amazon.com/opsworks/latest/userguide/workingcookbook-attributes.html)

Uploading AMI to AWS
---
```
packer build -only amazon-ebs -var 'aws_access_key=YOUR ACCESS KEY' -var 'aws_secret_key=YOUR SECRET KEY' alfresco-allinone.json
```
The AMI is based on an existing Ubuntu 12.04 AMI ([ami-de0d9eb7](http://thecloudmarket.com/image/ami-de0d9eb7--ubuntu-images-ebs-ubuntu-precise-12-04-amd64-server-20130222))

Creating VirtualBox/Vagrant box
---
```
packer build -only virtualbox-iso alfresco-allinone[-vagrant].json
```
This will first create and initialize a VirtualBox VM, then it will compress it into a ```packer_virtualbox-iso_virtualbox.box``` stored into the root project folder.

The VirtualBox VM is deleted at the end of the process by default, to save space; if you want to keep the VM on Virtualbox, you need to add the attribute ```"keep_input_artifact": true``` into the [```vagrant``` post-processor in alfresco-allinone.json](https://github.com/maoo/alfresco-boxes/tree/master/packer/alfresco-allinone.json#L56)

Running VM on Vagrant
---
If you want to run the VM you just created with VirtualBox you can use the [Vagrantfile](https://github.com/maoo/alfresco-boxes/tree/master/packer/Vagrantfile) that you find in the root folder; before you run the first time, install the following Vagrant plugins

```
vagrant plugin install vagrant-berkshelf
vagrant plugin install vagrant-omnibus
vagrant plugin install vagrant-vbguest
vagrant plugin install vagrant-hosts
```

To run the VM type ```vagrant up```

Customisations
---
You can read the [alfresco-allinone.json](https://github.com/maoo/alfresco-boxes/tree/master/packer/alfresco-allinone.json) definition to check the default values that are used to install Alfresco; there are many other default values that are defined by the following Chef Recipes
* [artifact-deployer](https://github.com/maoo/artifact-deployer), you can check default values in [attributes.json](https://github.com/maoo/artifact-deployer/tree/master/attributes)
* [chef-alfresco](https://github.com/maoo/chef-alfresco), you can check default values in [attributes.json](https://github.com/maoo/chef-alfresco/tree/master/attributes)

Development
---
If you want to test additional/external Chef recipes without triggering the Packer provisioning (and save some time), simply run ```vagrant up``` from the ```vagrant/dev``` folder
* Open http://192.168.0.23:8080/share
* Login as admin/admin
* Use top-right search box and type 'project'

You can change the [attributes.json](https://github.com/maoo/alfresco-boxes/tree/master/vagrant/built-with-packer/attributes.json) to build your logic

Multi VM
---
In ```vagrant/multivm``` you can find an example of Vagrant multi VM configuration; you can test it running ```run.sh``` from ```vagrant/multivm``` or

```
vagrant up db
vagrant up repo
vagrant up share
vagrant up solr
```
You can access Share on http://10.0.0.31:8080/share

If you just run ```vagrant up``` the execution won't be successful; unfortunately you need to run the command for each and every box.
The boxes ```repo2```, ```share2``` and ```lb``` are used for testing clustering capabilities; more on this (hopefully) soon.

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

When the packer commands fail, the VirtualBox VM may get inaccessiblel check and remove them using

```
VBoxManage list vms
VBoxManage unregistervm 22986cf8-3bad-4d22-8dc9-8983faa36422
```

To reset your local environment, run the following command

```
vagrant destroy -f && killall VBoxSVC && rm -Rf .vagrant *.lock
```
