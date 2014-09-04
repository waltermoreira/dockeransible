#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

apt-get -y update
apt-get install -y python python-dev python-pip git
pip install paramiko PyYAML jinja2 httplib2

git clone http://github.com/ansible/ansible.git /tmp/ansible
cd /tmp/ansible && python setup.py install

mkdir -p /build

apt-get clean
rm -rf /var/log/* /tmp/* /var/tmp/* /var/lib/apt/lists/*
