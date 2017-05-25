#!/usr/bin/env bash

repo_name="$1"
if [ -z "$repo_name" ] ; then
    echo "Usage: $0 <repo-name>"
    exit 1
fi

sudo mkdir $repo_name
cd $repo_name
hg init
cd ..
sudo chmod g+ws -R "$repo_name"
# FIXME: Unhardcode group
sudo chgrp lesh -R "$repo_name"
