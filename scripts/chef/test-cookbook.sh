#!/bin/bash

runTests () {
  echo "[test-cookbook.sh] Running Chef, Foodcritic and ERB syntax check tests"

  local __rbenv_version_stash
  check_ruby () {
    # Nasty hack - I can't get kitchen working with 2.3.1
    # Where is ruby version defined
    local __version_origin=$(rbenv version-origin)
    [[ -z "${__version_origin}" ]] && echo 'rbenv broken' && exit 1
    if [ ${__version_origin} == "$(rbenv root)/version" ]
    then
      # Global Ruby Version
      __rbenv_version_stash='global'
    else
      # Local Ruby Version
      __rbenv_version_stash=$(rbenv version-name)
    fi

    # Here it is: forcing 2.2.0
    rbenv local 2.2.0
    export PATH=$(ruby -rubygems -e 'puts Gem.user_dir')/bin:$PATH
  }

  # Put ruby back to its original state
  reset_ruby () {
    if [ ${__rbenv_version_stash} == 'global' ]
    then
      rbenv global
    else
      rbenv local ${__rbenv_version_stash}
    fi
  }

  gem_installer () {
    local gem=$1

    gem list --no-installed ${gem} &>> /dev/null
    if [ $? == 0 ]
    then
      gem_user_install () { gem install --no-rdoc --no-ri --user-install $*; }
      gem_user_install ${gem}
    fi
  }

  check_ruby

  local gem
  for gem in foodcritic rails-erb-check jsonlint rubocop yaml-lint chef
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

  reset_ruby
}

runTests
