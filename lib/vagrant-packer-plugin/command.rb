require_relative 'config'

require 'vagrant-packer-plugin/utils/downloader'
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
                          "[-D|--packer-debug] "\
                          "[-w|--why-run] "

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

            opts.on("-D", "--packer-debug", "true, to run packer in debug mode; default is false") do |debug|
                @params.debug = debug
            end

            opts.on("-w", "--why-run", "Why run mode will just test configuration but will not run or build anything") do |why_run|
              @params.why_run = why_run
            end
        end.parse!

        @params.finalize!

        # this code will be run only if the command wasn't asking for helpls
        @engine = VagrantPlugins::PackerBuild::Commons::Engine.new
        @engine.create_work_dir(@params.work_dir)

        if @params.ks_template
          Downloader.get(@params.ks_template, "#{@params.work_dir}/ks.cfg" )
        end

        # Invoke Berkshelf, if Berksfile is configured
        if @params.berksfile
          @engine.invoke_berkshelf(@params.work_dir, "cookbooks")
        end

        # Download Chef cookbooks via URL or path
        if @params.cookbooks_url
          @engine.get_artifact(@params.work_dir, @params.cookbooks_url, "cookbooks")
        end

        # Download Chef databags via URL or path
        if @params.databags_url
          @engine.get_artifact(@params.work_dir, @params.databags_url, "databags", @params)
        end

        # TODO - why saving attributes in single files if we have the instance-template nodes that have it all?
        # if @params.berksfile || @params.cookbooks_url
        #   chef_items = @engine.get_chef_items(nodes, @params.work_dir, @params.cookbooks_url, @params.databags_url)
        # end

        if !@params.why_run
          nodes = @engine.get_instance_templates(@params.work_dir, @params.instance_templates)
          PackerBuildImages.new(@params, @engine, nodes).execute!
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
