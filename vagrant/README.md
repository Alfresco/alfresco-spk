Configure Vagrant
---
Install Vagrant Plugins using ```common/install-vagrant-plugins.sh``` and make sure that Vagrant is properly installed running ```vagrant -v```
Alternatively, you can install your vagrant plugins manually using

```
vagrant plugin install vagrant-omnibus
vagrant plugin install vagrant-vbguest
vagrant plugin install vagrant-hosts
```

Run Vagrant
---
```
cd vagrant/dev
vagrant up
```

You can now
* Open http://192.168.0.33:8080/share
* Login as admin/admin
* Use top-right search box and type 'project'

Multi VM
---
The MultiVM environment on Vagrant is very experimental, since Vagrant is not the most suited technology for this, Docker is more indicated for this use-case.

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

To reset your local environment, run the following command

```
vagrant destroy -f && killall VBoxSVC && rm -Rf .vagrant *.lock
```
