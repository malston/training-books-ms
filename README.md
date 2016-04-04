Trainer Setup
=============

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

# Create new instances

sudo ansible-playbook aws.yml \
    --private-key=$PATH_TO_PEM \
    --extra-vars "hosts_group=ec2hosts password=$PASS instances=$INSTANCES preload=true"

# Provision existing instances

sudo ansible-playbook aws.yml \
    --private-key=$PATH_TO_PEM \
    -i ec2.py \
    --limit tag_Name_jenkins_docker_training \
    --extra-vars "hosts_group=tag_Name_jenkins_docker_training password=$PASS"

# Get the list of instances

sudo ./ec2.py --list

# Connect to an instance

INSTANCE_IP=[INSTANCE_IP]

sudo ssh -i $PATH_TO_PEM ubuntu@$INSTANCE_IP
```

Trainees Setup
==============

* If you do not already have an SSH client, please install [Secure Shell Chrome Extension](https://chrome.google.com/webstore/detail/secure-shell/pnhechapfaindjhompbnflcldabbghjo/related?hl=en)





```groovy
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
        docker.image("localhost:5000/books-ms").pull()
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
        withEnv(["TEST_TYPE=integ", "DOMAIN=http://[IP]:8081"]) {
            retry(2) {
                sh "./run_tests.sh"
            }
        }
    }
}
```

TomTom Meeting Summary (4th of April 2016)
==========================================

* Not much interest within the company
* "Navigation" team is using TeamCity. They spoke with someone and were not impressed with Jenkins.
* "PND" team is using two CJE masters. Involved with Docker. Interested in 60 minutes focused on Docker integration. Francois Mayer is PND manager. Michael Waysman is architect. Use AWS with CentOS 7 and use it for Docker integration.
* "Maps" or "CPP" team is the biggest Jenkins user (three masters). Lots of jobs.
* "Developers support" team. Many custom slaves connected to a master (mostly laptops, desktops, and VMs). Separate LDAPs on masters. Cannot manage users and slaves centrally. Requesting help with Puppet.
* Suggestion to dedicate 4 days of the engagement (out of 7 left) to the support team and make sure that CJOCs and CJEs are up and running.