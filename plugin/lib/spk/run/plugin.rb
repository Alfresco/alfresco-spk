module VagrantPlugins
    module Spk
      module Run
        class Plugin < Vagrant.plugin('2')
          name "Spk Run"

          description <<-DESC
          This plugin start alfresco 
          DESC

          config 'spk-run' do
            require_relative 'config'
            Config
          end

          command 'spk-run' do
            require_relative 'command'
            Command
          end
        end
      end
    end
end