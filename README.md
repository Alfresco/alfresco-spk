# Vagrant Packer plugin

## What Is
Vagrant Packer plugin allows to compose Packer templates and run them using vagrant and `Vagrantfile`; it also helps using Chef as provisioner.

## Install
- Install [Vagrant](https://www.vagrantup.com/downloads.html)
- Install [Packer (0.8.6+)](https://www.packer.io/downloads.html)
- Install Vagrant Packer plugin
```
curl -L --no-sessionid https://github.com/Alfresco/alfresco-spk/raw/vagrant-packer-plugin/pkg/vagrant-packer-plugin-0.5.0.gem > ~/.vagrant.d/vagrant-packer-plugin-0.5.0.gem
vagrant plugin install ~/.vagrant.d/vagrant-packer-plugin-0.5.0.gem
```

## Use
Define the following `Vagrantfile` and run `vagrant up` from the same folder
```
Vagrant.configure("2") do |config|
  config.packer_build.instance_templates = ["instance1.json","instance2.json"]
  config.packer_build.ks_template = "https://raw.githubusercontent.com/Alfresco/alfresco-spk/master/ks/ks-centos.cfg"
end
```

Type `vagrant packer-build -h` for more info on configuration.

## Local testing
Build Vagrant Packer plugin locally
```
rm Gemfile.lock ; bundle ; rake build ; vagrant plugin install pkg/vagrant-packer-plugin-0.5.0.gem
```
