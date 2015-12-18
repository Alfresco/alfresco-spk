module Vagrant
	module Spk
		module Commons
			class Config
				def self.get_params(custom_params)
				  params = {}
				  params['command'] = "curl --silent"
				  params['work_dir'] = custom_params[:work_dir] || "#{Dir.home}/.alfresco-spk/vagrant"

				  params['packer_bin'] = custom_params[:packer_bin] || 'packer'
				  params['packer_opts'] = custom_params[:packer_opts] || ''

				  params['box_url'] = custom_params[:vbox_url] || "http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_centos-7.1_chef-provisionerless.box"
				  params['box_name'] = custom_params[:vbox_name] || "opscode-centos-7.1"

				  params['cookbooks_url'] = custom_params[:cookbooks_url] || "https://artifacts.alfresco.com/nexus/service/local/repositories/releases/content/org/alfresco/devops/chef-alfresco/0.6.13/chef-alfresco-0.6.13.tar.gz"
				  params['databags_url'] = custom_params[:databags_url] || ''
				  params['stack_template'] = custom_params[:stack_template] || "file://#{File.expand_path File.dirname(__FILE__)}/../../../files/stack-templates/community-allinone.json"
				  params['ks_template'] = custom_params[:ks_template] || "file://#{File.expand_path File.dirname(__FILE__)}/../../../files/ks/ks-centos.cfg"
				  return params
				end
			end
		end
	end
end