
module VagrantPlugins
	module PackerBuild
		class Config < Vagrant.plugin(2, :config)
			attr_accessor :work_dir, :debug, :box_url, :box_name, :cookbooks_url, :databags_url, :instance_templates, :pre_commands, :post_commands, :env_vars, :ks_template, :why_run

			def initialize
				@work_dir = UNSET_VALUE
				@box_url = UNSET_VALUE
				@box_name = UNSET_VALUE
				@cookbooks_url = UNSET_VALUE
				@databags_url = UNSET_VALUE
				@pre_commands = UNSET_VALUE
				@post_commands = UNSET_VALUE
				@ks_template = UNSET_VALUE
				@env_vars = UNSET_VALUE
			end

			def finalize!
				@work_dir = "#{Dir.home}/.vagrant.d/data/packer-plugin" if @work_dir == UNSET_VALUE
				@box_url = 'http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_centos-7.2_chef-provisionerless.box' if @box_url == UNSET_VALUE
				@box_name = "opscode_centos-7.2" if @box_name == UNSET_VALUE
				@cookbooks_url = "./berks-cookbooks.tar.gz" if @cookbooks_url == UNSET_VALUE
				@databags_url = '' if @databags_url == UNSET_VALUE
				@pre_commands = "" if @pre_commands == UNSET_VALUE
				@post_commands = "" if @post_commands == UNSET_VALUE
				@ks_template = "" if @ks_template == UNSET_VALUE
				@env_vars = "" if @env_vars == UNSET_VALUE
			end
		end
	end
end
