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

export PATH=/usr/local/packer:$(ruby -rubygems -e 'puts Gem.user_dir')/bin:$PATH

# If ARTIFACT_ID is not set, extract it from GIT_REPO
# Right now it only supports HTTP Git urls
if [ -z "$ARTIFACT_ID" ]; then
  export ARTIFACT_ID=`echo ${GIT_REPO%????} | cut -d "/" -f 5`
  echo "[deploy-cookbook.sh] Setting ARTIFACT_ID=$ARTIFACT_ID"
else
  echo "[deploy-cookbook.sh] ARTIFACT_ID=$ARTIFACT_ID"
fi

buildArtifact () {
    # Using a gem installed berks won't work, because of the dependencies.

#  gem_installer () {
#    local gem=$1

#    gem list --no-installed ${gem} &>> /dev/null
#    if [ $? == 0 ]
#    then
#      gem_user_install () { gem install --no-rdoc --no-ri --user-install $*; }
#      gem_user_install ${gem}
#    fi
#  }

#  # Coarse grained.
#  set +e
#  gem_installer berkshelf 
#  set -e

  # Ensure we're using system defined berks
  local __berks=/usr/bin/berks

  if [ -s Berksfile ]; then
    echo "[deploy-cookbook.sh] Building Chef artifact with Berkshelf"
    rm -rf Berksfile.lock *.tar.gz; ${__berks} package berks-cookbooks.tar.gz
  elif [ -d data_bags ]; then
    echo "[deploy-cookbook.sh] Building Chef Databags artifact"
    rm -rf *.tar.gz; tar cfvz alfresco-databags.tar.gz ./data_bags
  fi
}

getCurrentVersion () {
  local version=$(grep version metadata.rb | awk '{print $2}' | tr -d \'\")
  echo ${version}
}

deploy () {
  echo "[deploy-cookbook.sh] Deploy $1"
  local repo_name=$MVN_REPO_ID

  mvn deploy:deploy-file -Dfile=$(echo *.tar.gz) -DrepositoryId=$MVN_REPO_CREDS_ID -Durl=$MVN_REPO_URL/content/repositories/$repo_name -DgroupId=$GROUP_ID  -DartifactId=$ARTIFACT_ID -Dversion=$1 -Dpackaging=tar.gz
}

run () {
  # Quit on failures
  set -e
  local suffix=$1
  buildArtifact
  local current_version=$(getCurrentVersion)
  deploy "$current_version$suffix"
}

suffix=$1
run $suffix
