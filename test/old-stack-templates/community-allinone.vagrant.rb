# Testing Chef provisioning, before creating an immutable image
# To use it:
# VAGRANT_VAGRANTFILE=Vagrantfile.pre vagrant up
#
# -*- mode: ruby -*-
# vi: set ft=ruby :
#

instance_template_path = "../instance-templates/allinone-community.json"
cookbooks_url = "https://artifacts.alfresco.com/nexus/service/local/repositories/releases/content/org/alfresco/devops/chef-alfresco/0.6.20/chef-alfresco-0.6.20.tar.gz"
run_list = ["alfresco::default"]

Vagrant.configure("2") do |config|

  # Vagrant Packer Plugin configurations
  config.packer_build.instance_templates = ["./spk/build-vagrantbox.json"]
  config.packer_build.ks_template = "https://raw.githubusercontent.com/Alfresco/alfresco-spk/master/ks/ks-centos.cfg"

  # Source Image configuration
  config.vm.box = "centos-7.2"
  config.vm.box_url = "http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_centos-7.2_chef-provisionerless.box"

  # TODO - hacky replacement of https://www.vagrantup.com/docs/provisioning/chef_solo.html#recipe_url
  # doesn't work due to issues with file permissions on
  # /tmp/vagrant-chef/cookbooks folder, may be an issue with
  # the chef-alfresco tar.gz in Nexus
  config.vm.provision "shell",
    inline: "cd /tmp ; curl -L #{cookbooks_url} > cookbooks.tar.gz ; mkdir vagrant-chef ; rm -rf vagrant-chef/cookbooks ; tar xvzf cookbooks.tar.gz -C vagrant-chef"

  # Alfresco provisioning configurations
  instance_template = JSON.parse(IO.read(File.expand_path(instance_template_path, "#{__FILE__}/..")))

  # Set local configurations
  config.vm.hostname = instance_template['name']
  config.vm.network :private_network, ip: instance_template['_local']['ip']
  config.vm.provider "virtualbox" do |v|
    v.memory = instance_template['_local']['ram']
    v.cpus = instance_template['_local']['cpus']
  end

  config.vm.provision "chef_solo" do |chef|
    chef.json = instance_template
    run_list.each do |recipe|
      chef.add_recipe recipe
    end
  end
end
