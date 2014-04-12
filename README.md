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

Using Packer.io
---

Commands to execute once on your box to configure Gems; you'll need to re-run them also if there are some changes applied to the Chef recipes you depend on
```
gem install bundler
bundle install
```

Commands to execute for each box build
```
bundle exec berks install --path vendor-cookbooks
packer build  -var 'aws_access_key=YOUR ACCESS KEY'  -var 'aws_secret_key=YOUR SECRET KEY' packer-allinone.json
```
