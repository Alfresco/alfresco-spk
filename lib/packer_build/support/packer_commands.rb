class PackerCommands
	
	def initialize(params, engine, file_list, env_vars, mode)
		@params = params
		@engine = engine
		@file_list = file_list
		@env_vars = env_vars
		@mode = mode
	end



	def execute!
		  validate
      commands_final = []
      @file_list.each { |file| commands_final << @engine.get_json(@params.work_dir, file.split('/')[-1], file) }

      command_sh = @env_vars
      commands_final.each do |commands|
        commands.each do |command|
          puts "[packer-#{@mode}] #{command[0]}"
          puts "[packer-#{@mode}] DEBUG: #{command[1]}"
          command_sh += command[1] + "\n"
        end
      end
      command_file = "/tmp/#{@mode}-commands.sh"
      File.open(command_file, 'w') { |file| file.write(command_sh) }
      FileUtils.chmod(0755, command_file);
      stdout, stderr, status = Open3.capture3(command_file)
      puts "[packer-#{@mode}] RET: #{status}, ERR: #{stderr}, OUT: #{stdout}"
	end
	

	private

	def validate
		raise ArgumentError.new("Params should be an instance of VagrantPlugins::PackerBuild::Config") if !@params.is_a?(VagrantPlugins::PackerBuild::Config)
		raise ArgumentError.new("Engine should be an instance of VagrantPlugins::PackerBuild::Commons::Engine") if !@engine.is_a?(VagrantPlugins::PackerBuild::Commons::Engine)
		raise ArgumentError.new("File list needs to be an Array, and cannot be empty") if !@file_list.is_a?(Array) or @file_list.empty?
		raise ArgumentError.new("Environment variables should be a string and cannot be empty") if !@env_vars.is_a?(String)
		raise ArgumentError.new("Mode should be either pre or post") if !["pre","post"].include?(@mode)
	end


end