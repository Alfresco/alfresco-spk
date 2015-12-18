module Vagrant
    module Spk
      module BuildImages
        class Plugin < Vagrant.plugin('2')
          name "Spk Build"

          description "This plugin build alfresco images"

          command 'spk-build-images' do
            require_relative 'command'
            Command
          end
        end
      end
    end
end
