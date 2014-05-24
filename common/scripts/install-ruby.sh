#!/bin/bash
. /tmp/common.sh

# kernel source is needed for vbox additions
if [ -f /etc/redhat-release ] ; then
    $yum install ruby
elif [ -f /etc/debian_version ] ; then
    $apt remove libruby1.8 ruby1.8 ruby1.8-dev rubygems1.8
    $apt install ruby
fi