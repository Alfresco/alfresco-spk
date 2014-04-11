vagrant-alfresco-boxes
================

A collection of [Vagrant](http://www.vagrantup.com) boxes built with with [chef-alfresco](https://github.com/maoo/chef-alfresco) and used by [vagrant-alfresco](https://github.com/maoo/vagrant-alfresco)

Preparing Boxes
======

* Checkout this project
* Install [Vagrant 1.3.5](http://docs.vagrantup.com/v2/installation/index.html) and [VirtualBox 4.3.2](https://www.virtualbox.org); please respect the exact mentioned versions

```
vagrant plugin install vagrant-berkshelf
vagrant plugin install vagrant-omnibus
vagrant plugin install vagrant-vb
```

To reset your local environment, run the following command

```
vagrant destroy -f && killall VBoxSVC && rm -Rf .vagrant *.lock
```

To run the box type

```
MVN_ALF_USERNAME=xxx MVN_ALF_PASSWORD=xxx vagrant up
```