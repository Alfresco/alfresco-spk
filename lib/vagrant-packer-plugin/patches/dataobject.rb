module Packer
	class DataObject
		def __add_array_of_strings(key, values, exclusives = [])
      self.__exclusive_key_error(key, exclusives)
      if Array.try_convert(values)
				#adding var as array of string - #{key.to_s}=#{values.to_ary.map(&:to_s)}
      	self.data[key.to_s] = values.to_ary.map(&:to_s)
			else
				#adding var as string - #{key.to_s}=#{values}"
				self.data[key.to_s] = values
			end
    end
  end
end