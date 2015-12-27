module VagrantPlugins
  module Spk
    class Plugin < Vagrant.plugin('2')
      name "Spk"

      description <<-DESC
      Build or run and Alfresco SPK stack
      DESC

      config 'spk' do
        require_relative 'config'
        Config
      end

      command 'spk' do
        require_relative 'command'
        Command
      end
    end
  end
end