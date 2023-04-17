role_name="role-acess-ssm"
policy_name="AmazonSSMManagedInstanceCore"

aws iam create-role --role-name $role_name --assume-role-policy-document \
'{
  "Version": "2012-10-17",
  "Statement": {
    "Effect": "Allow",
    "Principal": {
      "Service": "ec2.amazonaws.com"
    },
    "Action": "sts:AssumeRole"
  }
}'

aws iam attach-role-policy --role-name $role_name --policy-arn arn:aws:iam::aws:policy/$policy_name