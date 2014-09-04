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


provision() {
    echo "will run ansible here";
}


if [ "$#" -eq 0 ]; then
    usage;
elif [ "$1" == "install" ]; then
    install;
elif [ "$1" == "provision" ]; then
    provision;
fi
