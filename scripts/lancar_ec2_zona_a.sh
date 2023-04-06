vpc_id=$(aws ec2 describe-vpcs --filters Name=isDefault,Values=true --query "Vpcs[0].VpcId" --output text)
echo $vpc_id
#aws ec2 run-instances --image-id ami-0c94855ba95c71c99 --count 1 --instance-type t2.micro --key-name my-key-pair --security-group-ids sg-0d29a6b892e6a77a3 --subnet-id subnet-0bf25b18d43b73951
