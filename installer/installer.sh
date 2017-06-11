#!/usr/bin/env bash

function print_error() {
    echo -e "\033[31;1mError:\x1b[0m $@"
}

function print_warning() {
    echo -e "\033[33mWarning:\x1b[0m $@"
}

function print_message() {
    echo -en "[\033[32m"
    printf "%10s" "installer"
    echo -e "\x1b[0m] $@"
}

function fix_hgrc() {
    hgrc="$1/.hg/hgrc"
    repo_name="$2"
    cat >$hgrc <<EOF
[paths]
default = /home/mvel/work/$repo_name
dmvn = ssh://dmvn.net//srv/hg/$repo_name
bb = ssh://hg@bitbucket.org/dichlofos/$repo_name

[ui]
username = Mikhail Veltishchev <dichlofos-mv@yandex.ru>
EOF
}

function deploy_service() {
    service_name="$1"
    target_server="$2"
    mode="$3"
    if [ -z "$mode" ] ; then
        print_error "Empty mode specified"
        return 1
    fi

    work_dir="$HOME/deploy/$1"

    # prepare repo on remote
    ssh $target_server bash -xe <<EOF
        rm -rf $work_dir
        mkdir -p $work_dir
EOF
    scp bootstrap.sh $target_server:$work_dir/
    ssh $target_server bash -xe <<EOF
        cd $work_dir
        bash ./bootstrap.sh "sources"
        cd sources
        ls -la
        echo "see deploy script to enable real deploy"
        sudo ./install.sh $mode
EOF

}

unalias grep 2>/dev/null || true
