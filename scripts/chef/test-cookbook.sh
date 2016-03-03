#!/bin/bash

function runTests () {
  echo "[test-cookbook.sh] Running Chef, Foodcritic and ERB syntax check tests"

  gem list > gems.list

  if grep -L foodcritic gems.list; then
    gem install foodcritic
  fi
  if grep -L rails-erb-check gems.list; then
    gem install rails-erb-check
  fi
  if grep -L jsonlint gems.list; then
    gem install jsonlint
  fi
  if grep -L rubocop gems.list; then
    gem install rubocop
  fi

  #if grep -L yaml-lint gems.list; then
    gem install yaml-lint
  #fi

  find . -name "*.erb" -exec rails-erb-check {} \;
  find . -name "*.json" -exec jsonlint {} \;
  find . -name "*.rb" -exec ruby -c {} \;

  find . -name "*.yml" -not -path "./.kitchen.yml" -exec yaml-lint {} \;
  knife cookbook test cookbook -o ./ -a
  foodcritic -f any .
  # Next one should use warning as fail-level, printing only the progress review
  rubocop --fail-level warn | sed -n 2p
  rm -rf gems.list
}

runTests
