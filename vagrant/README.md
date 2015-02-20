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
vagrant plugin install vagrant-hosts
```
Some users have experienced [problems with the vagrant-vbguest plugin](https://github.com/maoo/alfresco-boxes/issues/19)

Run Vagrant
---
```
cd vagrant
vagrant up
```
This command will run - by default - `alfresco-allinone-dev.json`

You can now
* Open http://192.168.0.33:8080/share
* Login as admin/admin
* Use top-right search box and type 'project'

You can optionally define an alternative JSON file and/or select a different OS (only ```centos64``` and ```precise64``` are supported for now)
```
JSON=alfresco-allinone-ent.json BOX_OS=centos64 vagrant up
```

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

Maven Repository custom configuration
---
When `vagrant up` runs, it fetches artifacts using Apache Maven; you may want to reuse a (host) local Maven repository that already contains some of the artifacts you need (saving significant time during provisioning); add the following to your Vagrantfile

```
config.vm.synced_folder File.expand_path("~/m2-repository"), "/root/.m2/repository"
```

By default, alfresco-boxes will purge Maven configuration after the run, to avoid keeping installation files within the box; to avoid this operation, set the following in your JSON attribute file:

```
{
  "provisioners": [
    {
      "json": {
        ...
        "maven" : {
          "purge_settings" : false
        }
      }
    }
  ]
}
```
