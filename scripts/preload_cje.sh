#!/usr/bin/env bash

set -e

#ansible-playbook /vagrant/ansible/cje.yml -c local --extra-vars 'skip_licence=true'
ansible-playbook /vagrant/ansible/cje.yml -c local --extra-vars 'preload=true'

ansible-playbook /vagrant/ansible/node.yml -c local
