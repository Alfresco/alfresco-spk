module VagrantPlugins
  module PackerBuild
    class Plugin < Vagrant.plugin('2')
      name "vagrant-packer-plugin"

      description <<-DESC
      
      DESC

      config 'packer_build' do
        require_relative 'config'
        Config
      end

      command 'packer-build' do
        require_relative 'command'
        Command
      end
    end
  end
end