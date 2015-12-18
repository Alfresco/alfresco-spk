require 'spk/commons/engine'
require 'spk/commons/params'
require 'erb'


module Vagrant
  module Spk
  	module Run
      class Command < Vagrant.plugin('2', :command)
      	def initialize(args, env)
      		hashed_args = {}
      		@engine = Vagrant::Spk::Commons::Engine.new
      		@params = Vagrant::Spk::Commons::Config.get_params(hashed_args)
      		@engine.create_work_dir(@params['work_dir'])
      	end

   			def execute
   				nodes = @engine.get_stack_template_nodes(@params['command'], @params['work_dir'], @params['stack_template'], @params['ks_template'])
			  	@engine.get_chef_items(nodes, @params['work_dir'], @params['command'], @params['cookbooks_url'], @params['databags_url'])

			  	@template = File.read("#{File.expand_path File.dirname(__FILE__)}/../../../files/vagrant-templates/Vagrantfile.erb")


			  	# To be templated and run
			  	File.open("#{@params['work_dir']}/Vagrantfile", "w") { |file| file.write(ERB.new(@template).result(binding)) }

			  	`cd #{@params['work_dir']} && vagrant up >> vagrant.log`
   			end
    	end	
  	end
  end
end
