require_relative 'config'

require 'vagrant-packer-plugin/commons/engine'
require 'vagrant-packer-plugin/support/packer_build_images'
require 'vagrant-packer-plugin/support/packer_commands'

require 'berkshelf'
require 'optparse'
require 'fileutils'
module VagrantPlugins
  module PackerBuild
    class Command < Vagrant.plugin('2', :command)

      def initialize(args, env)
        @params = VagrantPlugins::PackerBuild::Config.new
        if env.vagrantfile.config.packer_build.is_a?(VagrantPlugins::PackerBuild::Config)
          @params = env.vagrantfile.config.packer_build
        end
      end

      def self.synopsis
        'Build immutable images using Packer'
      end

 			def execute
        OptionParser.new do |opts|
            opts.banner = "Usage: vagrant packer-build "\
                          "[-b|--box-url] "\
                          "[-n|--box-name] "\
                          "[-c|--cookbooks-url] "\
                          "[-d|--databags-url] "\
                          "[-k|--ks-template] "\
                          "[-B|--berksfile] "\
                          "[-i|--instance-templates] "\
                          "[-e|--pre-commands] "\
                          "[-o|--post-commands] "\
                          "[-v|--env-vars] "\
                          "[-D|--packer-debug] "\
                          "[-w|--why-run] "\
                          "[--env-vars] "

            opts.separator ""

            opts.on("-b", "--box-url [URL]", String, "Url of the template box for the virtual machine") do |box_url|
              @params.box_url = box_url
            end

            opts.on("-n", "--box-name [NAME]", String, "Name of the stack virtual machines") do |box_name|
              @params.box_name = box_name
            end

            opts.on("-c", "--cookbooks-url [URL]", String, "URL resolving Berkshelf (Cookbook repo) tar.gz archive") do |cookbooks_url|
              @params.cookbooks_url = cookbooks_url
            end

            opts.on("-d", "--databags-url [URL]", String, "URL resolving Chef databags tar.gz archive") do |databags_url|
              @params.databags_url = databags_url
            end

            opts.on("-k", "--ks-template [PATH]", String, "URL resolving the ks template for the machine (only used by Vagrant Box Image building)") do |ks_template|
              @params.ks_template = ks_template
            end

            opts.on("-B", "--berksfile [PATH]", String, "path resolving the Berksfile)") do |berksfile|
              @params.berksfile = berksfile
            end

            opts.on("-i", "--instance-templates [PATH1],[PATH2]", String, "URL resolving the instance templates") do |instance_templates|
              @params.instance_templates = instance_templates
            end

            opts.on("-e", "--pre-commands [PATHS]", String, "Comma-separated list of URLs resolving pre-commands JSON files") do |pre_commands|
              @params.pre_commands = pre_commands
            end

            opts.on("-o", "--post-commands [PATHS]", String, "Comma-separated list of URLs resolving post-commands JSON files") do |post_commands|
              @params.post_commands = post_commands
            end

            opts.on("-v", "--env-vars [PATHS]", String, "Comma-separated list of URLs resolving environment variables JSON files") do |env_vars|
              @params.env_vars = env_vars
            end

            opts.on("-D", "--packer-debug", "true, to run packer in debug mode; default is false") do |debug|
                @params.debug = debug
            end

            opts.on("-w", "--why-run", "Why run mode will just test configuration but will not run or build anything") do |why_run|
              @params.why_run = why_run
            end

        end.parse!


        #errors = validate
        #abort(errors.join("\n")) if errors.size > 0

        @params.finalize!


        # this code will be run only if the command wasn't asking for helpls
        @engine = VagrantPlugins::PackerBuild::Commons::Engine.new

        nodes = @engine.get_instance_templates(@params.work_dir, @params.instance_templates, @params.ks_template)

        # Delete Berksfile.lock, if present
        puts "[packer-info] Trying to delete local berksfile.lock"
        begin
          File.delete("#{Dir.pwd}/Berksfile.lock")
          puts "[packer-info] local Berksfile.lock removed!"
        rescue Errno::ENOENT
          puts "[packer-info] File not found, continuing normally.."
        end

        puts "[packer-info] Packaging berkshelf recipes..."

        Berkshelf::Cli.start(["package",@params.cookbooks_url.split('/')[-1]])
        # TODO - consider also params.berksfile, but not working yet
        # Berkshelf::Cli.start(["package",@params.cookbooks_url.split('/')[-1],"-b #{@params.berksfile}"])
        chef_items = @engine.get_chef_items(nodes, @params.work_dir, @params.cookbooks_url, @params.databags_url)

        env_vars_string = ""

        if @params.env_vars
          file_list = @params.env_vars.split(',')
          env_vars_final = []
          file_list.each do |file|
            env_vars_final << @engine.get_json(@params.work_dir, file.split('/')[-1], file)
          end
          env_vars_final.each do |vars|
            vars.each do |var|
              puts "VAR: #{var}"
              env_vars_string += "export " + var[0] + "=" + var[1] + "\n"
            end
          end
        end

        if !@params.why_run
          #Pre commands
          if @params.pre_commands
            file_list = @params.pre_commands.split(',')
            PackerCommands.new(@params, @engine, file_list, env_vars_string,  "pre").execute!
          end

          PackerBuildImages.new(@params, @engine, chef_items).execute!

          # Post Commands
          if @params.post_commands
            file_list = @params.post_commands.split(',')
            PackerCommands.new(@params, @engine, file_list, env_vars_string, "post").execute!
          end
        else
          abort("Why run mode selected - not continuing")
        end
 			end

      def validate
        errors = ""

        if @params.instance_templates.nil? or @params.instance_templates.empty?
          errors << "You must provide at least one instance template"
        end

        errors
      end
  	end

  end
end
