#!/bin/bash

USAGE="\
build_app.sh <name> <group> <distro>:
  provision app 'name' from roles using vars form {host,group}_vars/'group'
  and base distribution 'distro'

build_app.sh update <name> <group>:
  update an already committed image by running the playbook and skipping
  any task with tag 'initial' (make sure to run 'commit' again to generate
  the updated image)

build_app.sh commit <name>:
  create image
"

usage() {
    echo "$USAGE"
}


start_ssh_server() {
    name=$1;
    distro=$2;
    state=$(docker inspect -f "{{ .State.Running }}" $name 2>/dev/null)
    if [ ! "$?" -eq 0 -o "$state" == "<no value>" ]; then
        # No container with than name. Start one.
        docker run -d -P --name $name ${distro}_ssh_server
    elif [ "$state" == "false" ]; then
        # The container is stopped. Restart it.
        docker start $name;
    fi
    # Container running. Do nothing.
}


start_image() {
    name=$1;
    docker run -d --entrypoint=sleep --name=$name $name infinity
    docker exec $name service ssh start
}


if [ "$#" -eq 0 -o "$1" == "-h" ]; then
    usage;
elif [ "$1" == "commit" ]; then
    # --- commit
    docker commit $2 $2
    docker rm -f $2
    (
        echo "FROM $2";
        cat Runfile
    ) | docker build -t $2 -
else
    # --- provision or update
    if [ "$1" == "update" ]; then
        task="update";
        name=$2;
        group=$3;
        start_image $name;
    else
        task="provision";
        name=$1
        group=$2
        start_ssh_server $name $3;
    fi
    docker exec $name cat /etc/ssh/ssh_host_rsa_key > key
    chmod 0600 key
    mkdir temp
    cp -LR $(pwd)/roles temp
    docker run -it --rm \
        -v $(pwd)/temp/roles:/build/roles \
        -v $(pwd)/host_vars:/build/host_vars \
        -v $(pwd)/group_vars:/build/group_vars \
        -v $(pwd)/key:/build/key \
        -v $(pwd)/Runfile:/build/Runfile \
        --link $name:target app_builder provision $group $task
    rm -rf key temp
fi
