#!/bin/bash

set -e

echo "Installing Ansible..."
apt-get update -y
apt-get install -y build-essential libssl-dev libffi-dev python-dev python-pip
pip install ansible==1.9.3
mkdir -p /etc/ansible
touch /etc/ansible/hosts
