require 'spk/commons/engine'
require 'erb'
require 'optparse'
require_relative 'config'
require 'pry'


module VagrantPlugins
  module Spk
    class Command < Vagrant.plugin('2', :command)

      def initialize(args, env)
        @params = VagrantPlugins::Spk::Config.new
        @params.mode = args[0]
      end

      def self.synopsis
        'run or build an Alfresco SPK stack'
      end

 			def execute

        OptionParser.new do |opts|
            opts.banner = "Usage: vagrant spk [build-images|run] "\
                          "[-b|--box-url] "\
                          "[-n|--box-name] "\
                          "[-c|--cookbooks-url] "\
                          "[-d|--databags-url] "\
                          "[-k|--ks-template] "\
                          "[-s|--stack-template] "
            opts.separator ""

            opts.on("-b", "--box-url [URL]", String, "Url of the template box for the virtual machine") do |box_url|
              @params.box_url = box_url
            end

            opts.on("-n", "--box-name [NAME]", String, "Name of the stack virtual machines") do |box_name|
              @params.box_name = box_name
            end

            opts.on("-c", "--cookbooks-url [URL]", String, "Url of the chef recipes to be run on the machine") do |cookbooks_url|
              @params.cookbooks_url = cookbooks_url
            end

            opts.on("-d", "--databags-url [URL]", String, "Url of the databags to be applied to the chef run of the machine") do |databags_url|
              @params.databags_url = databags_url
            end

            opts.on("-k", "--ks-template [PATH]", String, "Path of the ks template for the machine") do |ks_template|
              @params.ks_template = ks_template
            end

            opts.on("-s", "--stack-template [PATH]", String, "Path of the SPK stack template") do |stack_template|
              @params.stack_template = stack_template
            end

            opts.on("-pre", "--pre-commands [PATH]", String, "Path of the pre commands JSON") do |pre_commands|
              @params.pre_commands = pre_commands
            end

            opts.on("-post", "--post-commands [PATH]", String, "Path of the post commands JSON") do |post_commands|
              @params.post_commands = post_commands
            end

        end.parse!
        @params.finalize!

        # this code will be run only if the command wasn't asking for help

        @engine = VagrantPlugins::Spk::Commons::Engine.new

        # this needs refactoring. every case needs it's own class
        case @params.mode
        when "build-images"
          @engine.create_work_dir(@params.work_dir)
          nodes = @engine.get_stack_template_nodes(@params.command, @params.work_dir, @params.stack_template, @params.ks_template)

          if @params.pre_commands
            file_list = @params.pre_commands.split(',')
            pre_commands_final = []
            file_list.each do |file|
              pre_commands_final << @engine.get_json(@params.command,@params.work_dir, file.split('/')[-1], file)
            end
          end

          if @params.post_commands
            file_list = @params.post_commands.split(',')
            post_commands_final = []
            file_list.each do |file|
              post_commands_final << @engine.get_json(@params.command,@params.work_dir, file.split('/')[-1], file)
            end
          end

          chef_items = @engine.get_chef_items(nodes, @params.work_dir, @params.command, @params.cookbooks_url, @params.databags_url)
          packer_defs = @engine.get_packer_defs("curl --no-sessionid --silent", @params.work_dir, chef_items)
          @engine.run_packer_defs(packer_defs, @params.work_dir, @params.packer_bin, @params.packer_opts , "packer.log")
          abort("Vagrant up build-images completed!")
        when "run"
          @engine.create_work_dir(@params.work_dir)
          nodes = @engine.get_stack_template_nodes(@params.command, @params.work_dir, @params.stack_template, @params.ks_template)
          chef_items = @engine.get_chef_items(nodes, @params.work_dir, @params.command, @params.cookbooks_url, @params.databags_url)
          @template = File.read("#{File.expand_path File.dirname(__FILE__)}/../../files/vagrant-templates/Vagrantfile.erb")
          # To be templated and run
          File.open("#{@params.work_dir}/Vagrantfile", "w") { |file| file.write(ERB.new(@template).result(binding)) }

          `cd #{@params.work_dir} && vagrant up >> vagrant.log`
          abort("Machine is up and running")
        else
          abort("You need to specify if you want to build or run")
        end
        # code that runs spk build

 			end
  	end

  end
end
