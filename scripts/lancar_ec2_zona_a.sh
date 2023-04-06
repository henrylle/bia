vpc_id=$(aws ec2 describe-vpcs --filters Name=isDefault,Values=true --query "Vpcs[0].VpcId" --output text)
subnet_id=$(aws ec2 describe-subnets --filters Name=vpc-id,Values=$vpc_id Name=availabilityZone,Values=us-east-1a)
echo $subnet_id
security_group_id="1234"
#aws ec2 run-instances --image-id ami-02f3f602d23f1659d --count 1 --instance-type t3.micro --security-group-ids $security_group_id --subnet-id $subnet_id
