Setup
=====

```bash
export AWS_ACCESS_KEY_ID='[YOUR_ACCESS_KEY_ID]'
export AWS_SECRET_ACCESS_KEY='[YOUR_SECRET_ACCESS_KEY]'
export PATH_TO_PEM=~/.ssh/jenkins-training-key.pem

echo "
[Credentials]
aws_access_key_id = $AWS_ACCESS_KEY_ID
aws_secret_access_key = $AWS_SECRET_ACCESS_KEY
" >~/.boto

# Create new instances and provision existing ones

sudo ansible-playbook aws.yml \
    --private-key=$PATH_TO_PEM \
    -i ec2.py \
    --limit tag_Name_jenkins_docker_training \
    --extra-vars "hosts_group=tag_Name_jenkins_docker_training"

# Create new instances only

sudo ansible-playbook aws-new.yml \
    --private-key=$PATH_TO_PEM \
    -i ec2.py \
    --limit tag_Name_jenkins_docker_training \
    --extra-vars "hosts_group=ec2hosts"

# Get the list of instances

sudo ./ec2.py --list

# Connect to an instance

INSTANCE_IP=[INSTANCE_IP]

ssh -i ~/.ssh/jenkins-training-key.pem ubuntu@$INSTANCE_IP
```

TODO
====

* Add Web SSH
* Print the list of hosts
* Confirm that the presentation works
* Create UI to manage instances
