require 'spk/utils/packer_interface'

class SpkBuildImages
	def initialize(params, chef_items)
		@params = params
		@chef_items = chef_items
	end
	
	def execute!
		packer = PackerInterface.new(@params.work_dir)
		packer_defs = packer.get_defs(@chef_items)
		packer.run_defs(packer_defs, @params.packer_bin, @params.packer_opts, "packer.log")
    abort("Vagrant up build-images completed!")
	end
end