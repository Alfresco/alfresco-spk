# Prerequisites
- Install Vagrant
- Install Vagrant SPK plugin
```
cd plugin
bundle update
rake build
vagrant plugin install pkg/spk-0.1.0.gem
```

# To build a Vagrant .box with Alfresco Community 5.1.c-EA

```
vagrant spk build-images -s file://$PWD/stack-templates/community-allinone-vagrantbox.json -k file://$PWD/ks/ks-centos.cfg

tail -f ~/.alfresco-spk/vagrant/packer/packer.log
```
