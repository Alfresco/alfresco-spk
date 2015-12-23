require 'spk/commons/engine'

module VagrantPlugins
    module Spk
    	module BuildImages
	        class Command < Vagrant.plugin('2', :command)

	        	#Initialize engine and environment before the execution of the image building
	        	def initialize(args, env)
	        		@engine = VagrantPlugins::Spk::Commons::Engine.new
	        		@params = VagrantPlugins::Spk::Run::Config.new
		          @params.finalize!
	        		@engine.create_work_dir(@params.work_dir)
	        	end

	        	def self.synopsis
	        		'build an SPK stack'
	        	end

	        	# Start building the image
	        	# 1. parse the stack template to retrieve it's nodes
	        	# 2. get the remote cookbooks from nexus
	        	# 3. parse and get the packer definitions e.g. provider, provisioners and builders
	        	# 4. run packer definitions inside an image
		   			def execute
					  	nodes = @engine.get_stack_template_nodes(@params.command, @params.work_dir, @params.stack_template, @params.ks_template)
					  	chef_items = @engine.get_chef_items(nodes, @params.work_dir, @params.command, @params.cookbooks_url, @params.databags_url)
					  	packer_defs = @engine.get_packer_defs("cat", @params.work_dir, chef_items)
					  	@engine.run_packer_defs(packer_defs, @params.work_dir, @params.packer_bin, @params.packer_opts , "packer.log")
					  	#abort("Vagrant up build-images completed!")
		   			end
	        end	
    	end
    end
end