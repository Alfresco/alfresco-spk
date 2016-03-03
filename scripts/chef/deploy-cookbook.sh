#!/bin/bash

# export MVN_REPO_CREDS_ID=my-repo-credentials-id
# export MVN_REPO_URL=http://artifacts.acme.com/nexus
# export GROUP_ID=my.acme.project

# Set one of the following variables
# export GIT_REPO="https://github.com/foo/bar.git"
# export ARTIFACT_ID="bar"

# Fixes issue https://github.com/berkshelf/berkshelf-api/issues/112
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

export PATH=/usr/local/packer:$HOME/.chefdk/gem/ruby/2.1.0/bin:/opt/chefdk/bin:/opt/chefdk/embedded/bin:$PATH

# If ARTIFACT_ID is not set, extract it from GIT_REPO
# Right now it only supports HTTP Git urls
if [ -z "$ARTIFACT_ID" ]; then
  export ARTIFACT_ID=`echo ${GIT_REPO%????} | cut -d "/" -f 5`
  echo "[deploy-cookbook.sh] Setting ARTIFACT_ID=$ARTIFACT_ID"
else
  echo "[deploy-cookbook.sh] ARTIFACT_ID=$ARTIFACT_ID"
fi

function buildArtifact () {
  if grep -L berkshelf gems.list; then
    gem install berkshelf
  fi

  if [ -s Berksfile ]; then
    echo "[deploy-cookbook.sh] Building Chef artifact with Berkshelf"
    rm -rf Berksfile.lock *.tar.gz; berks package berks-cookbooks.tar.gz
  elif [ -d data_bags ]; then
    echo "[deploy-cookbook.sh] Building Chef Databags artifact"
    rm -rf *.tar.gz; tar cfvz alfresco-databags.tar.gz ./data_bags
  fi
}

function getCurrentVersion () {
  version=`cat metadata.rb| grep version|awk '{print $2}' | tr -d \"`
  echo $version
}

function deploy () {
  echo "[deploy-cookbook.sh] Deploy $1"
  repo_name=$MVN_REPO_ID

  mvn deploy:deploy-file -Dfile=$(echo *.tar.gz) -DrepositoryId=$MVN_REPO_CREDS_ID -Durl=$MVN_REPO_URL/content/repositories/$repo_name -DgroupId=$GROUP_ID  -DartifactId=$ARTIFACT_ID -Dversion=$1 -Dpackaging=tar.gz
}

function run () {
  # Quit on failures
  set -e
  suffix=$1
  buildArtifact
  current_version=$(getCurrentVersion)
  deploy "$current_version$suffix"
}

suffix=$1
run $suffix
