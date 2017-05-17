#!/usr/bin/env bash

deploy_service() {

    service_name="$1"
    target_server="$2"
    mode="$3"

    work_dir="$HOME/deploy/$1"

    # prepare repo on remote
    ssh $target_server bash -xe <<EOF
        rm -rf $work_dir
        mkdir -p $work_dir
EOF
    scp -v bootstrap.sh $target_server:$work_dir/
    ssh $target_server bash -xe <<EOF
        cd $work_dir
        bash ./bootstrap.sh
        # sudo ./install.sh $mode
EOF

}
