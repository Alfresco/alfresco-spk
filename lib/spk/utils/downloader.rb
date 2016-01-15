require 'open-uri'

class Downloader
	def self.get(file, destination)
		file = file.gsub("file://", "")
		file_path = file.gsub("$PWD", "#{Dir.pwd}")
		puts "#{file_path} to #{destination}"
		open(file_path) {|f|
		   File.open(destination,"wb") do |file|
		     file.puts f.read
		   end
		}
	end
end