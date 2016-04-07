EC2 Setup
=========

Requirements
------------

* Linux or OS X
* Ansible
* AWS Access Key ID, AWS Secret Access Key, and AWS PEM

Preparation
-----------

```bash
cd ansible

sudo pip install passlib

PASS=$(python -c "from passlib.hash import sha512_crypt; import getpass; print sha512_crypt.encrypt(getpass.getpass())") # Use cb as password

export INSTANCES=1
export AWS_ACCESS_KEY_ID='[YOUR_ACCESS_KEY_ID]'
export AWS_SECRET_ACCESS_KEY='[YOUR_SECRET_ACCESS_KEY]'
export PATH_TO_PEM=~/.ssh/jenkins-training-key.pem
#export PATH_TO_PEM=~/.ssh/jenkins-docker-training.pem # PEM created through CB AWS console
#export PATH_TO_PEM=~/.ssh/jenkins.pem # CB PEM

echo "
[Credentials]
aws_access_key_id = $AWS_ACCESS_KEY_ID
aws_secret_access_key = $AWS_SECRET_ACCESS_KEY
" >~/.boto
```

Create new instances
--------------------

```bash
sudo ansible-playbook aws.yml \
    --private-key=$PATH_TO_PEM \
    --extra-vars "hosts_group=ec2hosts password=$PASS instances=$INSTANCES preload=true"
```

Provision existing instances
----------------------------

```bash
sudo ansible-playbook aws.yml \
    --private-key=$PATH_TO_PEM \
    -i ec2.py \
    --limit tag_Name_jenkins_docker_training \
    --extra-vars "hosts_group=tag_Name_jenkins_docker_training password=$PASS"
```

Get the list of instances
-------------------------

```bash
sudo ./ec2.py --list
```

SSH to an instance
------------------

```bash
INSTANCE_IP=[INSTANCE_IP]

sudo ssh -i $PATH_TO_PEM ubuntu@$INSTANCE_IP
```

Trainees Setup
==============

* If you do not already have an SSH client, please install [Secure Shell Chrome Extension](https://chrome.google.com/webstore/detail/secure-shell/pnhechapfaindjhompbnflcldabbghjo/related?hl=en)

Exercises
=========

The exercise consists performing the whole delivery lifecycle of an application. We'll test the application, and build and push a Docker container. The service we'll use is written in Go. Since this training is language-agnostic, you are not expected to know the language. You will not need any additional tools. All the tasks can be completed with Docker.

The solutions to all tasks are located at the end. Please try to solve them by yourself and look at the solutions only if you get stuck or want to validate your work.

Before diving into exercises, please SSH into the machine you are assigned and enter the */mnt/training-books-ms/exercises* directory. All the code you'll need is inside.

Docker
------

### Test the code

The command to test the code is as follows.

```bash
go get && go test --cover -v
```

Since Go is not installed on the server, you should use the [golang](https://hub.docker.com/_/golang/) image available in the Docker Hub.

The requirements for this task are as follows.

* Remove the container after the execution of the tests is finished
* The current host directory should be mounted as the */go/src/docker-flow* volume.
* The */go/src/docker-flow* inside the container should be working directory.
* Run the above mentioned command

For additional information, please consult [Docker Run](https://docs.docker.com/engine/reference/commandline/run/) documentation.

### Build the binary

The command to build the binary is as follows.

```bash
go get && go build -v -o docker-flow-proxy
```

The requirements for this task are as follows.

* Remove the container after the execution of the tests is finished
* The current host directory should be mounted as the */go/src/docker-flow* volume.
* The */go/src/docker-flow* inside the container should be working directory.
* Run the above mentioned command

For additional information, please consult [Docker Run](https://docs.docker.com/engine/reference/commandline/run/) documentation.

### Create Dockerfile that defines the Docker image

The Dockerfile that we'll create has the following requirements.

* It should extend the `haproxy:1.6-alpine` image. Alpine is the smallest base image. Extending it will guarantee that our container is as small as it can be.
* Define maintainer's name and email address.
* It should download *Consul Template* binary (*https://releases.hashicorp.com/consul-template/0.13.0/consul-template_0.13.0_linux_amd64.zip*), place it into the */usr/local/bin/* directory with the name *consul-template*, and make it executable. The following set of Linux commands would accomplish this requirement.

```bash
apk add --no-cache --virtual .build-deps curl unzip

curl -SL https://releases.hashicorp.com/consul-template/0.13.0/consul-template_0.13.0_linux_amd64.zip -o /usr/local/bin/consul-template.zip

unzip /usr/local/bin/consul-template.zip -d /usr/local/bin/

rm -f /usr/local/bin/consul-template.zip

chmod +x /usr/local/bin/consul-template
```

* Create a soft link from */lib/libc.musl-x86_64.so.1* to */lib64/ld-linux-x86-64.so.2*. The following set of Linux commands would accomplish this requirement.

```bash
mkdir /lib64

ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2
```

* Create a directory */cfg/tmpl*.
* Copy *haproxy.cfg* to */cfg/haproxy.cfg*.
* Copy *haproxy.tmpl* to */cfg/tmpl/haproxy.tmpl*.
* Copy *docker-flow-proxy* to */usr/local/bin/docker-flow-proxy*.
* Add *execute permissions to */usr/local/bin/docker-flow-proxy*.
* Define an environment variable *CONSUL_ADDRESS* with an empty string as value.
* Expose ports *80* and *8080*.
* Define `docker-flow-proxy server` as container's command.

For additional information, please consult [Dockerfile reference](https://docs.docker.com/engine/reference/builder/) documentation.

Exercise Solutions
==================

Docker
------

### Test the code

```bash
docker run --rm \
    -v $PWD:/go/src/docker-flow \
    -w /go/src/docker-flow \
    golang \
    go get && go test --cover -v
```

The explanation of the arguments is as follows.

* The `--rm` argument automatically removes the container when it exits
* The `-v $PWD:/go/src/docker-flow` argument mounts the current directory (`$PWD`) as `/go/src/docker-flow`.
* The `go get && go test --cover -v ./...` argument is the command that is run inside the container

### Build the binary

```bash
docker run --rm -v $PWD:/go/src/docker-flow -w /go/src/docker-flow golang go get && go build -v -o docker-flow-proxy
```

The explanation of the arguments is as follows.

* The `--rm` argument automatically removes the container when it exits
* The `-v $PWD:/go/src/docker-flow` argument mounts the current directory (`$PWD`) as `/go/src/docker-flow`.
* The `go get && go build -v -o docker-flow-proxy` argument is the command that is run inside the container

### Create Dockerfile that defines the Docker image

The content of the *Dockerfile* is as follows.

```
FROM haproxy:1.6-alpine
MAINTAINER 	Viktor Farcic <vfarcic@cloudbees.com>

RUN apk add --no-cache --virtual .build-deps curl unzip && \
    curl -SL https://releases.hashicorp.com/consul-template/0.13.0/consul-template_0.13.0_linux_amd64.zip -o /usr/local/bin/consul-template.zip && \
    unzip /usr/local/bin/consul-template.zip -d /usr/local/bin/ && \
    rm -f /usr/local/bin/consul-template.zip && \
    chmod +x /usr/local/bin/consul-template && \
    apk del .build-deps

RUN mkdir /lib64 && ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2
RUN mkdir -p /cfg/tmpl
COPY haproxy.cfg /cfg/haproxy.cfg
COPY haproxy.tmpl /cfg/tmpl/haproxy.tmpl
COPY docker-flow-proxy /usr/local/bin/docker-flow-proxy
RUN chmod +x /usr/local/bin/docker-flow-proxy

ENV CONSUL_ADDRESS ""
EXPOSE 80
EXPOSE 8080

CMD ["docker-flow-proxy", "server"]
```

TODO: Continue









### Build the container and push it to the private registry

```bash
docker build -t localhost/docker-flow-proxy .

docker push localhost/docker-flow-proxy
```




node("cd") {
    git "https://github.com/cloudbees/training-books-ms.git"
    def dir = pwd()
    sh "mkdir -p ${dir}/db"
    sh "chmod 0777 ${dir}/db"

    stage "pre-deployment tests"
    def tests = docker.image("localhost:5000/training-books-ms-tests")
    tests.pull()
    tests.inside("-v ${dir}/db:/data/db") {
        sh "./run_tests.sh"
    }

    stage "build"
    def service = docker.build "localhost:5000/training-books-ms"
    service.push()
    stash includes: "docker-compose*.yml", name: "docker-compose"
}

checkpoint "deploy"

node("production") {
    stage "deploy"
    def response = input message: 'Please confirm deployment to production', ok: 'Submit', parameters: [[$class: 'StringParameterDefinition', defaultValue: '', description: 'Additional comments', name: '']], submitter: 'manager'
    echo response
    unstash "docker-compose"
    def pull = [:]
    pull["service"] = {
        docker.image("localhost:5000/training-books-ms").pull()
    }
    pull["db"] = {
        docker.image("mongo").pull()
    }
    parallel pull
    sh "docker-compose -p books-ms up -d app"
    sleep 2
}

node("cd") {
    stage "post-deployment tests"
    def tests = docker.image("localhost:5000/training-books-ms-tests")
    tests.inside() {
        withEnv(["TEST_TYPE=integ", "DOMAIN=http://54.93.170.250:8081"]) {
            retry(2) {
                sh "./run_tests.sh"
            }
        }
    }
}