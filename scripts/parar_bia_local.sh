nome="bia-local"
aws ec2 stop-instances --filters "Name=tag:Name,Values=$nome" --query 'StoppingInstances[*].InstanceId'
