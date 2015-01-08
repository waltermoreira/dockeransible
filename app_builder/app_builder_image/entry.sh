#!/bin/bash

USAGE="\
usage:

install: install app builder
"

USE_TARGET="\
No target directory.
Invoke docker as:

  docker run -v \$(pwd):/target app_builder install
"

INSTALLED="\
'build_app.sh' installed in current directory.

Run './build_app.sh -h' for help.
"

usage() {
    echo "$USAGE"
}


install() {
    if [ ! -d /target ]; then
        echo "$USE_TARGET"
    else
        cp /bin/build_app.sh /target
        echo "$INSTALLED"
    fi
}


construct_site_yml() {
    echo "\
---
- hosts: $1
  roles:" > /build/site.yml
    (
        cd /build/roles;
        for role in $(ls -d *); do
            echo "    - $role"
        done
    ) >> /build/site.yml;
}


construct_inventory() {
    (
        echo "[$1]"
        echo "$TARGET_PORT_22_TCP_ADDR ansible_ssh_private_key_file=/build/key"
    ) >> /build/hosts;
}


provision() {
    construct_inventory $1;
    construct_site_yml $1;
    ANSIBLE_HOST_KEY_CHECKING=false ansible-playbook -i /build/hosts /build/site.yml
    apt-get clean
    rm -rf /var/log/* /tmp/* /var/tmp/* /var/lib/apt/lists/*
}


if [ "$#" -eq 0 ]; then
    usage;
elif [ "$1" == "install" ]; then
    install;
elif [ "$1" == "provision" ]; then
    provision $2;
fi
