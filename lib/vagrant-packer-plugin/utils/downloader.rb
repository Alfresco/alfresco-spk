require 'open-uri'
require 'openssl'

class Downloader
	def self.get(file, destination, params=nil)
		if params.nil? or params.databags_username.nil?
			file = file.gsub("file://", "")
			file_path = file.gsub("$PWD", "#{Dir.pwd}")
			puts "[packer-build] #{file_path} to #{destination}"
			open(file_path) {|f|
			   File.open(destination,"wb") do |file|
			     file.puts f.read
			   end
			}
		else
			self.get_with_auth(file, destination, params.databags_username, params.databags_password)
		end
	end

	def self.get_with_auth(file, destination,user, password)
		puts "[packer-build] retrieving with authentication"
		file = file.gsub("file://", "")
		file_path = file.gsub("$PWD", "#{Dir.pwd}")
		puts "[packer-build] #{file_path} to #{destination}"
		open(file_path, :http_basic_authentication => [user, password], :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE) {|f|
			File.open(destination,"wb") do |file|
				file.puts f.read
			end
		}
	end

end
