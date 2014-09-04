#!/bin/bash

USAGE="\
build_app.sh <name>:         run playbook
build_app.sh commit <name>:  create image
"

usage() {
    echo "$USAGE"
}

if [ "$#" -eq 0 -o "$1" == "-h" ]; then
    usage;
else
    docker run -d -P --name $1 ssh_server
    docker run ssh_server cat /etc/ssh/ssh_host_rsa_key > key
    docker run -it -v $(pwd):/build/roles --link $1:target app_builder provision
fi
