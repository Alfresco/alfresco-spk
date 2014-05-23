#!/bin/bash

rm -Rf vendor-cookbooks *.lock

# Run berkshelf
# use the following for Berkshelf 2 or earliear
# bundle exec berks install --path vendor-cookbooks
bundle exec berks vendor vendor-cookbooks
