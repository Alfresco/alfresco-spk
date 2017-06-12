#!/bin/bash

# You need to export GIT_REPO=git@github.com:YourAccount/YourProject.git before calling this script

export PATH=$(ruby -rubygems -e 'puts Gem.user_dir')/bin:$PATH

getCurrentVersion () {
  version=$(grep -w version metadata.rb | awk '{print $2}' | tr -d \'\")
  echo ${version}
}

run() {

  gem_installer () {
    local gem=$1

    gem list --no-installed ${gem} &>> /dev/null
    if [ $? == 0 ]
    then
      gem_user_install () { gem install --no-rdoc --no-ri --user-install $*; }
      gem_user_install ${gem}
    fi
  }
  # Install github_changelog_generator gem
  PKG_CONFIG_PATH=/opt/chefdk/embedded/lib/pkgconfig gem_installer nokogiri
  gem_installer github_changelog_generator

  export VERSION=$(getCurrentVersion)
  local V_VERSION=v${VERSION}

  export GIT_PREFIX=git@github.com
  export GIT_ACCOUNT_NAME=`echo ${GIT_REPO%????} | cut -d "/" -f 4`
  
  # If ARTIFACT_ID is not set, extract it from GIT_REPO
  # Right now it only supports HTTP Git urls
  if [ -z "$ARTIFACT_ID" ]; then
    export ARTIFACT_ID=`echo ${GIT_REPO%????} | cut -d "/" -f 5`
    echo "[pre-release-cookbook.sh] Setting ARTIFACT_ID=$ARTIFACT_ID"
  else
    echo "[pre-release-cookbook.sh] ARTIFACT_ID=$ARTIFACT_ID"
  fi

  if [ -z "$GIT_PROJECT_NAME" ]; then
    export GIT_PROJECT_NAME=$ARTIFACT_ID
    echo "[pre-release-cookbook.sh] Setting GIT_PROJECT_NAME=$ARTIFACT_ID"
  else
    echo "[pre-release-cookbook.sh] GIT_PROJECT_NAME=$ARTIFACT_ID"
  fi
  
  echo "[pre-release-cookbook.sh] Setting git remote to $GIT_PREFIX:$GIT_ACCOUNT_NAME/$GIT_PROJECT_NAME.git"
  git remote set-url origin $GIT_PREFIX:$GIT_ACCOUNT_NAME/$GIT_PROJECT_NAME.git

  echo "[pre-release-cookbook.sh] Check if there's an old tag to remove"
  git tag -d "${V_VERSION}"
  [[ $? == 0 ]] && echo "Forced removal of local tag ${V_VERSION}"

  echo "[pre-release-cookbook.sh] Tagging to ${VERSION}"
  git tag -a "${V_VERSION}" -m "releasing ${V_VERSION}"
}

run
