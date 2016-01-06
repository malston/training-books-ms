#!/usr/bin/env bash

set -e

ansible-playbook /vagrant/ansible/docker.yml -c local

docker pull cloudbees/training-books-ms-tests

docker tag -f cloudbees/training-books-ms-tests 10.100.198.200:5000/training-books-ms-tests

docker push 10.100.198.200:5000/training-books-ms-tests

set +e

git clone https://github.com/cloudbees/training-books-ms.git

set -e

cd training-books-ms

docker run -it --rm \
    -v $PWD/client/components:/source/client/components \
    -v $PWD/client/test:/source/client/test \
    -v $PWD/src:/source/src \
    -v $PWD/target/scala-2.10:/source/target/scala-2.10 \
    --env TEST_TYPE=all \
    10.100.198.200:5000/training-books-ms-tests

docker build -t 10.100.198.200:5000/books-ms .

docker push 10.100.198.200:5000/books-ms

docker pull mongo
