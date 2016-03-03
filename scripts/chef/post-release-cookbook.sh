#!/bin/bash

function getCurrentVersion () {
  version=`cat metadata.rb| grep version|awk '{print $2}' | tr -d \"`
  echo $version
}

function getIncrementedVersion () {
  version=$(getCurrentVersion)
  echo $version | awk -F'[.]' '{print $1 "." $2 "." $3+1}'
}

function incrementVersion () {
  export currentVersion=$(getCurrentVersion)
  export nextVersion=$(getIncrementedVersion)

  echo "[post-release-cookbook.sh] Incrementing version from $currentVersion to $nextVersion"

  sed "s/$currentVersion/$nextVersion/" metadata.rb > metadata.rb.tmp
  rm -f metadata.rb
  mv metadata.rb.tmp metadata.rb

  # TODO - enable it when autoconf is installed
  if [ -n "$GIT_TOKEN" ]
  then
    echo "[post-release-cookbook.sh] Adding $currentVersion to CHANGELOG.md"
    github_changelog_generator -u Alfresco -p $GIT_PROJECT_NAME -t $GIT_TOKEN
    sed -i '/- Update /d' ./CHANGELOG.md
  fi
}

function run() {
  echo "[post-release-cookbook.sh] Pushing $(getCurrentVersion) tag to github (origin)"
  git push origin --tags
  incrementVersion
  echo "[post-release-cookbook.sh] Set new version ($(getCurrentVersion)) in metadata.rb"
  git stash
  git pull origin master
  git stash pop
  git add metadata.rb
  git add *.md
  git commit -m "Bumping version to v$(getCurrentVersion)"
  git push origin master
  echo "[post-release-cookbook.sh] Release completed!"
}

run
