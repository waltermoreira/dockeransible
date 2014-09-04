#!/bin/bash

USAGE="\
build_app.sh <name>:         run playbook
build_app.sh commit <name>:  create image
"

usage() {
    echo "$USAGE"
}


start_ssh_server() {
    name=$1;
    state=$(docker inspect -f "{{ .State.Running }}" $name)
    if [ ! "$?" -eq 0 ]; then
        # No container with than name. Start one.
        docker run -d -P --name $name ssh_server
    elif [ "$state" == "false" ]; then
        # The container is stopped. Restart it.
        docker start $name;
    fi
    # Container running. Do nothing.
}


if [ "$#" -eq 0 -o "$1" == "-h" ]; then
    usage;
else
    start_ssh_server $1;
    docker run --rm ssh_server cat /etc/ssh/ssh_host_rsa_key > key
    chmod 0600 key
    docker run -it --rm \
        -v $(pwd)/roles:/build/roles \
        -v $(pwd)/key:/build/key \
        --link $1:target app_builder provision
    rm -rf key
fi
