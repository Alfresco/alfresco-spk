class SpkBuildImages
	def initialize(params, engine, chef_items)
		@params = params
		@engine = engine
		@chef_items = chef_items
	end
	
	def execute!
		packer_defs = @engine.get_packer_defs("curl --no-sessionid --silent", @params.work_dir, @chef_items)
    @engine.run_packer_defs(packer_defs, @params.work_dir, @params.packer_bin, @params.packer_opts , "packer.log")
    abort("Vagrant up build-images completed!")
	end
end