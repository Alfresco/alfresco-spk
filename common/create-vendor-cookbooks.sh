#!/bin/bash

rm -Rf vendor-cookbooks

# Run berkshelf
# use ```bundle exec berks vendor vendor-cookbooks``` syntax as of Berkshelf 3 onwards
bundle exec berks install --path vendor-cookbooks
