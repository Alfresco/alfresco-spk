#!/bin/bash

# Install Bundler Gem and run berkshelf
gem install bundler
bundle install
bundle exec berks install --path vendor-cookbooks

# Install Vagrant Plugins
vagrant plugin install vagrant-omnibus
vagrant plugin install vagrant-vbguest
vagrant plugin install vagrant-hosts
