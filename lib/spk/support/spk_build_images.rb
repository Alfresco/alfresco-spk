require 'spk/utils/packer_interface'

class SpkBuildImages
	def initialize(params, engine, chef_items)
		@params = params
		@chef_items = chef_items
		@engine = engine
	end
	
	def execute!
		packer = PackerInterface.new(@params.work_dir, @engine)
		packer_defs = packer.get_defs(@chef_items)
		packer.run_defs(packer_defs, @params.packer_opts)
    abort("Vagrant up build-images completed!")
	end
end