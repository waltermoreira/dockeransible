#!/bin/bash

ansible-playbook -i /build/hosts -c local /build/ansible/site.yml

apt-get clean
rm -rf /var/log/* /tmp/* /var/tmp/* /var/lib/apt/lists/*
