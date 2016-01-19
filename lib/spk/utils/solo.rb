require 'packer-config'
require 'spk/utils/dataobject'


module Packer
  class Provisioner < Packer::DataObject
    class Chef < Provisioner
      class Solo < Chef
      	def initialize
      		super
      		self.data['type'] = CHEF_SOLO
          self.add_required([])
      	end

      	def json(hash)
          self.__add_json('json', hash)
        end

      end
    end
  end
end