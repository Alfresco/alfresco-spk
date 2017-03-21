#!/bin/bash

runTests () {
  echo "[test-cookbook.sh] Running Chef, Foodcritic and ERB syntax check tests"

  gem_installer () {
    local gem=$1

    gem list --no-installed ${gem} &>> /dev/null
    if [ $? == 0 ]
    then
      gem install ${gem}
    fi
  }

  local gem
  for gem in foodcritic rails-erb-check jsonlint rubocop yaml-lint
  do
    gem_installer ${gem}
  done

  find . -not -path '*/\.*' -name "*.erb" -exec rails-erb-check {} \;
  find . -not -path '*/\.*' -name "*.json" -exec jsonlint {} \;
  find . -not -path '*/\.*' -name "*.rb" -exec ruby -c {} \;

  find . -not -path '*/\.*' -name "*.yml" -not -path "./.kitchen.yml" -exec yaml-lint {} \;
  knife cookbook test cookbook -o ./ -a
  foodcritic -f any .
  # Next one should use warning as fail-level, printing only the progress review
  rubocop --fail-level warn | sed -n 2p
}

runTests
