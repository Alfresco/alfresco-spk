vagrant-alfresco-boxes
================

A collection of [Vagrant](http://www.vagrantup.com) boxes built with with [chef-alfresco](https://github.com/maoo/chef-alfresco) and used by [vagrant-alfresco](https://github.com/maoo/vagrant-alfresco)

Preparing Boxes
======

* Checkout this project
* Install [Vagrant](http://docs.vagrantup.com/v2/installation/index.html) and [VirtualBox](https://www.virtualbox.org)
* From your commandline run:

```
vagrant plugin install vagrant-berkshelf
vagrant plugin install vagrant-omnibus
```

```
rm -Rf .vagrant.d
rm -Rf ~/.vagrant.d/boxes/alfresco-mysql-vb
ln -s Vagrantfile.mysql Vagrantfile
vagrant up
vagrant package --output alfresco-mysql-vb.box
vagrant destroy
```

The box binary can be found at [https://dl.dropboxusercontent.com/u/723955/boxes/alfresco-mysql-vb.box](https://dl.dropboxusercontent.com/u/723955/boxes/alfresco-mysql-vb.box)

```
rm -Rf .vagrant.d
rm -Rf ~/.vagrant.d/boxes/alfresco-web-vb
ln -s Vagrantfile.web Vagrantfile
vagrant up
vagrant package --output alfresco-web-vb.box
vagrant destroy
```

The box binary can be found at [https://dl.dropboxusercontent.com/u/723955/boxes/alfresco-web-vb.box](https://dl.dropboxusercontent.com/u/723955/boxes/alfresco-web-vb.box)

```
rm -Rf .vagrant.d
rm -Rf ~/.vagrant.d/boxes/alfresco-allinone-vb
ln -s Vagrantfile.allinone Vagrantfile
vagrant up
vagrant package --output alfresco-allinone-vb.box
vagrant destroy
```
The box binary can be found at [https://dl.dropboxusercontent.com/u/723955/boxes/alfresco-allinone-vb.box](https://dl.dropboxusercontent.com/u/723955/boxes/alfresco-allinone-vb.box)
