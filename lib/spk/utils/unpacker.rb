require "rubygems/package"

class Unpacker
	def self.unpack(file, destination)
		puts "unpacking #{file} in #{destination}"
		File.open(file, "rb") do |file|
		  Gem::Package::TarReader.new(file) do |tar|
		    tar.each do |entry|
		      if entry.file?
		        FileUtils.mkdir_p(destination)
		        File.open("#{destination}/#{entry.full_name}", "wb") do |f|
		          f.write(entry.read)
		        end
		        File.chmod(entry.header.mode, entry.full_name)
		      end
		    end
		  end
		 end
	end
end