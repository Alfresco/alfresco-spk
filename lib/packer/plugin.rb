module VagrantPlugins
  module Packer
    class Plugin < Vagrant.plugin('2')
      name "Packer"

      description <<-DESC
      
      DESC

      config 'packer' do
        require_relative 'config'
        Config
      end

      command 'packer' do
        require_relative 'command'
        Command
      end
    end
  end
end