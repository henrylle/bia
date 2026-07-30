script_dir=$(cd "$(dirname "$0")" && pwd)   # roda de qualquer pasta, sem mudar o cwd

role_name="role-acesso-ssm"
policy_name="AmazonSSMManagedInstanceCore"

if aws iam get-role --role-name "$role_name" &> /dev/null; then
    echo "A IAM role $role_name já existe."
    exit 1
fi

aws iam create-role --role-name $role_name --assume-role-policy-document file://$script_dir/ec2_principal.json
# Cria o perfil de instância (pode ter sobrado de uma execução que falhou no meio)
if aws iam get-instance-profile --instance-profile-name "$role_name" &> /dev/null; then
    echo "Perfil de instância $role_name já existe, reaproveitando."
else
    aws iam create-instance-profile --instance-profile-name $role_name
fi

# Adiciona a função IAM ao perfil de instância
aws iam add-role-to-instance-profile --instance-profile-name $role_name --role-name $role_name

aws iam attach-role-policy --role-name $role_name --policy-arn arn:aws:iam::aws:policy/$policy_name