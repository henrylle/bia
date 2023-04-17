role_name="role-acesso-ssm"
policy_name="AmazonSSMManagedInstanceCore"

aws iam create-role --role-name $role_name --assume-role-policy-document file://ec2_principal.json

aws iam attach-role-policy --role-name $role_name --policy-arn arn:aws:iam::aws:policy/$policy_name