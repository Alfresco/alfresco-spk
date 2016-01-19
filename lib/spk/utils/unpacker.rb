#This class manage unpacking formats
#Since the formats are many (and not only tar), this class is expected to be a good target for refactoring in metaprogramming
#End of this class should be something like Unpacker.send("#{format}", file)

require "rubygems/package"
require 'zlib'


class Unpacker
	TAR_LONGLINK = '././@LongLink'
	def self.tar(file, destination)
		puts "[spk-info] unpacking #{file} to #{destination}"
		Gem::Package::TarReader.new( Zlib::GzipReader.open "#{destination}/#{file}" ) do |tar|
		  dest = nil
		  tar.each do |entry|
		    if entry.full_name == TAR_LONGLINK
		      dest = File.join destination, entry.read.strip
		      next
		    end
		    dest ||= File.join destination, entry.full_name
		    if entry.directory?
		      File.delete dest if File.file? dest
		      FileUtils.mkdir_p dest, :mode => entry.header.mode, :verbose => false
		    elsif entry.file?
		      FileUtils.rm_rf dest if File.directory? dest
		      File.open dest, "wb" do |f|
		        f.print entry.read
		      end
		      FileUtils.chmod entry.header.mode, dest, :verbose => false
		    elsif entry.header.typeflag == '2' #Symlink!
		      File.symlink entry.header.linkname, dest
		    end
		    dest = nil
		  end
		end
	end
end