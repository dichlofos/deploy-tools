#!/usr/bin/env bash

# Commonly used installer routines
# Author: Mikhail Veltishchev <dichlofos-mv@yandex.ru>

# Please obey PEP8:
# Exactly 2 lines between functions
# Variable names are with_underscores


function print_error() {
    # Error message printer
    echo -e "\033[31;1mError:\x1b[0m $@"
}


function print_warning() {
    # Warning message printer
    echo -e "\033[33mWarning:\x1b[0m $@"
}


function print_message() {
    # Generic info message printer
    echo -en "[\033[32m"
    printf "%10s" "installer"
    echo -e "\x1b[0m] $@"
}


function fix_hgrc() {
    repo_path="$1"
    repo_name="$2"
    if [ -z "$repo_path" ] ; then
        print_error "Usage: fix_hgrc <repo_path> <repo_name>"
        return 1
    fi

    if [ -z "$repo_name" ] ; then
        print_error "Usage: fix_hgrc <repo_path> <repo_name>"
        return 1
    fi

    hgrc="$repo_path/.hg/hgrc"
    cat >$hgrc <<EOF
[paths]
default = /home/mvel/work/$repo_name
dmvn = ssh://dmvn.net//srv/hg/$repo_name
bb = ssh://hg@bitbucket.org/dichlofos/$repo_name

[ui]
username = Mikhail Veltishchev <dichlofos-mv@yandex.ru>
EOF
    cat $hgrc
}


function xcms_git_version() {
    # Calculates unique string that identifies GIT repo (reflecting local changes too)

    if ! [ -d ".git" ] ; then
        print_error "$(pwd) is not a GIT repo root"
        return 1
    fi

    git_branch="$( git symbolic-ref HEAD | sed -e s:refs/heads/:: )"
    git_version="$( git rev-list --all | wc -l )"

    # to flush CSS cache each time it deploys
    local_status="$( git status | sha256sum - | cut -c1-4 )"
    local_diff="$( git diff | sha256sum - | cut -c5-8 )"

    echo $git_branch-r$git_version-$local_status-$local_diff
}


function xcms_version_css() {
    # Creates a copy of CSS files under directory named as site version.
    # Usage: xcms_version_css <destination_dir> <relatiive_path>
    # e.g. xcms_version_css /var/www/site_root engine

    destination_dir="$1"
    css_root_dir="$destination_dir/$2"
    if ! [ -d "$css_root_dir" ] ; then
        return 0
    fi

    version="$( cat $destination_dir/version )"
    print_message "    Processing '$css_root_dir' to version '$version' ..."

    (
        cd "$css_root_dir"
        css_dirs="$( find . -type d -name 'css' )"
        for d in $css_dirs ; do (
            $sudo_mode rm -rf "$d/$version"
            cd "$d"
            $sudo_mode ln -sf . "$version"
        ) done
    )
}


function deploy_service() {
    service_name="$1"
    target_server="$2"
    mode="$3"
    sudo_mode="$4"

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
        sudo_mode=$sudo_mode $sudo_mode ./install.sh $mode
EOF

}

unalias grep 2>/dev/null || true
