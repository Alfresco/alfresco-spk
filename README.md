alfresco-boxes
================

A collection of utilities for Alfresco VM provisioning and deployment using Packer and Vagrant; the deployment and installation logic is provided by [chef-alfresco](https://github.com/maoo/chef-alfresco).

With this project you can
* Build and launch Virtualbox (.vdi) Image containing Alfresco 4.2 stack
* Build and upload an AWS AMI containing Alfresco 4.2 stack
* Customize the VM provisioning and Alfresco configuration/deployment at any stage, simply editing a JSON file
* Add custom logic, either via external [Chef cookbooks](https://github.com/maoo/alfresco-boxes/tree/master/Berksfile), or using additional [Packer provisioners](https://github.com/maoo/alfresco-boxes//tree/masterpacker-allinone.json#L127), such as ```shell```
* Use Vagrant to create [your own VM from scratch](https://github.com/maoo/alfresco-boxes/tree/master/dev/Vagrantfile)

Configuring your host machine
---
* Make sure that Ruby is installed (I'm currently running on v1.9.3)
* Checkout this project and cd into the root folder
* Install (please respect the exact mentioned versions)
  * [Vagrant 1.3.5](http://docs.vagrantup.com/v2/installation/index.html)
  * [VirtualBox 4.3.2](https://www.virtualbox.org)
  * [Packer 0.5.2](http://www.packer.io/downloads.html)
* Run ```install.sh``` or
  * Install bundler with ```gem install bundler && bundle install```
  * Run Berkshelf to resolve external chef recipes; this step will have to be executed everytime you change the Berksfile definition with ```bundle exec berks install --path vendor-cookbooks```

Uploading AMI to AWS
---
```
packer build  -var 'aws_access_key=YOUR ACCESS KEY'  -var 'aws_secret_key=YOUR SECRET KEY' packer-allinone.json
```
The AMI is based on an existing Ubuntu 12.04 AMI ([ami-de0d9eb7](http://thecloudmarket.com/image/ami-de0d9eb7--ubuntu-images-ebs-ubuntu-precise-12-04-amd64-server-20130222))

Creating VirtualBox/Vagrant box
---
```
packer build -only virtualbox-iso packer-allinone.json
```
This will first create and initialize a VirtualBox VM, then it will compress it into a ```packer_virtualbox-iso_virtualbox.box``` stored into the root project folder.

The VirtualBox VM is deleted at the end of the process by default, to save space; if you want to keep the VM on Virtualbox, you need to add the attribute ```"keep_input_artifact": true``` into the [```vagrant``` post-processor in packer-allinone.json](https://github.com/maoo/alfresco-boxes/tree/master/packer-allinone.json#L144)

Running VM on Vagrant
---
If you want to run the VM you just created with VirtualBox you can use the [Vagrantfile](https://github.com/maoo/alfresco-boxes/tree/master/Vagrantfile) that you find in the root folder; before you run the first time, install the following Vagrant plugins

```
vagrant plugin install vagrant-berkshelf
vagrant plugin install vagrant-omnibus
vagrant plugin install vagrant-vbguest
```

To run the VM type ```vagrant up```

Customisations
---
You can read the [packer-allinone.json](https://github.com/maoo/alfresco-boxes/tree/master/packer-allinone.json) definition to check the default values that are used to install Alfresco; there are many other default values that are defined by the following Chef Recipes
* [artifact-deployer](https://github.com/maoo/artifact-deployer), you can check default values in [attributes.json](https://github.com/maoo/artifact-deployer/tree/master/attributes)
* [chef-alfresco](https://github.com/maoo/chef-alfresco), you can check default values in [attributes.json](https://github.com/maoo/chef-alfresco/tree/master/attributes)

Development
---
If you want to test additional/external Chef recipes without triggering the Packer provisioning (and save some time), simply run ```vagrant up``` from the ```dev``` folder
* Open http://192.168.0.23:8080/share
* Login as admin/admin
* Use top-right search box and type 'project'

You can change the [attributes.json](https://github.com/maoo/alfresco-boxes/tree/master/dev/attributes.json) to build your logic; if you need to test an additional Chef recipe, you'll need to change the root [Berksfile](https://github.com/maoo/alfresco-boxes/tree/master/Berksfile) (used by Packer), otherwise you can change ```config.berkshelf.berksfile_path``` in [Vagrantfile](https://github.com/maoo/alfresco-boxes/tree/master/dev/Vagrantfile)

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
