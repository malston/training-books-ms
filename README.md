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
