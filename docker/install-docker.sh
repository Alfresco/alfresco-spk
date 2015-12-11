#!/bin/bash

# tee /etc/yum.repos.d/docker.repo <<-'EOF'
# [dockerrepo]
# name=Docker Repository
# baseurl=https://yum.dockerproject.org/repo/main/centos/$releasever/
# enabled=1
# gpgcheck=1
# gpgkey=https://yum.dockerproject.org/gpg
# EOF
#
# #Installing Docker
# yum -y install docker-engine

curl -sSL https://get.docker.com/ | sh

service docker start
