require 'spk/commons/engine'
require 'erb'
class SpkRun
	def initialize(params)
		@params = params
	end
	
	def execute!
		template = File.read("#{File.expand_path File.dirname(__FILE__)}/../../../files/vagrant-templates/Vagrantfile.erb")
    # To be templated and run
    File.open("#{@params.work_dir}/Vagrantfile", "w") { |file| file.write(ERB.new(template).result(binding)) }

    `cd #{@params.work_dir} && vagrant up 2>&1`
    abort("Machine is up and running")
	end
end