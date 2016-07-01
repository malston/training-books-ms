#!/bin/bash

set -e

echo "Installing Ansible..."
apt-get update -y
apt-get install -y build-essential libssl-dev libffi-dev python-dev python-pip maven
pip install ansible==1.9.3
mkdir -p /etc/ansible
touch /etc/ansible/hosts

# Uncomment to run java on slave without docker
# echo "Installing openjdk-8-jdk..."
# sudo add-apt-repository -y ppa:openjdk-r/ppa
# sudo apt-get update -y
# sudo apt-get install -y openjdk-8-jdk
# sudo update-alternatives --set java /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java
# sudo update-alternatives --set javac /usr/lib/jvm/java-8-openjdk-amd64/bin/javac
