require 'curb'

class Downloader
	def self.get(file, destination)
		file = Curl::Easy.get(file)
		file.on_body { |d| File.open(destination,'w+') {|f| f.write d } }
		file.perform
	end
end