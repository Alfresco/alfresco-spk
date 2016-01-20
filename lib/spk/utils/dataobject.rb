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

  end
end