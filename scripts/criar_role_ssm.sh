role_name="role-acesso-ssm"
policy_name="AmazonSSMManagedInstanceCore"

if aws iam get-role --role-name "$role_name" &> /dev/null; then
    echo "A IAM role $role_name já existe."
    exit 1
fi

aws iam create-role --role-name $role_name --assume-role-policy-document file://ec2_principal.json
# Cria o perfil de instância
aws iam create-instance-profile --instance-profile-name $role_name

# Adiciona a função IAM ao perfil de instância
aws iam add-role-to-instance-profile --instance-profile-name $role_name --role-name $role_name

aws iam attach-role-policy --role-name $role_name --policy-arn arn:aws:iam::aws:policy/$policy_name