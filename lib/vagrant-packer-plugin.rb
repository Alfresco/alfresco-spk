require 'bundler'

begin
  require 'vagrant'
rescue LoadError
  Bundler.require(:default, :development)
end

require 'vagrant-packer-plugin/plugin'
require 'vagrant-packer-plugin/command'