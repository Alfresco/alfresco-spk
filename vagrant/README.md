Install Packer
---
* Download [Vagrant installer](https://www.vagrantup.com/downloads.html)
* Install [Ruby and Bundler](http://bundler.io) (if you're in OSX, you can just install [XCode](https://developer.apple.com/xcode))

Configure Vagrant
---
Install Vagrant Plugins using ```common/install-vagrant-plugins.sh``` and make sure that Vagrant is properly installed running ```vagrant -v```
Alternatively, you can install your vagrant plugins manually using

```
vagrant plugin install vagrant-omnibus
vagrant plugin install vagrant-vbguest
vagrant plugin install vagrant-triggers
```
Some users have experienced [problems with the vagrant-vbguest plugin](https://github.com/maoo/alfresco-boxes/issues/19)

Run Vagrant
---
```
cd vagrant
vagrant up
```

You can now
* Open http://192.168.0.33:8080/share
* Login as admin/admin
* Use top-right search box and type 'project'

Custom parameters
---
You can optionally override the following variables:
```
DOWNLOAD_CMD="curl"
WORK_DIR="./.vagrant"

COOKBOOKS_URL="https://artifacts.alfresco.com/nexus/service/local/repositories/releases/content/org/alfresco/devops/chef-alfresco/0.6.7/chef-alfresco-0.6.7.tar.gz"
DATABAGS_URL=nil

STACK_TEMPLATE_URL="https://raw.githubusercontent.com/Alfresco/chef-alfresco/master/stack-templates/enterprise-clustered.json"
```

Alfresco Enterprise
---
In order to use an enterprise version, you must pass your artifacts.alfresco.com credentials as follows:
```
NEXUS_USERNAME=myusername
NEXUS_PASSWORD=password
```

Debugging
---
For debugging purposes, prepend
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
