#!/bin/bash

function getCurrentVersion () {
  version=`cat metadata.rb| grep version|awk '{print $2}' | tr -d \"`
  echo $version
}

function run() {
  export VERSION=$(getCurrentVersion)

  echo "[pre-release-cookbook.sh] Check if there's an old tag to remove"
  if git tag -d "v$VERSION"
  then echo "Forced removal of local tag v$VERSION"
  fi

  echo "[pre-release-cookbook.sh] Tagging to $VERSION"
  git tag -a "v$VERSION" -m "releasing v$VERSION"
}

run
