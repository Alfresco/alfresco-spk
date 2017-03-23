#!/bin/bash

# You need to export GIT_REPO=git@github.com:YourAccount/YourProject.git before calling this script

function getCurrentVersion () {
  version=$(grep version metadata.rb | awk '{print $2}' | tr -d \'\”)
  echo $version
}

function run() {
  
  # Install github_changelog_generator gem
  gem list --no-installed github_changelog_generator &>> /dev/null
  if [ $? == 0 ]
  then
    PKG_CONFIG_PATH=/opt/chefdk/embedded/lib/pkgconfig gem install nokogiri
    gem install github_changelog_generator
  fi

  export VERSION=$(getCurrentVersion)

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
  if git tag -d "v$VERSION"
  then echo "Forced removal of local tag v$VERSION"
  fi

  echo "[pre-release-cookbook.sh] Tagging to $VERSION"
  git tag -a "v$VERSION" -m "releasing v$VERSION"
}

run
