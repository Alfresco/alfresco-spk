require 'bundler'

begin
  require 'vagrant'
rescue LoadError
  Bundler.require(:default, :development)
end

require 'packer_build/plugin'
require 'packer_build/command'