require 'bundler'

begin
  require 'vagrant'
rescue LoadError
  Bundler.require(:default, :development)
end

require 'spk/build-images/plugin'
require 'spk/build-images/command'

require 'spk/run/plugin'
require 'spk/run/command'
