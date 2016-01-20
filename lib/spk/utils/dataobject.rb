module Packer
	class DataObject
    def __add_json(key, data, exclusives = [])
      self.__exclusive_key_error(key, exclusives)
      raise TypeError.new() unless data.is_a?(Hash)
      self.data[key.to_s] = {}
      data.keys.each do |k|
        self.data[key.to_s][k] = data[k]
      end
    end

    def add_splitted_variable(name, value)
      variables_copy = Marshal.load(Marshal.dump(self.variables))
      variables_copy[name.to_s] = value.to_s
      self.__add_hash('variables', variables_copy)
    end

  end
end