#!/bin/bash

# Install Vagrant Plugins
vagrant plugin install vagrant-berkshelf
vagrant plugin install vagrant-omnibus
vagrant plugin install vagrant-vbguest

# Install Bundler Gem and run berkshelf
bundle exec berks install --path vendor-cookbooks
gem install bundler
bundle install