module Packer
  class Config < Packer::DataObject
  	def add_split_variable(name, value)
      variables_copy = Marshal.load(Marshal.dump(self.variables))
      variables_copy[name.to_s] = value
      self.__add_hash('variables', variables_copy)
    end
  end
 end