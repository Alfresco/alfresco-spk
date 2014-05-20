Development
---
If you want to test additional/external Chef recipes without triggering the Packer provisioning (and save some time), simply run ```vagrant up``` from the ```vagrant/dev``` folder
* Open http://192.168.0.33:8080/share
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