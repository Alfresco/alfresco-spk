# Alfresco SPK Vagrantfile
#
# -*- mode: ruby -*-
# vi: set ft=ruby :
require_relative 'scripts/provisioning-libs'

vagrantCommand = ARGV[0]
vagrantImagesParam = ARGV[1]
vagrantUpOrProvision = ['up','provision'].include? vagrantCommand

print "Vagrant command: '#{vagrantCommand}'\n"
print "Vagrant image command: '#{vagrantImagesParam}'\n"

params = getEnvParams()
initWorkDir(params['workDir'])
nodes = getStackTemplateNodes(params['downloadCmd'], params['workDir'], params['stackTemplateUrl'])

if vagrantImagesParam == 'images'
  downloadChefItems(nodes, params['workDir'], params['downloadCmd'], params['cookbooksUrl'], params['dataBagsUrl'])
  packerDefs = getPackerDefinitions(params['downloadCmd'], params['workDir'], nodes)
  runPackerDefinitions(packerDefs, params['workDir'], params['packerBin'], params['packerOpts'], "packer.log")
  abort("Vagrant up images completed!")
else
  if vagrantUpOrProvision
    downloadChefItems(nodes, params['workDir'], params['downloadCmd'], params['cookbooksUrl'], params['dataBagsUrl'])
  end

  Vagrant.configure("2") do |config|
    nodes.each do |chefNodeName,chefNode|
      config.vm.define chefNodeName do |machineConfig|

        if vagrantUpOrProvision
          machineConfig.vm.synced_folder ".", "/vagrant", mount_options: ["dmode=777", "fmode=666"]

          boxAttributes = getNodeAttributes(params['workDir'], chefNodeName)

          boxIp = chefNode['local-run']['ip']
          boxHostname = boxAttributes["hostname"] || boxAttributes["name"]
          boxRunList = boxAttributes["run_list"]

          if boxIp
            machineConfig.vm.network :private_network, ip:  boxIp
          end
          machineConfig.vm.hostname = boxHostname
        end

        machineConfig.vm.provider :virtualbox do |vb,override|
          override.vm.box_url = params['vagrantBoxUrl']
          override.vm.box = params['boxName']
          vb.customize ["modifyvm", :id, "--memory", chefNode['local-run']['memory']]
          vb.customize ["modifyvm", :id, "--cpus", chefNode['local-run']['cpus']]
        end

        if vagrantUpOrProvision
          # Chef run configuration
          machineConfig.vm.provision :chef_solo do |chef|
            chef.cookbooks_path = "#{params['workDir']}/cookbooks"
            chef.data_bags_path = "#{params['workDir']}/data_bags"

            boxRunList.each do |recipe|
              chef.add_recipe "recipe[#{recipe}]"
            end

            chef.json = boxAttributes
          end
        end
      end
    end
  end
end
