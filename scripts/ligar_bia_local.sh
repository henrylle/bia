nome="bia-local"
instance_id=$(aws ec2 describe-instances --query 'Reservations[].Instances[].InstanceId' --filters "Name=tag:Name,Values=$nome" --output text)
aws ec2 start-instances  --instance-ids $instance_id
